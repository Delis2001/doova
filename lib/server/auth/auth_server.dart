import 'dart:io';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
final String catchMessage = 'We ran into a problem. Please try again shortly';
final String networkMessage =
    'No internet connection. Connect to the internet and try again';

class AuthServer {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with Email and Password
  Future<User?> registerWithEmail(String email, String password,
      String fullName, BuildContext context) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // Save user info to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'Name': fullName,
          'authMethod': 'password',
          'createdAt': FieldValue.serverTimestamp(),
          'coins': 5,
          'isPremium': false,
        });
        // Send verification email
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          await FirebaseAuth.instance
              .signOut(); // Force logout until verification
          Toast.successToast(context,
              'Verification email sent. Please verify before logging in');
        }

        return user;
      }

      return null;
    } on SocketException {
      Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    } on PlatformException catch (error) {
      if (error.code == 'network_error') {
        Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      } else {
       Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      }
      return null;
    } on FirebaseAuthException catch (error) {
      firebaseAuthError(error, context);
      return null;
    } catch (error) {
       Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    }
  }

  // Get Auth Method by Email
  Future<String?> getAuthMethodByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first['authMethod'] as String;
  }

  // Login with Email and Password
  Future<User?> loginWithEmail(
      String email, String password, BuildContext context) async {
    try {
      final method = await getAuthMethodByEmail(email);
      if (method == null) {
        Toast.errorToast(context, 'User not found. Please confirm your credentials or consider signing up',  color: Colors.red, position: DelightSnackbarPosition.top);
        return null;
      }
      if (method != 'password') {
        Toast.errorToast(context,
            'This email was registered using $method. Please log in with $method',  color: Colors.red, position: DelightSnackbarPosition.top);
        return null;
      }

      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on SocketException {
     Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    } on PlatformException catch (error) {
      if (error.code == 'network_error') {
        Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      } else {
       Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      firebaseAuthError(e, context);
      return null;
    } catch (e) {
      Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final existingMethod = await getAuthMethodByEmail(googleUser.email);

      if (existingMethod != null && existingMethod != 'google') {
        Toast.errorToast(context,
            'This email was registered using $existingMethod. Please log in with $existingMethod',  color: Colors.red, position: DelightSnackbarPosition.top);
        // Sign out from Google to let them choose another account next time
        await googleSignIn.signOut();
        return null;
      }

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (existingMethod == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'Name': userCredential.user!.displayName,
          'coins': 5,
          'isPremium': false,
          'authMethod': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential.user;
    } on SocketException {
      Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    } on PlatformException catch (error) {
      if (error.code == 'network_error') {
        Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
        return null;
      } else {
        Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      }
      return null;
    } on FirebaseAuthException catch (error) {
      firebaseAuthError(error, context);
      return null;
    } catch (error) {
       Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      await GoogleSignIn().signOut();
      return null;
    }
  }

  // Sign in with Apple
  Future<User?> signInWithApple(BuildContext context) async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.delis.doova.service',
          redirectUri:
              Uri.parse('https://doova-709a7.firebaseapp.com/__/auth/handler'),
        ),
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // This is safer: wait for the userCredential before checking the email
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final userEmail = userCredential.user?.email;
      final uid = userCredential.user?.uid;
      final userName =
          '${appleCredential.givenName} ${appleCredential.familyName}';

      if (userEmail != null) {
        final existingMethod = await getAuthMethodByEmail(userEmail);
        if (existingMethod != null && existingMethod != 'apple') {
          Toast.errorToast(context,
              'This email was registered using $existingMethod. Please log in with $existingMethod',  color: Colors.red, position: DelightSnackbarPosition.top);
          return null;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': uid,
        'email': userEmail,
        'Name': userName,
        'coins': 5,
        'isPremium': false,
        'authMethod': 'apple',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return userCredential.user;
    } on SocketException {
      Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    } on PlatformException catch (error) {
      if (error.code == 'network_error') {
        Toast.errorToast(context,networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
        return null;
      } else {
        Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      }
      return null;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        Toast.errorToast(context, 'Apple sign-in was cancelled',  color: Colors.red, position: DelightSnackbarPosition.top);
      } else {
        Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      }
      return null;
    } on FirebaseAuthException catch (error) {
      firebaseAuthError(error, context);
      return null;
    } catch (error) {
      Toast.errorToast(context,catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return null;
    }
  }

//Update email
  Future<void> updateEmail(BuildContext context, String newEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'no-user', message: 'User not found. Please confirm your credentials or consider signing up');
      }

      // ✅ Avoid changing to the same email
      if (user.email == newEmail.trim()) {
        throw FirebaseAuthException(
            code: 'same-email', message: 'This is already your current email');
      }

      // ✅ Quick internet check
      try {
        await FirebaseFirestore.instance
            .collection('connectivity-check')
            .doc('ping')
            .get()
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        throw FirebaseAuthException(
          code: 'firestore-offline',
          message: networkMessage,
        );
      }

      final providerId = user.providerData.first.providerId;
      if (providerId != 'password') {
        throw FirebaseAuthException(
            code: 'email-change-not-allowed',
            message: 'Email change is not allowed');
      }
      // ✅ Refresh email verification status
      await user.reload();
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        throw FirebaseAuthException(
            code: 'email-not-verified',
            message:
                'Please verify your current email before changing to a new one');
      }

      // ✅ Change email
      await user.updateEmail(newEmail.trim());

      // ✅ Send verification to new email
      await user.sendEmailVerification();

      // ✅ Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'email': newEmail.trim()});
    } on FirebaseAuthException catch (_) {
      rethrow; // Rethrow to be handled by the provider
    } catch (e) {
      throw Exception(catchMessage); // Handle other errors
    }
  }

