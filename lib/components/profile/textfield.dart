import 'package:flutter/material.dart';

class ProfileScreenCustomTextField extends StatelessWidget {
  const ProfileScreenCustomTextField({
    super.key,
    this.hintText,
    this.obscureText,
    this.suffixIcon,
    required this.validator,
    required this.onSaved,
    required this.controller,
  });

  final String? hintText;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: fieldWidth,
            child: TextFormField(
              obscureText: obscureText ?? false,
              validator: validator,
              onSaved: onSaved,
              controller: controller,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: constraints.maxWidth*0.04),
              cursorColor: isDarkMode ? Colors.white : Colors.black,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(fieldWidth * 0.02),
                  borderSide:  BorderSide(color: Color(0xff979797), width: constraints.maxWidth * 0.0030),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(fieldWidth * 0.02),
                  borderSide:  BorderSide(color: Color(0xff6F24E9), width: constraints.maxWidth * 0.0030),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(fieldWidth * 0.02),
                  borderSide:  BorderSide(color: Color(0xff979797), width: constraints.maxWidth * 0.0030),
                ),
                hintText: hintText,
                suffixIcon: suffixIcon,
                hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: constraints.maxWidth*0.04),
              ),
            ),
          ),
        );
      },
    );
  }
}
