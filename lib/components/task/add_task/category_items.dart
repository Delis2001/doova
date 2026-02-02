import 'package:doova/model/add_task/category.dart';
import 'package:flutter/material.dart';

class CategoryItems extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final Size size;

  const CategoryItems({
    super.key,
    required this.category,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = size.width * 0.9;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final double containerWidth = screenWidth * 0.19;
    final double maxItemWidth = screenWidth * 0.23;

    return SizedBox(
      width: maxItemWidth,
      child: Column(
        children: [
          Container(
            height: size.height * 0.08,
            width: containerWidth,
            decoration: BoxDecoration(
              color: category.color ?? Colors.grey,
              borderRadius: BorderRadius.circular(size.width * 0.02),
              shape: BoxShape.rectangle,
              border: (isSelected &&
                      category.title.trim().toLowerCase() != 'create new')
                  ? Border.all(
                      color: isDarkMode ? Colors.white : Colors.black,
                      width: screenWidth*0.0050,
                    )
                  : null,
            ),
            child: Center(
              child: category.image != null
                  ? SizedBox(
                    height: size.height*0.07,
                    width: screenWidth*0.07,
                    child: Image.asset(category.image!,fit: BoxFit.contain,))
                  : Icon(
                      category.icon ?? Icons.error,
                      size:screenWidth*0.07,
                    ),
            ),
          ),
          SizedBox(height: size.height * 0.004),
          Text(
            category.title[0].toUpperCase() +
                category.title.substring(1).toLowerCase(),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: screenWidth*0.04),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
