import 'dart:async';
import 'dart:io';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageProviderNotifier extends ChangeNotifier {
  BuildContext? context;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _networkImageUrl;
  String? _errorMessage;
  String? fallbackImage;
  bool _isImageInitialized = false;

  bool get isImageInitialized => _isImageInitialized;
  XFile? get imageFile => _imageFile;
  String? get networkImageUrl => _networkImageUrl;
  String? get errorMessage => _errorMessage;

  void setContext(BuildContext ctx) => context = ctx;

  /// Pick image from gallery or camera
  Future<void> pickImage(
    ImageSource source,
    Size size,
  ) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _imageFile = pickedFile;
        _errorMessage = null;
        await uploadToFirebaseStorage();
      } else {
        _errorMessage = "No image selected.";
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to pick image: $e";
      if (e is SocketException) {
        if (context?.mounted ?? false) {
          Toast.errorToast(context!,
              'Sorry, could not update your profile photo. Please try again later',
              color: Colors.grey.shade900,
              position: DelightSnackbarPosition.bottom,
              leading: SizedBox(
                  height: size.height * 0.06,
                  width: size.width * 0.06,
                  child:
                      Image.asset(fit: BoxFit.contain, IconManager.warning)));
        }
      } else {
        if (context?.mounted ?? false) {
          Toast.errorToast(context!,
              'Sorry, could not update your profile photo. Please try again later',
              color: Colors.grey.shade900,
              position: DelightSnackbarPosition.bottom,
              leading: SizedBox(
                  height: size.height * 0.06,
                  width: size.width * 0.06,
                  child:
                      Image.asset(fit: BoxFit.contain, IconManager.warning)));
        }
      }
      if (kDebugMode) print(_errorMessage);
      notifyListeners();
    }
  }

  /// Retrieve lost image (if app was terminated during image picking)
  Future<void> retrieveLostData(BuildContext context) async {
    if (kIsWeb) return; // Skip web
    try {
      final response = await _picker.retrieveLostData();

      if (response.isEmpty) return;

      if (response.files != null && response.files!.isNotEmpty) {
        _imageFile = response.files!.first;
        _errorMessage = null;
        await uploadToFirebaseStorage();
        // ✅ Upload recovered image
      } else {
        _errorMessage = "Failed to retrieve image: ${response.exception}";
        if (kDebugMode) print(_errorMessage);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error retrieving lost image: $e";
      if (kDebugMode) print(_errorMessage);
      notifyListeners();
    }
  }

  Future<void> uploadToFirebaseStorage() async {
    // 1. Check network
    if (!await hasNetwork()) {
      throw Exception(
          'Sorry, could not update your profile photo. Please try again later');
    }

    // 2. Reload user
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();

    if (_imageFile == null) {
      if (kDebugMode) print('No image selected');
    }

    final imageFile = File(_imageFile!.path);
    if (!imageFile.existsSync()) {
      if (kDebugMode) print('Invalid file path: ${_imageFile!.path}');
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('Images')
        .child('${user?.uid}.jpg');

    try {
      // 3. Upload image
      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.timeout(const Duration(seconds: 10));

      // 4. Get download URL
      final downloadURL = await storageRef.getDownloadURL();

      // 5. Update user Firestore doc
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      await userDocRef.update({'imageUrl': downloadURL});

      // 6. Save success state
      _networkImageUrl = downloadURL;
      _errorMessage = null;

      if (kDebugMode) print('Image uploaded: $downloadURL');
    } on TimeoutException {
      throw Exception(
          'Sorry, could not update your profile photo. Please try again later');
    } on FirebaseException catch (e) {
      if (e.code == 'canceled') {
        throw Exception(
            'Sorry, could not update your profile photo. Please try again later');
      } else {
        throw Exception(
            'Sorry, could not update your profile photo. Please try again later');
      }
    } on SocketException {
      throw Exception(
          'Sorry, could not update your profile photo. Please try again later');
    } catch (e) {
      throw Exception(
          'Sorry, could not update your profile photo. Please try again later');
    }
  }

  /// Load image from Firestore or fall back to local image
  Future<void> getProfileImageInternal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final imageUrl = doc.data()?['imageUrl'];
      final prefs = await SharedPreferences.getInstance();
      _networkImageUrl = imageUrl;
      if (imageUrl != null) {
        prefs.setString('ImageUrl', imageUrl);
      }
    } catch (e) {
      if (kDebugMode) print("getProfileImage error: $e");
    }
  }

  Future<void> loadFallbackImageInternal() async {
    fallbackImage = await getFallbackImageFromPref();
  }

  Future<String?> getFallbackImageFromPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ImageUrl');
  }

  Future<void> clearImagePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ImageUrl');
    _networkImageUrl = null;
    _imageFile = null;
    fallbackImage = null;
    notifyListeners();
  }

  void resetImageInitialization() {
    _isImageInitialized = false;
    notifyListeners();
  }

  Future<void> initializeProfileImages() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners(); // Safe to notify now
    });

    try {
      await getProfileImageInternal(); // <- we'll make this internal
      await loadFallbackImageInternal(); // <- we'll make this internal
    } catch (e) {
      if (kDebugMode) print('Error initializing images: $e');
    }

    _isImageInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners(); // Safe to notify now
    });
  }

  getBuildContext(BuildContext newContext) {
    context = newContext;
  }
}
