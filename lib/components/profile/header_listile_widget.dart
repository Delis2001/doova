import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.size});
  final String title;
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
