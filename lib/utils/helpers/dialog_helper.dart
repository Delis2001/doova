import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/components/indicator.dart';
import 'package:doova/components/profile/textfield.dart';
import 'package:doova/components/task/add_task/category_items.dart';
import 'package:doova/components/task/add_task/priority_items.dart';
import 'package:doova/constant/dummy.dart';
import 'package:doova/model/add_task/category.dart';
import 'package:doova/model/add_task/sub_task.dart';
import 'package:doova/model/add_task/task.dart';
import 'package:doova/provider/auth/auth_provider.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/server/monetizing/ads_server.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:doova/views/task/create_new_category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

void showCustomDialog(
  BuildContext context, {
  required String title,
  required Size size,
  required List<Widget> items,
  required VoidCallback elevatedButtonOnTap,
  Size? elevatedButtonSize,
  VoidCallback? textButtonOnTap,
  String? text1,
  String? text2,
  bool isElevatedButtonNotCentered = true,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  showDialog(
    context: context,
    useSafeArea: true,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor:
          isDark ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * 0.9),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Title
              Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: size.width * 0.04),
                  ),
                  SizedBox(height: size.height * 0.02),
                  const Divider(
                    thickness: 1,
                  ),
                ],
              ),

              /// Scrollable content
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.5,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: items,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.010),

              /// Action buttons
              Row(
                mainAxisAlignment: isElevatedButtonNotCentered
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  /// Cancel / TextButton
                  isElevatedButtonNotCentered
                      ? TextButton(
                          onPressed: textButtonOnTap,
                          child: Text(
                            text1 ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: size.width * 0.04,
                                ),
                          ),
                        )
                      : Container(),

                  /// Save / ElevatedButton
                  ElevatedButton(
                    onPressed: elevatedButtonOnTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6F24E9),
                      minimumSize: elevatedButtonSize ??
                          Size(size.width * 0.5, size.height * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.01),
                      ),
                    ),
                    child: Text(
                      text2 ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: size.width * 0.04,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

passwordDialog({
  required BuildContext context,
  required FormFieldValidator<String> oldPasswordValidator,
  required FormFieldValidator<String> newPasswordValidator,
  required FormFieldSetter<String> onSaved,
  required TextEditingController oldPasswordController,
  required TextEditingController newPasswordController,
  required GlobalKey<FormState> formKey,
  required Size size,
}) {
  bool oldPasswordObscureText = false;
  bool newPasswordObscureText = false;
  showCustomDialog(context,
      size: size,
      isElevatedButtonNotCentered: true,
      title: 'Change account Password',
      items: [
        StatefulBuilder(builder: (context, setState) {
          return Form(
              key: formKey,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter old password',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: size.width * 0.04)),
                    SizedBox(
                      height: size.height * 0.005,
                    ),
                    ProfileScreenCustomTextField(
                      controller: oldPasswordController,
                      onSaved: onSaved,
                      validator: oldPasswordValidator,
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              oldPasswordObscureText = !oldPasswordObscureText;
                            });
                          },
                          icon: Icon(
                              size: size.width * 0.05,
                              oldPasswordObscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xff979797))),
                      obscureText: !oldPasswordObscureText,
                      hintText: '************',
                    ),
                    Text('Enter new password',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: size.width * 0.04)),
                    SizedBox(
                      height: size.height * 0.005,
                    ),
                    ProfileScreenCustomTextField(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              newPasswordObscureText = !newPasswordObscureText;
                            });
                          },
                          icon: Icon(
                            size: size.width * 0.05,
                            newPasswordObscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color(0xff979797),
                          )),
                      obscureText: !newPasswordObscureText,
                      controller: newPasswordController,
                      onSaved: onSaved,
                      validator: newPasswordValidator,
                      hintText: '************',
                    )
                  ],
                ),
              ));
        })
      ],
      elevatedButtonOnTap: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await context.read<AuthProvider>().updatePassword(
              oldPassword: oldPasswordController.text.trim(),
              newPassword: newPasswordController.text.trim(),
              context: context);
        }
        oldPasswordController.clear();
        newPasswordController.clear();
      },
      text1: 'Cancel',
      text2: 'Edit',
      textButtonOnTap: () {
        oldPasswordController.clear();
        newPasswordController.clear();
        context.pop(context);
      });
}

