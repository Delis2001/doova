import 'package:doova/model/add_task/task.dart';
import 'package:doova/r.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TaskItems extends StatelessWidget {
  const TaskItems({super.key, required this.task, required this.selectedTask, required this.size});
  final TaskModel task;
  final void Function(TaskModel task) selectedTask;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        selectedTask(task);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2C2C2E) : Color(0xffE5E5E5),
          borderRadius: BorderRadius.circular(screenWidth * 0.01),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    runSpacing: screenHeight * 0.008,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        children: [
                          // Time
                          Text(
                            task.formattedTime,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: screenWidth * 0.032),
                          ),

                          // Space between
                          SizedBox(width: screenWidth * 0.03),
                          // Category
                          Expanded(
                            flex: 5,
                            child: _buildInfoBox(
                              size: size,
                              context,
                              color: task.category.color,
                              icon: task.category.image != null
                                  ? Image.asset(
                                      task.category.image!,
                                      width: screenWidth * 0.030,
                                      height: screenWidth * 0.030,
                                    )
                                  : Icon(
                                      task.category.icon,
                                      size: screenWidth * 0.030,
                                    ),
                              label: task.category.title,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          // Space between
                          SizedBox(width: screenWidth * 0.02),

                          // Priority
                          Expanded(
                            flex: 3,
                            child: _buildInfoBox(
                              size: size,
                              context,
                              borderColor: const Color(0xff6F24E9),
                              icon: SizedBox(
                                width: screenHeight * 0.025,
                                height: screenHeight * 0.025,
                                child: Image.asset(
                                  IconManager.flag,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              label: task.priority.toString(),
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(
    BuildContext context, {
    Color? color,
    Color? borderColor,
    required Widget icon,
    required String label,
    required bool isDarkMode,
    required Size size,
  }) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        color: color,
        border: borderColor != null ? Border.all(color: borderColor) : null,
        borderRadius: BorderRadius.circular(screenWidth * 0.015),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: screenWidth * 0.01),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: screenWidth*0.03)),
          ),
        ],
      ),
    );
  }
}

Widget buildShimmerTask(
  double screenWidth,
  double screenHeight,
  bool isDarkMode,
) {
  final baseCardColor =
      isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5);
  final shimmerBase = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
  final shimmerHighlight =
      isDarkMode ? Colors.grey.shade600 : Colors.grey.shade100;

  return Container(
    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      color: baseCardColor,
      borderRadius: BorderRadius.circular(screenWidth * 0.02),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox circle
        Shimmer.fromColors(
          baseColor: shimmerBase,
          highlightColor: shimmerHighlight,
          child: Container(
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),

        // Right content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              Shimmer.fromColors(
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
                child: Container(
                  height: screenHeight * 0.022,
                  width: screenWidth * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),

              // Row for time, category, priority
              Wrap(
                spacing: screenWidth * 0.025,
                runSpacing: screenHeight * 0.01,
                children: [
                  // Time shimmer
                  Shimmer.fromColors(
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                    child: Container(
                      height: screenHeight * 0.02,
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  // Category shimmer
                  Shimmer.fromColors(
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                    child: Container(
                      height: screenHeight * 0.035,
                      width: screenWidth * 0.28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Priority shimmer
                  Shimmer.fromColors(
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                    child: Container(
                      height: screenHeight * 0.035,
                      width: screenWidth * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CompletedTaskItems extends StatelessWidget {
  final TaskModel completedTask;
  final Size size;
  final void Function(TaskModel completedTask) selectedCompletedTask;

  const CompletedTaskItems({
    super.key,
    required this.completedTask,
    required this.selectedCompletedTask,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return GestureDetector(
      onTap: () {
        selectedCompletedTask(completedTask);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
          borderRadius: BorderRadius.circular(screenWidth * 0.01),
        ),
        child: Row(
          children: [
            Container(
                  width:size.width * 0.05,
                  height:size.height * 0.05,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        completedTask.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  child: completedTask.isCompleted
                      ? Icon(Icons.check,
                          color: Colors.white, size: screenWidth * 0.03)
                      : null,
                ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completedTask.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      decorationColor:  isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    children: [
                      Text(
                        completedTask.formattedTime,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: screenWidth * 0.032),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
