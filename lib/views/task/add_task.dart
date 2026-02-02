import 'package:doova/components/indicator.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/dialog_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  bool editingTitle = true;
  bool editingDescription = false;
  late UserProvider userProvider;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUser(uid);
    _titleFocus.requestFocus();
    _titleFocus.addListener(
      () {
        setState(() {
          editingTitle = _titleFocus.hasFocus;
        });
      },
    );
    _descriptionFocus.addListener(
      () {
        setState(() {
          editingDescription = _descriptionFocus.hasFocus;
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    // isTextFieldEmpty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    var keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              color: isDarkMode
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xffE5E5E5),
            ),
            child: SizedBox(
              width: double.infinity,
              height: size.height * 0.76,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardSpace),
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.025),
                        Text('Add Task',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: size.width * 0.06,
                                )),
                        SizedBox(height: size.height * 0.010),
                        titleTextField(context, _titleController, size,
                            _titleFocus, editingTitle),
                        SizedBox(height: size.height * 0.020),
                        descriptionTextField(
                            context,
                            size,
                            _descriptionController,
                            _descriptionFocus,
                            editingDescription),
                        SizedBox(height: size.height * 0.025),
                        Row(
                          children: [
                            icons(
                              size: size,
                              context: context,
                              image: IconManager.timer,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                showCalender(
                                  context,
                                  (pickedDate) {
                                    context
                                        .read<TaskProvider>()
                                        .getSelectedDate(pickedDate);
                                  },
                                  () {
                                    showTimer(
                                      context,
                                      onTimeSelected: (pickedTime) {
                                        context
                                            .read<TaskProvider>()
                                            .getSelectedTime(pickedTime);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(width: size.width * 0.025),
                            icons(
                                size: size,
                                context: context,
                                image: IconManager.tags,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  categoryDialog(
                                    context,
                                    size,
                                    'Add Category',
                                    (selectedCategory) {},
                                  );
                                }),
                            SizedBox(width: size.width * 0.025),
                            icons(
                                size: size,
                                context: context,
                                image: IconManager.flag,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  priorityDialog(context, 'Task Priority',
                                      'Save', (selectedPriority) {}, size);
                                }),
                            const Spacer(),
                            // ValueListenableBuilder<bool>(
                            //   valueListenable: isTextFieldEmpty,
                            //   builder: (context, value, child) { return
                            SizedBox(
                              height: size.height * 0.10,
                              child:
                                  //  value ? Center(child: textButton(context)):
                                  GestureDetector(
                                onTap: () => createTask(size: size),
                                child: SizedBox(
                                  height: size.height * 0.08,
                                  width: size.width * 0.08,
                                  child: Image.asset(
                                    fit: BoxFit.contain,
                                    'assets/icon/send.png',
                                    color: const Color(0xff6F24E9),
                                  ),
                                ),
                              ),
                            )
                            //   },
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  createTask({required Size size}) async {
    final taskProvider = context.read<TaskProvider>();
    final categories = taskProvider.selectedCategory;
    final selectedDate = taskProvider.selectedDate;
    final selectedPriority = taskProvider.selectedPriority;
    final selectedTime = taskProvider.formattedSelectedTime;
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    if (selectedDate == null ||
        selectedTime.isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      taskErrorDialog(
          context,
          'Please enter a description and select a date and time before saving',
          size);
      return;
    }
    // Check coin balance for non-premium users
    if (!user.isPremium && user.coins <= 0) {
      monetizingDialog(context, size);
      return;
    }
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
    await taskProvider.createTask(
        context: context,
        title: _titleController.text.trim().isEmpty
            ? 'New Task'
            : _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: selectedPriority ?? taskProvider.priorityFallback[0].number,
        category: categories ?? taskProvider.categoryFallback[0],
        time: selectedTime,
        date: selectedDate,
        userProvider: userProvider);
    if (!mounted) return;
    Navigator.of(context).pop(); // pop the loading dialog
  }
}

textButton(BuildContext context) {
  return TextButton(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
    ),
    onPressed: () {
      context.pop();
    },
    child: const Text(
      'Cancel',
      style: TextStyle(
        color: Color(0xff6F24E9),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );
}

icons(
    {required BuildContext context,
    required String image,
    required final void Function() onTap,
    required Size size}) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return GestureDetector(
      onTap: onTap,
      child: SizedBox(
          height: size.height * 0.06,
          width: size.width * 0.06,
          child: Image.asset(
            fit: BoxFit.contain,
            image,
            color: isDarkMode ? Colors.white : Colors.black,
          )));
}

titleTextField(BuildContext context, TextEditingController titleController,
    Size size, FocusNode titleFocus, bool editingTitle) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  // final textFieldHeight = (size.height * 0.07).clamp(50.0, 70.0);

  if (editingTitle) {
    return TextField(
      controller: titleController,
      focusNode: titleFocus,
      maxLines: 1,
      maxLength: 30,
      buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
      textCapitalization: TextCapitalization.sentences,
      autofocus: true,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontSize: size.width * 0.04),
      enableSuggestions: true,
      autocorrect: true,
      cursorColor: isDarkMode ? Colors.white : Colors.black,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.02),
            borderSide: BorderSide(
                color: const Color(0xff6F24E9), width: size.width * 0.0030)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.02),
            borderSide: BorderSide(
                color: const Color(0xff6F24E9), width: size.width * 0.0030)),
      ),
    );
  } else {
    final display =
        titleController.text.trim().isEmpty ? 'New Task' : titleController.text;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(titleFocus);
      },
      child: Text(
        display,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Color(0xff979797), fontSize: size.width * 0.04),
      ),
    );
  }
}

descriptionTextField(
    BuildContext context,
    Size size,
    TextEditingController descriptionController,
    FocusNode descriptionFocus,
    bool editingDescription) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  // final textFieldHeight = (size.height * 0.07).clamp(50.0, 70.0);

  if (editingDescription) {
    return TextField(
      focusNode: descriptionFocus,
      buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      controller: descriptionController,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(height: 1.4, fontSize: size.width * 0.04),
      enableSuggestions: true,
      autocorrect: true,
      cursorColor: isDarkMode ? Colors.white : Colors.black,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.02),
            borderSide: BorderSide(
                color: const Color(0xff6F24E9), width: size.width * 0.0030)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.02),
            borderSide: BorderSide(
                color: const Color(0xff6F24E9), width: size.width * 0.0030)),
      ),
      maxLines: 4,
    );
  } else {
    final display = descriptionController.text.trim().isEmpty
        ? 'Description'
        : descriptionController.text;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(descriptionFocus);
      },
      child: Text(
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        display,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Color(0xff979797), fontSize: size.width * 0.04),
      ),
    );
  }
}
