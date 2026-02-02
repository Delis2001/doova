import 'package:doova/provider/theme/theme_provider.dart';
// import 'package:doova/components/profile/setting_listile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final isLargeScreen = size.width > 600;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: size.width > 600
                ? topPadding +
                    size.height * 0.08 // Gives room for notch + your content
                : kToolbarHeight, // Use default on phones
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: size.width * 0.05,
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontSize: size.width * 0.06),
            ),
          ),
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.001,
                    vertical: size.height * 0.005,
                  ),
                  leading: SizedBox(
                    height: size.height * 0.06,
                    width: size.width * 0.06,
                    child: Image.asset(
                      'assets/icon/brush.png',
                      color: isDarkMode ? Colors.white : Colors.black,
                      fit: BoxFit.contain,
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: size.width * 0.04),
                  ),
                  trailing: Transform.scale(
                    scale: isLargeScreen
                        ? 1.5
                        : 1.0, // 👈 scale switch on large screens
                    child: Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      activeColor: isDarkMode ? Colors.white : Colors.black,
                      activeTrackColor: const Color(0xff6F24E9),
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ),
                ),

                // /// ✅ Other settings list tile
                // SettingsListTile(
                //   onTap: () {},
                //   icon: 'assets/icon/menu.png',
                //   title: 'Notification',
                //   isDarkMode: isDarkMode,
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