nameDialog({
  required BuildContext context,
  required FormFieldValidator<String> validator,
  required FormFieldSetter<String> onSaved,
  required TextEditingController nameController,
  required GlobalKey<FormState> formKey,
  required Size size,
}) {
  showCustomDialog(context,
      size: size,
      isElevatedButtonNotCentered: true,
      title: 'Change account name',
      items: [
        Form(
            key: formKey,
            child: ProfileScreenCustomTextField(
              controller: nameController,
              validator: validator,
              onSaved: onSaved,
            ))
      ],
      elevatedButtonOnTap: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await context.read<AuthProvider>().updateName(
              newName: nameController.text.trim(), context: context);
        }
        return;
      },
      text1: 'Cancel',
      text2: 'Edit',
      textButtonOnTap: () {
        if (context.mounted) context.pop(context);
      });
}

emailDialog({
  required BuildContext context,
  required FormFieldValidator<String> validator,
  required FormFieldSetter<String> onSaved,
  required TextEditingController emailController,
  required GlobalKey<FormState> formKey,
  required Size size,
}) {
  showCustomDialog(context,
      size: size,
      isElevatedButtonNotCentered: true,
      title: 'Change account email',
      items: [
        Form(
            key: formKey,
            child: ProfileScreenCustomTextField(
              controller: emailController,
              validator: validator,
              onSaved: onSaved,
            ))
      ],
      elevatedButtonOnTap: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await context.read<AuthProvider>().updateEmail(
              newEmail: emailController.text.trim(), context: context);
        }
        return;
      },
      text1: 'Cancel',
      text2: 'Edit',
      textButtonOnTap: () {
        if (context.mounted) context.pop(context);
      });
}

priorityDialog(
  BuildContext context,
  String title,
  String text2,
  void Function(int selectedPriority) onSelect,
  Size size,
) {
  int? selectedPriority = 0;
  return showCustomDialog(context,
      size: size,
      isElevatedButtonNotCentered: true,
      title: title,
      items: [
        StatefulBuilder(
          builder: (context, setInnerState) {
            return SingleChildScrollView(
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.7,
                ),
                itemCount: priority.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedPriority == index;
                  return PriorityItems(
                    priority: priority[index],
                    isSelectedPriority: isSelected,
                    onTap: () {
                      setInnerState(() {
                        selectedPriority = index;
                      });
                      // print(
                      //     'This the priority selected${priority[index].number}');
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
      elevatedButtonOnTap: () {
        onSelect(selectedPriority! + 1);
        context.read<TaskProvider>().setSelectedPriority(selectedPriority! + 1);
        context.pop(context);
      },
      text1: 'Cancel',
      text2: text2,
      textButtonOnTap: () {
        context.pop(context);
      });
}

void categoryDialog(
  BuildContext context,
  Size size,
  String text2,
  void Function(CategoryModel selectedCategory) onSelect,
) {
  CategoryModel? selectedCategory;
  showCustomDialog(
    size: size,
    context,
    title: 'Choose Category',
    isElevatedButtonNotCentered: false,
    items: [
      StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                final allCategories = provider.allCategories;
                final sortedCategories = [
                  ...allCategories.where((c) => c.title != 'Create New'),
                  ...allCategories.where((c) => c.title == 'Create New'),
                ];
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final category = sortedCategories[index];
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onLongPress: () {
                        deleteCategoryDialog(
                          context,
                          category.title,
                          () async {
                            // Safely pop the confirmation dialog
                            Navigator.pop(context);

                            // Show loading dialog
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => Center(
                                    child: LoadingIndicator(
                                  size: size,
                                )),
                              );
                            }

                            await provider.deleteCategory(
                                context, category, size);

                            // Close loading dialog if still mounted
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          size,
                        );
                      },
                      onTap: () async {
                        setState(() {
                          selectedCategory = category;
                        });
                        if (category.title == 'Create New') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateNewCategoryScreen(),
                            ),
                          );
                        }
                      },
                      child: CategoryItems(
                        size: size,
                        category: category,
                        isSelected: isSelected,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      )
    ],
    elevatedButtonSize: Size(size.width * 0.7, size.height * 0.06),
    elevatedButtonOnTap: () {
      if (selectedCategory == null || selectedCategory!.title == 'Create New') {
        Toast.errorToast(
          context,
          'Please select a category',
          color: Colors.grey.shade900,
          position: DelightSnackbarPosition.bottom,
        );
        return;
      }
      onSelect(selectedCategory!);
      context.read<TaskProvider>().setSelectedCategory(selectedCategory!);
      Navigator.pop(context);
    },
    text2: text2,
  );
}

logoutDialog(BuildContext context, {required Size size}) {
  showCustomDialog(
    size: size,
    context,
    isElevatedButtonNotCentered: true,
    title: 'Logout',
    items: [
      Column(
        children: [
          Lottie.asset(
            LottieManager.eyeLottie,
            height: size.width * 0.6, // 40% of dialog width
          ),
          const SizedBox(height: 16),
          Text(
            'Oh no! You\'re leaving...\nAre you sure?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: size.width * 0.07, // based on dialog width
                ),
          ),
        ],
      )
    ],
    elevatedButtonOnTap: () async {
      Navigator.of(context).pop();
      await context.read<AuthProvider>().logout(context);
    },
    textButtonOnTap: () {
      Navigator.of(context).pop();
    },
    text1: 'No',
    text2: 'Yes',
  );
}

