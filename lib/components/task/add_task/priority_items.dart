import 'package:doova/model/add_task/priority.dart';
import 'package:flutter/material.dart';

class PriorityItems extends StatelessWidget {
  const PriorityItems({
    super.key,
    required this.priority,
    required this.isSelectedPriority,
    required this.onTap,
  });

  final PriorityModel priority;
  final bool isSelectedPriority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth; // This is the actual cell width.
        final itemHeight = constraints.maxHeight;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelectedPriority
                  ? const Color(0xff6F24E9)
                  : isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(itemWidth * 0.05),
              border: Border.all(
                color: isSelectedPriority
                    ? const Color(0xff6F24E9)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: itemHeight * 0.4,
                  width: itemWidth * 0.4,
                  child: Image.asset(
                    priority.image,
                    fit: BoxFit.contain,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: itemHeight * 0.05),
                Text(
                  priority.number.toString(),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: itemHeight * 0.2,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
