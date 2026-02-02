import 'package:flutter/material.dart';

class PasswordTextfield extends StatelessWidget {
  const PasswordTextfield(
      {super.key,
      required this.controller,
      required this.size,
      required this.onSaved,
      required this.validator,
      required this.obscureText,
      required this.suffixIcon});
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final TextEditingController controller;
  final bool obscureText;
  final Widget suffixIcon;
  final Size size;

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
        validator: validator,
        onSaved: onSaved,
        controller: controller,
        obscureText: obscureText,
        style: Theme.of(context)
            .textTheme
            .titleMedium!.copyWith(fontSize: size.width * 0.04), // This controls typing color
        cursorColor: isDarkMode ? Colors.white : Colors.black,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: BorderSide(
                    color: Color(0xFF2C2C2E), width: size.width * 0.0030)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: BorderSide(
                    color: Color(0xff6F24E9), width: size.width * 0.0030)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: BorderSide(
                    color: Color(0xFF2C2C2E), width: size.width * 0.0030)),
            hintText: '************',
            suffixIcon: suffixIcon,
            hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: size.width * 0.04))); // This controls hint color
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField(
      {super.key,
      required this.validator,
      required this.onSaved,
      required this.controller,
      required this.hintText,
      required this.size,
      this.textCapitalization});
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final TextEditingController controller;
  final String hintText;
  final TextCapitalization? textCapitalization;
  final Size size;

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: validator,
        textCapitalization: textCapitalization!,
        onSaved: onSaved,
        controller: controller,
        style: Theme.of(context)
            .textTheme
            .titleMedium!.copyWith(fontSize: size.width * 0.04), // This controls typing color
        cursorColor: isDarkMode ? Colors.white : Colors.black,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: BorderSide(
                    color: Color(0xFF2C2C2E), width: size.width * 0.0030)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: BorderSide(
                    color: Color(0xff6F24E9), width: size.width * 0.0030)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.02),
                borderSide: BorderSide(
                    color: Color(0xFF2C2C2E), width: size.width * 0.0030)),
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: size.width * 0.04))); // This controls hint color
  }
}
