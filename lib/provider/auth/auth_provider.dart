// providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/server/auth/auth_server.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String catchMessage = 'We ran into a problem. Please try again shortly';
final String networkMessage =
    'No internet connection. Connect to the internet and try again';

class AuthProvider with ChangeNotifier {
  final AuthServer _authService = AuthServer();
  User? _user;
  bool _isLoading = false;
  String? _fullName;
  String? _email;

  String? get fullName => _fullName;
  String? get email => _email;
  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);
      _user = await _authService.registerWithEmail(
          email, password, fullName, context);
      if (_user != null) {
        _setLoading(false);

        Toast.successToast(
          context,
          'Verification link sent. Please verify before logging in',
        );
        context.go('/IntroScreenDefault/Login');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    } finally {
      _setLoading(false); // <- Ensures loading stops in ALL cases
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);
      _user = await _authService.loginWithEmail(email, password, context);
      if (_user != null) {
        _setLoading(false);
        // Refresh user data
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        if (_user!.emailVerified) {
          context.pushReplacement('/HomeScreen');
        } else {
          await _authService.logout(context);
          Toast.errorToast(context, 'Please verify your email before logging in',
              color: Colors.red, position: DelightSnackbarPosition.top);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signInWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);
      _user = await _authService.signInWithGoogle(context);
      if (_user != null) {
        _setLoading(false);
        // Refresh user data
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        if (_user!.emailVerified) {
          context.pushReplacement('/HomeScreen');
        } else {
          await _authService.logout(context);
          return 'Please verify your email before continuing';
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signInWithApple(BuildContext context) async {
    try {
      _setLoading(true);
      _user = await _authService.signInWithApple(context);
      if (_user != null) {
        _setLoading(false);
        context.pushReplacement('/HomeScreen');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword({
    required String newPassword,
    required String oldPassword,
    required BuildContext context,
  }) async {
    try {
      context.pop();
      _setLoading(true);
      await _authService.updatePassword(
          context: context, newPassword: newPassword, oldPassword: oldPassword);
      await FirebaseAuth.instance.currentUser?.reload();
      _user = FirebaseAuth.instance.currentUser;
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (kDebugMode) {
        debugPrint('$e');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEmail({
    required String newEmail,
    required BuildContext context,
  }) async {
    try {
      context.pop(); // ✅ just context.pop() — no need to pass context again!
      _setLoading(true);

      await _authService.updateEmail(context, newEmail);
        Toast.successToast(context, 'A verification link was sent to your new email.');

      // ✅ If you want: reload here — optional!
      await FirebaseAuth.instance.currentUser?.reload();
      _user = FirebaseAuth.instance.currentUser;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);

      if (e.code == 'no-user') {
        Toast.errorToast(context,
            'User not found. Please confirm your credentials or sign up.',
            color: Colors.red, position: DelightSnackbarPosition.top);
      } else if (e.code == 'same-email') {
        Toast.errorToast(context, 'This is already your current email.',
            color: Colors.red, position: DelightSnackbarPosition.top);
      } else if (e.code == 'firestore-offline') {
        Toast.errorToast(context, networkMessage,
            color: Colors.red, position: DelightSnackbarPosition.top);
      } else if (e.code == 'email-change-not-allowed') {
        final providerId =
            FirebaseAuth.instance.currentUser?.providerData.first.providerId ??
                'unknown';
        Toast.errorToast(context,
            'You signed in with $providerId, email change not allowed.',
            color: Colors.red, position: DelightSnackbarPosition.top);
      } else if (e.code == 'operation-not-allowed') {
        Toast.errorToast(context,
            'Email change is currently restricted. Please contact support.',
            color: Colors.red, position: DelightSnackbarPosition.top);
      } else if (e.code == 'email-not-verified') {
        Toast.errorToast(context,
            'Please verify your current email before changing to a new one.',
            color: Colors.red, position: DelightSnackbarPosition.top);
      } else {
        firebaseAuthError(e, context);
      }
    } catch (e) {
      _setLoading(false);
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
     if (kDebugMode) {
        debugPrint('$e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateName({
    required String newName,
    required BuildContext context,
  }) async {
    try {
      context.pop();
      _setLoading(true);
      await _authService.updateName(context, newName);
      await FirebaseAuth.instance.currentUser?.reload();
      _user = FirebaseAuth.instance.currentUser;
      _fullName = newName;
    } on FirebaseAuthException catch (_) {
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      _setLoading(false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _authService.logout(context);
      _user = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('Logout failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected error during logout: $e');
      }
    }
  }

  Future<void> setUerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _fullName = doc.data()?['Name'];
    _email = doc.data()?['email'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Name', _fullName!);
    await prefs.setString('email', _email!);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