Future<void> showCalender(
  BuildContext context,
  void Function(DateTime selectedDate) onDateSelected,
  void Function() onEditTime,
) async {
  DateTime? selectedDate;
  DateTime initialFocusedDay = selectedDate ?? DateTime.now();
  DateTime? selectedDay = selectedDate;
  DateTime focusedDay = initialFocusedDay;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  await showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive width/height for dialog
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final dialogWidth = screenWidth < 500 ? screenWidth * 0.95 : 400.0;
          final dialogHeight = screenHeight < 700 ? null : 520.0;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: dialogWidth,
                    minWidth: 280,
                    maxHeight: dialogHeight ?? double.infinity,
                  ),
                  child: Builder(
                    builder: (context) {
                      // cap the dialog to a percentage of screen height
                      final maxDialogHeight = screenHeight * 0.85 < 650.0
                          ? screenHeight * 0.85
                          : 650.0;

                      return SizedBox(
                        height: maxDialogHeight,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                /// Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: dialogWidth * 0.12,
                                      width: dialogWidth * 0.12,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            focusedDay = DateTime(
                                                focusedDay.year,
                                                focusedDay.month - 1);
                                          });
                                        },
                                        child: Image.asset(
                                          fit: BoxFit.contain,
                                          IconManager.arrowStart,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          DateFormat.yMMMM().format(focusedDay),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontSize: dialogWidth * 0.04,
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: dialogWidth * 0.12,
                                      width: dialogWidth * 0.12,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            focusedDay = DateTime(
                                                focusedDay.year,
                                                focusedDay.month + 1);
                                          });
                                        },
                                        child: Image.asset(
                                          fit: BoxFit.contain,
                                          IconManager.arrowEnd,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(),

                                // Calendar grows to available space and won't overflow
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, innerConstraints) {
                                      return SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight:
                                                innerConstraints.maxHeight,
                                          ),
                                          child: TableCalendar(
                                            firstDay: DateTime.utc(2000),
                                            lastDay: DateTime.utc(2100),
                                            focusedDay: focusedDay,
                                            selectedDayPredicate: (day) =>
                                                isSameDay(selectedDay, day),
                                            onDaySelected: (day, focus) {
                                              setModalState(() {
                                                selectedDay = day;
                                                focusedDay = focus;
                                              });
                                            },
                                            onPageChanged: (newFocusedDay) {
                                              setModalState(() {
                                                focusedDay = newFocusedDay;
                                              });
                                            },
                                            headerVisible: false,
                                            calendarStyle: CalendarStyle(
                                              todayDecoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        dialogWidth * 0.02),
                                              ),
                                              todayTextStyle: TextStyle(
                                                color: isDark
                                                    ? Colors.black
                                                    : Colors.black,
                                              ),
                                              selectedDecoration: BoxDecoration(
                                                color: const Color(0xff6F24E9),
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        dialogWidth * 0.02),
                                              ),
                                              selectedTextStyle:
                                                  const TextStyle(
                                                      color: Colors.white),
                                              defaultDecoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        dialogWidth * 0.02),
                                              ),
                                              weekendDecoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        dialogWidth * 0.02),
                                              ),
                                              outsideDecoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        dialogWidth * 0.02),
                                              ),
                                              defaultTextStyle:
                                                  Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                          color: isDark
                                                              ? Colors.white70
                                                              : Colors.black,
                                                          fontSize:
                                                              dialogWidth *
                                                                  0.045),
                                              weekendTextStyle: Theme.of(
                                                      context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      color: Colors.redAccent,
                                                      fontSize:
                                                          dialogWidth * 0.045),
                                            ),
                                            daysOfWeekStyle: DaysOfWeekStyle(
                                              weekdayStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      color: const Color(
                                                          0xff979797),
                                                      fontSize:
                                                          dialogWidth * 0.04),
                                              weekendStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      color: Colors.redAccent,
                                                      fontSize:
                                                          dialogWidth * 0.04),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(height: dialogWidth * 0.05),

                                /// Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontSize: dialogWidth * 0.04,
                                            ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (selectedDay != null) {
                                          onDateSelected(selectedDay!);
                                        }
                                        Navigator.pop(context);
                                        onEditTime();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff6F24E9),
                                        minimumSize:
                                            Size(dialogWidth * 0.5, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              dialogWidth * 0.01),
                                        ),
                                      ),
                                      child: Text(
                                        'Edit Time',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize: dialogWidth * 0.045,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

void showTimer(
  BuildContext context, {
  required void Function(TimeOfDay time) onTimeSelected,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  int hour = 7;
  int minute = 20;
  bool isAm = true;
  final hourController = FixedExtentScrollController(initialItem: hour - 1);
  final minuteController = FixedExtentScrollController(initialItem: minute);
  // ignore: dead_code
  final amPmController = FixedExtentScrollController(initialItem: isAm ? 0 : 1);
  showDialog(
    context: context,
    builder: (_) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final constrainWidth = screenWidth * 0.9;
          final constrainHeight = constraints.maxHeight;
          final textScale = MediaQuery.of(context).textScaleFactor;
          return AlertDialog(
            scrollable: true,
            backgroundColor:
                isDark ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            content: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constrainWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Time',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: constrainWidth * 0.04,
                          ),
                    ),
                    const Divider(),
                    SizedBox(
                      height: constrainHeight *
                          0.25, // Use constrainHeight for a better fit
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: _buildPickerWheel(
                              constrainHeight: constrainHeight,
                              context: context,
                              controller: hourController,
                              count: 12,
                              onSelected: (i) => hour = i + 1,
                              width: constrainWidth * 0.2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              ":",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: constrainWidth * 0.06 * textScale,
                                  ),
                            ),
                          ),
                          Flexible(
                            child: _buildPickerWheel(
                              constrainHeight: constrainHeight,
                              context: context,
                              controller: minuteController,
                              count: 60,
                              onSelected: (i) => minute = i,
                              width: constrainWidth * 0.2,
                            ),
                          ),
                          Flexible(
                            child: _buildPickerWheel(
                              constrainHeight: constrainHeight,
                              context: context,
                              controller: amPmController,
                              count: 2,
                              onSelected: (i) => isAm = i == 0,
                              labels: const ['AM', 'PM'],
                              width: constrainWidth * 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: constrainWidth * 0.04,
                      ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final finalHour = isAm ? (hour % 12) : (hour % 12) + 12;
                  final selected = TimeOfDay(hour: finalHour, minute: minute);
                  onTimeSelected(selected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6F24E9),
                  minimumSize:
                      Size(constrainWidth * 0.4, constrainHeight * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(constrainWidth * 0.01),
                  ),
                ),
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: constrainWidth * 0.04,
                      ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildPickerWheel(
    {required BuildContext context,
    required FixedExtentScrollController controller,
    required int count,
    required Function(int) onSelected,
    List<String>? labels,
    required double width,
    required double constrainHeight}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textScale = MediaQuery.of(context).textScaleFactor;
  return Container(
    width: width,
    height: constrainHeight * 0.2,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: isDark ? Colors.black26 : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40 * textScale.clamp(0.9, 1.2),
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelected,
      perspective: 0.005,
      diameterRatio: 1.2,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) {
          final text = labels != null
              ? labels[index]
              : (count == 12
                  ? (index + 1).toString().padLeft(2, '0')
                  : index.toString().padLeft(2, '0'));
          return Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: width * 0.2 * textScale,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          );
        },
      ),
    ),
  );
}

