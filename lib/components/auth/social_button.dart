import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton(
      {super.key,
      this.icon,
      required this.text,
      required this.isIcon,
      this.icons,
      required this.onPressed,
      required this.size});
  final String? icon;
  final IconData? icons;
  final String text;
  final bool isIcon;
  final void Function() onPressed;
  final Size size;

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.icon(
        onPressed: onPressed,
        label: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: size.width * 0.045),
        ),
        icon: isIcon
            ? Icon(
                icons,
                color: isDarkMode ? Colors.white : Colors.black,
                size: size.width * 0.068,
              )
            : SizedBox(
                height: size.height * 0.05,
                width: size.width * 0.05,
                child: Image.asset(
                  fit: BoxFit.contain,
                  icon!,
                ),
              ),
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
            shape: WidgetStatePropertyAll(OutlinedBorder.lerp(
                BeveledRectangleBorder(
                    side: BorderSide(
                        color: Color(0xff6F24E9), width: size.width * 0.0030)),
                BeveledRectangleBorder(
                    side: BorderSide(
                        color: Color(0xff6F24E9), width: size.width * 0.0030)),
                BorderSide.strokeAlignOutside)),
            backgroundColor: WidgetStatePropertyAll(
                isDarkMode ? Colors.black : Colors.white),
            minimumSize: WidgetStatePropertyAll(
                Size(size.width * 0.90, size.height * 0.06))));
  }
}
