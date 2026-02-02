import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// bool _isContextMounted(BuildContext context) {
//   // context is Element in Flutter, check mounted property safely
//   if (context is! Element) return false;
//   return context.mounted;
// }
class Toast {
  static double _screenWidth = 0;

  static void setScreenWidth(double width) {
    _screenWidth = width > 600 ? 600 : width;
  }

  static double scaleWidth(double factor) => _screenWidth * factor;

  static void errorToast(
    BuildContext context,
    String title, {
    required Color color,
    required DelightSnackbarPosition position,
    Widget? leading,
    bool isYellow = false,
  }) {
    if (!context.mounted) return;

    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isYellow ? Colors.yellow : Colors.white,
          fontSize: scaleWidth(0.04),
        );
    DelightToastBar(
      position: position,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
      builder: (_) {
        return ToastCard(
          leading: leading,
          color: color,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        );
      },
    ).show(context);
  }

  static void successToast(BuildContext context, String title) {
    if (!context.mounted) return;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontSize: scaleWidth(0.04),
        );
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 3),
      builder: (_) {
        return ToastCard(
          color: Colors.green,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        );
      },
    ).show(context);
  }
}

void firebaseAuthError(FirebaseAuthException e, BuildContext context) {
  switch (e.code) {
    case 'user-not-found':
      Toast.errorToast(context, 'No user found with this email',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'wrong-password':
      Toast.errorToast(context, 'Incorrect password',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'email-already-in-use':
      Toast.errorToast(context, 'This email is already in use',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'invalid-email':
      Toast.errorToast(context, 'Invalid email format',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'weak-password':
      Toast.errorToast(
          context, 'Password is too weak. Please use at least 6 characters',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'user-disabled':
      Toast.errorToast(context, 'Your account has been disabled',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'too-many-requests':
      Toast.errorToast(context, 'Too many attempts. Try again later',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'account-exists-with-different-credential':
      Toast.errorToast(
          context, 'An account already exists with a different sign-in method',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'popup-closed-by-user':
      Toast.errorToast(context, 'Sign-in popup closed before completing',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'network-request-failed':
      Toast.errorToast(context, 'Please check your internet connection',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    case 'requires-recent-login':
      Toast.errorToast(context, 'Please re-login to perform this operation',
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
    default:
      Toast.errorToast(context, e.message.toString(),
          color: Colors.red, position: DelightSnackbarPosition.top);
      break;
  }
}