void taskErrorDialog(BuildContext context, String message, Size size) {
  showCustomDialog(
    size: size,
    context,
    title: 'Missing Information',
    elevatedButtonSize: Size(size.width * 0.5, size.height * 0.06),
    items: [
      LayoutBuilder(
        builder: (context, constraints) {
          final dialogWidth = constraints.maxWidth;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(LottieManager.eyeLottie,
                    height: dialogWidth * 0.6),
                SizedBox(height: size.height * 0.02),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: dialogWidth * 0.06,
                      ),
                ),
              ],
            ),
          );
        },
      )
    ],
    elevatedButtonOnTap: () => Navigator.pop(context),
    text2: "Okay",
    isElevatedButtonNotCentered: false,
  );
}

Future<void> monetizingDialog(BuildContext context, Size size) async {
  bool isLoading = false;

  try {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.warning);
    }
  } catch (e) {
    debugPrint("Haptic error: $e");
  }

  if (!context.mounted) return;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              Dialog(
                insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.05,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.9,
                    maxHeight: size.height * 0.85,
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.all(size.width * 0.04),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Title
                        Text(
                          'You\'re Out of Coin',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: size.width * 0.045),
                        ),
                        SizedBox(height: size.height * 0.015),

                        const Divider(thickness: 1),

                        SizedBox(height: size.height * 0.02),

                        /// Lottie
                        Lottie.asset(
                          LottieManager.coinLottie,
                          height: size.height * 0.3,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: size.height * 0.02),

                        /// Description
                        Text(
                          'Not enough coins! Watch ads or upgrade to premium',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontSize: size.width * 0.04),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: size.height * 0.03),

                        /// Watch Ad Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (kIsWeb) {
                                      // Friendly toast for web
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(); // Close dialog
                                      adsDialog(context, size);
                                    } else {
                                      setState(() => isLoading = true);
                                      final adService = AdService();
                                      adService.loadRewardAd(
                                        onLoaded: () {
                                          adService.showRewardAd(
                                            context: context,
                                            uid: context
                                                .read<UserProvider>()
                                                .user!
                                                .uid,
                                            userProvider:
                                                context.read<UserProvider>(),
                                          );
                                        },
                                        onError: (error) {
                                          setState(() => isLoading = false);
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                          Toast.errorToast(context,
                                              'We\'re having trouble loading ads right now. Please try again later.',
                                              color: Colors.grey.shade900,
                                              position: DelightSnackbarPosition
                                                  .bottom,
                                              leading: SizedBox(
                                                height: size.height * 0.06,
                                                width: size.width * 0.06,
                                                child: Image.asset(
                                                    fit: BoxFit.contain,
                                                    IconManager.warning),
                                              ));
                                        },
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6F24E9),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Watch Ad to earn 1 coin',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: size.width * 0.04,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        /// Upgrade Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // handle upgrade
                              Toast.errorToast(
                                context,
                                'Unlimited Task is coming soon! We\'re finalizing setup with Google Play. Stay tuned and thank you for your patience!',
                                color: Colors.grey.shade900,
                                position: DelightSnackbarPosition.bottom,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6F24E9),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Upgrade to premium (unlimited task)',
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: size.width * 0.04,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// FULLSCREEN loader
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: LoadingIndicator(
                        size: size,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

void showAddSubTaskDialog(
  BuildContext context,
  TaskModel tk,
  void Function(List<SubTaskModel> updated) subTaskState,
  TextEditingController dialogController,
  Size size,
) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  showCustomDialog(context,
      size: size,
      title: 'Create New Sub-Task',
      items: [
        SizedBox(
          width: size.width * 0.8,
          child: TextField(
            buildCounter: (context,
                    {required currentLength,
                    required isFocused,
                    required maxLength}) =>
                null,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            controller: dialogController,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: size.width * 0.04,
                ),
            enableSuggestions: true,
            autocorrect: true,
            cursorColor: isDarkMode ? Colors.white : Colors.black,
            decoration: InputDecoration(
              hintText: 'Enter sub-Task title',
              alignLabelWithHint: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: const Color(0xff6F24E9), width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: const Color(0xff6F24E9), width: 1)),
            ),
            maxLength: 30,
          ),
        )
      ],
      elevatedButtonOnTap: () async {
        Navigator.pop(context); // close the dialog

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Center(
                child: LoadingIndicator(
              size: MediaQuery.of(context).size,
            )),
          );
        }

        final provider = context.read<TaskProvider>();
        final title = dialogController.text.trim();

        if (title.isEmpty) {
          if (context.mounted) Navigator.pop(context); // close loading
          return;
        }

        final newSubTask = SubTaskModel(
          id: '',
          title: title,
          isCompleted: false,
        );

        final added = await provider.addSubTask(tk.taskId, newSubTask, context);

        if (added) {
          final updated = provider.getSubTasks(tk.taskId);
          subTaskState(updated);
        }

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true)
              .pop(); // close loading spinner
        }
        dialogController.clear();
      },
      text1: '  Cancel',
      text2: 'Add Sub-Task',
      textButtonOnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        dialogController.clear();
      });
}