//Update password
  Future<void> updatePassword({
    required BuildContext context,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Toast.errorToast(context, 'User not found. Please confirm your credentials or consider signing up',  color: Colors.red, position: DelightSnackbarPosition.top);
        return;
      }
      final providerId = user.providerData.first.providerId;

      if (providerId == 'password') {
        // Re-authenticate with old password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
        // Proceed to update password
        await user.updatePassword(newPassword);
        Toast.successToast(context, 'Your account password has been updated');
      } else {
        Toast.errorToast(
          context,
          'You signed in with $providerId, password change not allowed',  color: Colors.red, position: DelightSnackbarPosition.top
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Toast.errorToast(context, 'Current password is incorrect',  color: Colors.red, position: DelightSnackbarPosition.top);
        return;
      } else if (e.code == 'requires-recent-login') {
        Toast.errorToast(context, 'Please re-login and try again',  color: Colors.red, position: DelightSnackbarPosition.top);
        return;
      } else {
        firebaseAuthError(e, context);
        return;
      }
    } on SocketException {
      Toast.errorToast(context, networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    } on PlatformException catch (error) {
      if (error.code == 'network_error') {
        Toast.errorToast(context, networkMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
        return;
      } else {
        Toast.errorToast(context, catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
        return;
      }
    } catch (e) {
      Toast.errorToast(context, catchMessage,  color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }
  }

// update fullName
  Future<void> updateName(BuildContext context, String newName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'User not found. Please confirm your credentials or consider signing up',
      );
    }
    // ✅ Connectivity check
    try {
      await FirebaseFirestore.instance
          .collection('connectivity-check')
          .doc('ping')
          .get()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      throw FirebaseAuthException(
        code: 'firestore-offline',
        message: networkMessage,
      );
    }
    // ✅ Update Firestore and display name
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'Name': newName});

      await user.updateDisplayName(newName);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'update-failed',
        message: 'Unable to update name at this time. Please try again later.',
      );
    }
  }


  Future<void> logout(BuildContext context,) async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();
      // Sign out from Google to avoid auto sign-in
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      context.pushReplacement('/IntroScreenDefault/Login');
      // No sign-out required for Apple; it's stateless
    } catch (e) {
      if (kDebugMode) {
      debugPrint('Logout error: $e');
      }
    }
  }
}
