import 'package:doova/provider/auth/auth_provider.dart';
import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/views/home/calendar.dart';
import 'package:doova/views/home/focus.dart';
import 'package:doova/views/home/index.dart';
import 'package:doova/views/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;
  List screens = [
    IndexScreen(),
    CalendarScreen(),
    FocusModeScreen(),
    ProfileScreen(),
  ];
  @override
  void initState() {
    context.read<AuthProvider>().setUerData();
    context.read<ImageProviderNotifier>().initializeProfileImages();
    super.initState();
  }

  onSelectedIndex(int value) {
    setState(() {
      index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavigationBar(
              backgroundColor:
                  isDarkMode ? Color(0xFF2C2C2E) : Color(0xffE5E5E5),
              type: BottomNavigationBarType.fixed,
              selectedIconTheme: IconThemeData(
                color: Color(0xff6F24E9),
                size: size.height * 0.035,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDarkMode ? Colors.white : Colors.black,
                size: size.height * 0.035,
              ),
              unselectedLabelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: size.width * 0.04),
              selectedLabelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: size.width * 0.04,),
              selectedItemColor: isDarkMode ? Colors.white : Colors.black,
              onTap: onSelectedIndex,
              currentIndex: index,
              items: [
                BottomNavigationBarItem(
                    icon: buildNavIcon(
                        IconManager.home, index == 0, isDarkMode, context, size),
                    label: 'Index'),
                BottomNavigationBarItem(
                    icon: buildNavIcon(
                        IconManager.calendar, index == 1, isDarkMode, context, size),
                    label: 'Calendar'),
                BottomNavigationBarItem(
                    icon: buildNavIcon(
                        IconManager.clock, index == 2, isDarkMode, context, size),
                    label: 'Focus'),
                BottomNavigationBarItem(
                    icon: buildNavIcon(
                        IconManager.user, index == 3, isDarkMode, context, size),
                    label: 'Profile'),
              ]),
          body: screens[index],
        );
      },
    );
  }
}

Widget buildNavIcon(String assetPath, bool isActive, bool isDarkMode,
    BuildContext context, Size size) {
  double iconSize =
      size.width * (24 / 360); // or size.height * (24 / 800) if you prefer

  return SizedBox(
    height: iconSize,
    width: iconSize,
    child: SvgPicture.asset(
      assetPath,
      colorFilter: ColorFilter.mode(
        isActive
            ? const Color(0xff6F24E9)
            : (isDarkMode ? Colors.white : Colors.black),
        BlendMode.srcIn,
      ),
      fit: BoxFit.contain,
    ),
  );
}