deleteCategoryDialog(BuildContext context, String categoryTitle,
    final void Function() onPressed, Size size) {
  return showCustomDialog(
    size: size,
    context,
    title: 'Delete Category',
    items: [
      Text(
        textAlign: TextAlign.center,
        'Are You sure you want to delete this category?\n Category title: $categoryTitle',
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(fontSize: size.width * 0.06),
      ),
    ],
    text1: 'No',
    isElevatedButtonNotCentered: true,
    text2: 'Yes',
    elevatedButtonOnTap: onPressed,
    textButtonOnTap: () => context.pop(),
  );
}

aboutDoovaDialog(BuildContext context, Size size) {
  return showCustomDialog(
    size: size,
    context,
    title: 'About Doova',
    items: [
      Text(
        textAlign: TextAlign.center,
        'Doova is a productivity app designed to help you stay focused, manage tasks efficiently, and build healthier digital habits.\n\n'
        'We are currently improving the experience and preparing full documentation including our Terms of Service and Privacy Policy.\n\n'
        'Thank you for being an early user of Doova. Your feedback and support are helping shape a better experience for everyone.',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(height: 1.4, fontSize: size.width * 0.04),
      ),
    ],
    isElevatedButtonNotCentered: false,
    text2: 'Got it, thanks!',
    elevatedButtonOnTap: () {
      Navigator.pop(context);
    },
    elevatedButtonSize: Size(size.width * 0.7, size.height * 0.06),
  );
}

