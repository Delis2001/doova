import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/components/indicator.dart';
import 'package:doova/components/task/edit_task/edit_task_items.dart';
import 'package:doova/components/task/edit_task/task_description_view.dart';
import 'package:doova/model/add_task/category.dart';
import 'package:doova/model/add_task/sub_task.dart';
import 'package:doova/model/add_task/task.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/dialog_helper.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EditTaskView extends StatefulWidget {
  EditTaskView({
    super.key,
    required this.task,
    this.editedCategory,
    this.editedDate,
    this.editedPriority,
    this.editedTime,
  });

  final List<TaskModel> task;
  CategoryModel? editedCategory;
  int? editedPriority;
  String? editedDate;
  TimeOfDay? editedTime;

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final TextEditingController dialogController = TextEditingController();
  late TaskModel tk;
  late TaskProvider provider;
  int _currentStep = 0;
  List<SubTaskModel> _subTasks = [];

  int maxLines = 4;

  @override
  void initState() {
    super.initState();
    tk = widget.task.first;
    widget.editedCategory = tk.category;
    widget.editedPriority = tk.priority;
    widget.editedDate = tk.date;

    widget.editedTime = context.read<TaskProvider>().parseTime(tk.time);
    _titleFocus.addListener(_onFocusChange);
    _descriptionFocus.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.fetchSubTasks(tk.taskId);
      if (!mounted) return;
      setState(() {
        _subTasks = taskProvider.getSubTasks(tk.taskId);
        _clampCurrentStep();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = context.read<TaskProvider>();
  }

  @override
  void dispose() {
    _titleFocus.removeListener(_onFocusChange);
    _descriptionFocus.removeListener(_onFocusChange);
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    dialogController.dispose();
    provider.clearControllers(tk.taskId);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _clampCurrentStep() {
    if (_subTasks.isEmpty) {
      _currentStep = 0;
    } else if (_currentStep >= _subTasks.length) {
      _currentStep = _subTasks.length - 1;
    }
  }

  String get formattedSelectedEditTime {
    if (widget.editedTime == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, widget.editedTime!.hour,
        widget.editedTime!.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<TaskProvider>().isLoading;
    final titleController = provider.getTitleController(tk.taskId, tk.title);
    final descriptionController =
        provider.getDescriptionController(tk.taskId, tk.description);
    final currentCategory = widget.editedCategory ?? tk.category;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(children: [
          SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                toolbarHeight: size.width > 600
                    ? topPadding + size.height * 0.08
                    : kToolbarHeight,
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                automaticallyImplyLeading: false,
                actions: [
                  SizedBox(width: size.width * 0.02),
                  buildButton(
                      size: size,
                      image: IconManager.cancel,
                      onPressed: () => Navigator.pop(context)),
                  const Spacer(),
                  buildButton(
                    size: size,
                    image: IconManager.repeat,
                    onPressed: () async {
                      if (tk.isCompleted) {
                        Toast.errorToast(
                          context,
                          'Restore this task first before toggling repeat.',
                          color: Colors.grey.shade900,
                          position: DelightSnackbarPosition.bottom,
                          leading: SizedBox(
                            height: size.height * 0.06,
                            width: size.width * 0.06,
                            child: Image.asset(
                              fit: BoxFit.contain,
                              IconManager.warning,
                            ),
                          ),
                        );
                        return;
                      }

                      final newRepeatState = !tk.isRepeating;

                      final success = await context
                          .read<TaskProvider>()
                          .toggleRepeat(tk.taskId, newRepeatState, context);

                      if (!success || !mounted) return;

                      setState(() {
                        tk = tk.copyWith(isRepeating: newRepeatState);
                      });
                    },
                    isActive: tk.isRepeating,
                  ),
                  SizedBox(width: size.width * 0.02),
                ],
              ),
              body: Container(
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: size.height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          !tk.isCompleted
                              ? Container(
                                  width: size.width * 0.05,
                                  height: size.height * 0.05,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                )
                              : Container(
                                  width: size.width * 0.06,
                                  height: size.height * 0.06,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tk.isCompleted
                                        ? Colors.green
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  child: tk.isCompleted
                                      ? Icon(Icons.check,
                                          color: Colors.white,
                                          size: size.width * 0.03)
                                      : null,
                                ),
                          Text(
                            titleController.text.trim().isEmpty
                                ? tk.title
                                : titleController.text.trim(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: size.width * 0.05),
                          ),
                          !tk.isCompleted
                              ? GestureDetector(
                                  onTap: () {
                                    final tempTitleController =
                                        TextEditingController(
                                            text: titleController.text);
                                    final tempDescController =
                                        TextEditingController(
                                            text: descriptionController.text);
                                    editTaskDialog(
                                      context,
                                      tk,
                                      size,
                                      _titleFocus,
                                      _descriptionFocus,
                                      tempTitleController,
                                      tempDescController,
                                      onSave: () {
                                        titleController.text =
                                            tempTitleController.text.trim();
                                        descriptionController.text =
                                            tempDescController.text.trim();
                                      },
                                    );
                                  },
                                  child: SizedBox(
                                    width: size.width * 0.06,
                                    height: size.height * 0.06,
                                    child: Image.asset(
                                      fit: BoxFit.contain,
                                      IconManager.edit,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: size.width * 0.07,
                                ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            final isOverflowing = isDescriptionOverflown(
                              text: descriptionController.text.trim().isEmpty
                                  ? tk.description
                                  : descriptionController.text.trim(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontSize: size.width * 0.045),
                              maxWidth: size.width * 0.9,
                              maxLines: maxLines,
                            );

                            if (isOverflowing) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDescriptionView(
                                    description: descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? tk.description
                                        : descriptionController.text.trim(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              descriptionController.text.trim().isEmpty
                                  ? tk.description
                                  : descriptionController.text.trim(),
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      height: 1.4, fontSize: size.width * 0.04),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      buildListile(
                          size: size,
                          onPressed: !tk.isCompleted
                              ? () {
                                  showCalender(
                                    context,
                                    (pickedDate) {
                                      setState(() {
                                        widget.editedDate =
                                            DateFormat('EEE, MMM d, y')
                                                .format(pickedDate);
                                      });
                                    },
                                    () {
                                      showTimer(
                                        context,
                                        onTimeSelected: (pickedTime) {
                                          setState(() {
                                            widget.editedTime = pickedTime;
                                          });
                                        },
                                      );
                                    },
                                  );
                                }
                              : null,
                          icon: IconManager.timer,
                          title: 'Task Time :',
                          text: provider.formatEditTaskDateTime(
                            dateString: widget.editedDate ?? tk.date,
                            timeString: formattedSelectedEditTime.isNotEmpty
                                ? formattedSelectedEditTime
                                : tk.time,
                          )),
                      buildListile(
                        size: size,
                        onPressed: !tk.isCompleted
                            ? () {
                                categoryDialog(
                                  context,
                                  size,
                                  'Edit Category',
                                  (selectedCategory) {
                                    setState(() {
                                      widget.editedCategory = selectedCategory;
                                    });
                                  },
                                );
                              }
                            : null,
                        icon: IconManager.tags,
                        title: 'Task Category :',
                        isText: false,
                        isTextWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            currentCategory.image != null
                                ? Image.asset(
                                    widget.editedCategory?.image ??
                                        tk.category.image!,
                                    height: size.height * 0.06,
                                    width: size.width * 0.06,
                                  )
                                : Icon(
                                    widget.editedCategory?.icon ??
                                        tk.category.icon,
                                    size: size.width * 0.06,
                                  ),
                            SizedBox(width: size.width * 0.03),
                            Flexible(
                              child: Text(
                                widget.editedCategory?.title ??
                                    tk.category.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontSize: size.width * 0.04,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildListile(
                        size: size,
                        onPressed: !tk.isCompleted
                            ? () {
                                priorityDialog(context, 'Edit Priority', 'Edit',
                                    (selectedPriority) {
                                  setState(() {
                                    widget.editedPriority = selectedPriority;
                                  });
                                }, size);
                              }
                            : null,
                        icon: IconManager.flag,
                        title: 'Task Priority :',
                        isText: false,
                        isTextWidget: SizedBox(
                          width: size.width * 0.15,
                          height: size.height * 0.03,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${widget.editedPriority ?? tk.priority}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontSize: size.width * 0.04),
                            ),
                          ),
                        ),
                      ),
                      // This ListTile opens the Add Subtask Dialog
                      if (!tk.isCompleted)
                        buildListile(
                          size: size,
                          onPressed: () {
                            showAddSubTaskDialog(context, tk, (updated) {
                              setState(() {
                                _subTasks = updated;
                                _clampCurrentStep();
                              });
                            }, dialogController, size);
                          },
                          icon: IconManager.hierarchy,
                          title: 'Sub - Task',
                          text: 'Add Sub - Task',
                        ),

                      // Show subtasks stepper
                      if (!tk.isCompleted && _subTasks.isNotEmpty) ...[
                        buildSubTaskStepper(size),
                      ],

                      buildListile(
                        size: size,
                        deleteOnPressed: () {
                          deleteTaskDialog(
                            context,
                            () async {
                              final taskProvider = context.read<TaskProvider>();
                              taskProvider.setLoading(true); // start loading

                              Navigator.pop(context); // close confirm dialog

                              await taskProvider.deleteTask(
                                context: context,
                                taskId: tk.taskId,
                              );

                              taskProvider.setLoading(false); // stop loading
                            },
                            size,
                          );
                        },
                        icon: IconManager.trash,
                        title: 'Delete Task',
                        isDelete: true,
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: editTaskButton(context, size),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                  child: LoadingIndicator(
                size: size,
              )),
            ),
        ]);
      },
    );
  }

  Widget editTaskButton(BuildContext context, Size size) {
    final titleController = provider.getTitleController(tk.taskId, tk.title);
    final descriptionController =
        provider.getDescriptionController(tk.taskId, tk.description);
    final formattedTime = formattedSelectedEditTime.isNotEmpty
        ? formattedSelectedEditTime
        : tk.time;
    final formattedDate = widget.editedDate ?? tk.date;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.02),
      child: SizedBox(
        width: double.infinity,
        height: size.height * 0.06,
        child: ElevatedButton(
          onPressed: () async {
            if (tk.isCompleted) {
              // If restoring, push date forward
              final now = DateTime.now();
              final pushedDate = now.add(const Duration(days: 1));
              final newDate = DateFormat('EEE, MMM d, y').format(pushedDate);

              await context.read<TaskProvider>().updateTask(
                    context: context,
                    taskId: tk.taskId,
                    title: titleController.text.trim().isEmpty
                        ? tk.title
                        : titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? tk.description
                        : descriptionController.text.trim(),
                    priority: widget.editedPriority ?? tk.priority,
                    category: widget.editedCategory ?? tk.category,
                    time: formattedTime,
                    date: newDate,
                  );
            } else {
              // Normal edit
              await context.read<TaskProvider>().updateTask(
                    context: context,
                    taskId: tk.taskId,
                    title: titleController.text.trim().isEmpty
                        ? tk.title
                        : titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? tk.description
                        : descriptionController.text.trim(),
                    priority: widget.editedPriority ?? tk.priority,
                    category: widget.editedCategory ?? tk.category,
                    time: formattedTime,
                    date: formattedDate,
                  );
            }
          },
          child: Text(
            !tk.isCompleted ? 'Edit Task' : 'Restore Task',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: size.width * 0.04,
                ),
          ),
        ),
      ),
    );
  }

  Widget buildButton({
    required String image,
    final void Function()? onPressed,
    bool isActive = false,
    required Size size,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size.height * 0.05,
        width: size.width * 0.09,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green // or any color for active repeat
              : isDarkMode
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xffE5E5E5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: SizedBox(
          width: size.width * 0.05,
          height: size.height * 0.05,
          child: Image.asset(
            fit: BoxFit.contain,
            image,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildListile({
    required String icon,
    required String title,
    void Function()? onPressed,
    void Function()? deleteOnPressed,
    Widget? isTextWidget,
    String? text,
    bool isDelete = false,
    bool isText = true,
    required Size size,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return EditTaskItem(
      size: size,
      deleteOnPressed: deleteOnPressed,
      icon: icon,
      title: title,
      onTap: onPressed ?? () {},
      isDarkMode: isDarkMode,
      isTextWidget: isTextWidget,
      text: text,
      isDelete: isDelete,
      isText: isText,
    );
  }

  bool isDescriptionOverflown({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: Directionality.of(context),
    );
    tp.layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }

  Widget buildSubTaskStepper(Size size) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // const circleColor = Color(0xff6F24E9);
    return Stepper(
      connectorColor: WidgetStatePropertyAll(
        Color(0xff6F24E9),
      ),
      key: ValueKey(_subTasks.length), // ✅ Fixes length mismatch crash
      physics: const ClampingScrollPhysics(),
      currentStep: _currentStep,
      onStepTapped: (index) {
        setState(() => _currentStep = index);
      },
      controlsBuilder: (context, details) {
        return const SizedBox.shrink(); // removes Continue/Cancel
      },
      steps: _subTasks.asMap().entries.map((entry) {
        final idx = entry.key;
        final subTask = entry.value;

        return Step(
          title: Text(
            subTask.title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: size.width * 0.04,
                ),
          ),
          content: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final updated =
                      subTask.copyWith(isCompleted: !subTask.isCompleted);
                  final success =
                      await provider.updateSubTask(tk.taskId, updated, context);
                  if (success) {
                    setState(() {
                      _subTasks[idx] = updated;
                    });
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.05,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        subTask.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  child: subTask.isCompleted
                      ? Icon(Icons.check,
                          color: Colors.white, size: size.width * 0.03)
                      : null,
                ),
              ),
              SizedBox(
                width: size.width * 0.03,
              ),
              GestureDetector(
                key: ValueKey('delete_${subTask.id}'),
                onTap: () async {
                  final success = await provider.deleteSubTask(
                      tk.taskId, subTask.id, context);
                  if (success) {
                    setState(() {
                      _subTasks.removeAt(idx);
                      if (_currentStep > 0) _currentStep--;
                    });
                  }
                },
                child: SizedBox(
                    width: size.width * 0.06,
                    height: size.height * 0.06,
                    child: Image.asset(fit: BoxFit.contain, IconManager.trash)),
              )
            ],
          ),
          isActive: _currentStep == idx,
        );
      }).toList(),
    );
  }
}
