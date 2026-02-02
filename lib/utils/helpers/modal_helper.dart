import 'package:doova/views/task/add_task.dart';
import 'package:doova/components/profile/profile_modal_items.dart';
import 'package:flutter/material.dart';

void imagePicker(BuildContext context,Size size) {
  showGeneralDialog(
    context: context,
    barrierLabel: 'image Picker',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(size.width*0.04),
              topRight: Radius.circular(size.width*0.04),
            ),
            clipBehavior: Clip.antiAlias,
            child: ProfileModalItems(size: size),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

void openModalBottomSheet(BuildContext context,Size size) {
  showGeneralDialog(
    context: context,
    barrierLabel: 'Add Task',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(size.width*0.04),
              topRight: Radius.circular(size.width*0.04),
            ),
            clipBehavior: Clip.antiAlias,
            child: const AddTaskScreen(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
