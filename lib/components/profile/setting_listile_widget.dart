import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDarkMode,
    this.isLogout = false,
    this.isEmailIcon = false,
    required this.size
  });
  final String icon;
  final String title;
  final bool isDarkMode;
  final bool isLogout;
  final bool isEmailIcon;
  final void Function() onTap;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.001),
      leading: SizedBox(
        height: size.height * 0.06,
        width: size.width * 0.06,
        child: Image.asset(
          fit: BoxFit.contain,
          icon,
          color: isLogout
              ? Colors.red
              : (isEmailIcon
                  ? (isDarkMode
                      ? Color.fromARGB(255, 173, 171, 171)
                      : const Color.fromARGB(255, 70, 70, 73))
                  : (isDarkMode ? Colors.white : Colors.black)),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: isLogout ? Colors.red : null,fontSize: size.width*0.04
            ),
      ),
      trailing: isLogout
          ? null
          : Icon(Icons.arrow_forward_ios_rounded,
              color: isDarkMode ? Colors.white : Colors.black,size: size.width*0.04,),
    );
  }
}
