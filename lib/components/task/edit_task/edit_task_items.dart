import 'package:flutter/material.dart';

class EditTaskItem extends StatelessWidget {
  const EditTaskItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDarkMode,
    this.deleteOnPressed,
    this.text,
    this.isTextWidget,
    this.isText = true,
    this.isDelete = false,
    required this.size,
  });

  final String icon;
  final String title;
  final bool isDarkMode;
  final Widget? isTextWidget;
  final bool isText;
  final String? text;
  final bool isDelete;
  final void Function() onTap;
  final void Function()? deleteOnPressed;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: isDelete ? deleteOnPressed : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.005,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            SizedBox(
              width: size.width*0.06,
              height: size.height*0.06,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  icon,
                  color: isDelete
                      ? Colors.red
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),

            SizedBox(width: size.width * 0.04),

            // Title
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDelete ? Colors.red : null,
                  fontSize: size.width * 0.04,
                ),
              ),
            ),

            // Value or trailing widget
            if (!isDelete)
              Container(
                constraints: BoxConstraints(
                  minWidth: size.width * 0.2,
                  maxWidth: size.width * 0.6,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xffE5E5E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isText
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: size.width * 0.5,
                        ),
                        child: isTextWidget,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