fAQDialog(BuildContext context, Size size) {
  return showCustomDialog(
    size: size,
    context,
    title: 'FAQ',
    items: [
      Text(
        textAlign: TextAlign.center,
        'Our FAQ section is currently being prepared to provide quick answers to common questions about using Doova.\n\n'
        'In the meantime, feel free to reach out to our support team if you have any questions or need help.\n\n'
        'We appreciate your patience as we continue improving the app.',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              height: 1.4,
              fontSize: size.width * 0.04,
            ),
      ),
    ],
    isElevatedButtonNotCentered: false,
    text2: 'Understood',
    elevatedButtonOnTap: () {
      Navigator.pop(context);
    },
    elevatedButtonSize: Size(size.width * 0.7, size.height * 0.06),
  );
}

adsDialog(BuildContext context, Size size) {
  return showCustomDialog(
    size: size,
    context,
    title: 'Coming Soon!',
    items: [
      Text(
        textAlign: TextAlign.center,
        'The full app is coming soon! For now, you can contact our support and they will help you out.',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              height: 1.4,
              fontSize: size.width * 0.04,
            ),
      ),
    ],
    isElevatedButtonNotCentered: false,
    text2: 'Got it, thanks!',
    elevatedButtonOnTap: () {
      Navigator.of(context, rootNavigator: false).pop();
    },
    elevatedButtonSize: Size(size.width * 0.7, size.height * 0.06),
  );
}

