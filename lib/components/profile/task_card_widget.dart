import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String label;
  final bool isDarkMode;
  final Size size;

  const TaskCard({
    super.key,
    required this.label,
    required this.isDarkMode,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.08,
      width: size.width * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.01),
        color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!
                        .copyWith(fontSize: size.width * 0.04),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title,required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    final screenWidth = size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontSize: screenWidth * 0.040),
      ),
    );
  }
}