deleteTaskDialog(
    BuildContext context, final void Function() onPressed, Size size) {
  return showCustomDialog(
    size: size,
    context,
    title: 'Delete task',
    items: [
      Text(
        textAlign: TextAlign.center,
        'Are You sure you want to delete this Task?',
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(fontSize: size.width * 0.06),
      ),
    ],
    text1: 'No',
    isElevatedButtonNotCentered: true,
    text2: 'Yes',
    elevatedButtonOnTap: onPressed,
    textButtonOnTap: () => context.pop(),
  );
}

editTaskDialog(
  BuildContext context,
  TaskModel task,
  Size size,
  FocusNode titleFocus,
  FocusNode descriptionFocus,
  TextEditingController titleController,
  TextEditingController descriptionController, {
  required VoidCallback onSave,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  bool listenersAdded = false;
  bool dialogMounted = true;
  late void Function() titleListener;
  late void Function() descListener;

  showCustomDialog(context,
      size: size,
      isElevatedButtonNotCentered: true,
      title: 'Edit task details',
      items: [
        StatefulBuilder(
          builder: (context, setState) {
            if (!listenersAdded) {
              titleController.text = task.title;
              descriptionController.text = task.description;
              titleListener = () {
                if (dialogMounted && context.mounted) {
                  setState(() {});
                }
              };
              descListener = () {
                if (dialogMounted && context.mounted) {
                  setState(() {});
                }
              };

              titleFocus.addListener(titleListener);
              descriptionFocus.addListener(descListener);
              listenersAdded = true;
            }

            final titleHasFocus = titleFocus.hasFocus;
            final descHasFocus = descriptionFocus.hasFocus;
            return WillPopScope(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleHasFocus
                      ? TextField(
                          controller: titleController,
                          focusNode: titleFocus,
                          maxLines: 1,
                          maxLength: 30,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  required maxLength}) =>
                              null,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          cursorColor: const Color(0xff979797),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xff979797),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xff979797),
                                width: 1,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(titleFocus);
                          },
                          child: Text(
                            titleController.text.trim().isEmpty
                                ? 'New Task'
                                : titleController.text,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: const Color(0xff979797),
                                  fontSize: size.width * 0.04,
                                ),
                          ),
                        ),
                  const SizedBox(height: 15),
                  descHasFocus
                      ? TextField(
                          controller: descriptionController,
                          focusNode: descriptionFocus,
                          maxLines: 4,
                          minLines: 1,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: isDarkMode ? Colors.white : Colors.black,
                            height: 1.4,
                          ),
                          cursorColor: const Color(0xff979797),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xff979797),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xff979797),
                                width: 1,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(descriptionFocus);
                          },
                          child: Text(
                            descriptionController.text.trim().isEmpty
                                ? 'Description'
                                : descriptionController.text,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: const Color(0xff979797),
                                  fontSize: size.width * 0.04,
                                ),
                          ),
                        ),
                ],
              ),
              onWillPop: () async {
                dialogMounted = false;
                titleFocus.removeListener(titleListener);
                descriptionFocus.removeListener(descListener);
                return true;
              },
            );
          },
        ),
      ],
      elevatedButtonOnTap: () {
        onSave();
        dialogMounted = false;
        titleFocus.removeListener(titleListener);
        descriptionFocus.removeListener(descListener);
        Navigator.pop(context);
      },
      text1: 'Cancel',
      text2: 'Edit',
      textButtonOnTap: () {
        dialogMounted = false;
        titleFocus.removeListener(titleListener);
        descriptionFocus.removeListener(descListener);
        Navigator.pop(context);
      });

  // Auto focus after the dialog opens
  Future.delayed(const Duration(milliseconds: 100), () {
    if (context.mounted) {
      FocusScope.of(context).requestFocus(titleFocus);
    }
  });
}
