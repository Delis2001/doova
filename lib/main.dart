import 'dart:async';

import 'package:doova/firebase_options.dart';
import 'package:doova/provider/auth/auth_provider.dart';
import 'package:doova/provider/focus/app_usage.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/utils/message_handler/message_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:doova/provider/theme/theme_provider.dart';
import 'package:doova/utils/route/app_route.dart';
import 'package:doova/utils/theme/theme.dart';
import 'package:doova/views/error/error.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final GoRouter _router;
final apiKey = 'test_eMNEUKZmZqLyoJNcrEqUfRTttxf';

// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'dart:io';

// Future<void> initializeRevenueCat() async {
//   // Platform-specific API keys
//   String apiKey;
//   if (Platform.isIOS) {
//     apiKey = 'test_eMNEUKZmZqLyoJNcrEqUfRTttxf';
//   } else if (Platform.isAndroid) {
//     apiKey = 'test_eMNEUKZmZqLyoJNcrEqUfRTttxf';
//   } else {
//     throw UnsupportedError('Platform not supported');
//   }

//   await Purchases.configure(PurchasesConfiguration(apiKey));
// }

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized(); // ✅ Moved into zone
    MobileAds.instance.initialize();
    RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds: ['ddb8639a-0fd0-4b63-8eb3-cc1fa1322284']);
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    await Purchases.configure(
      PurchasesConfiguration("YOUR_REVENUECAT_API_KEY"),
    );
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final themeProvider = ThemeProvider();
    await themeProvider.loadTheme();

    _router = AppRoutes.goRoute(navigatorKey);

    await initLocalNotifications();
    await initPushMessaging();
    runApp(Doova(themeProvider: themeProvider));
  }, (error, stackTrace) {
    debugPrint('Caught async error: $error');
    _navigateToError(error.toString(), stackTrace.toString());
  });

  // For sync Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Caught UI error: ${details.exception}');
    _navigateToError(details.exception.toString(), details.stack.toString());
  };
}

void _navigateToError(String errorMessage, String stackTrace) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(
        '/ErrorScreen',
        extra: {
          'errorMessage': errorMessage,
          'stackTrace': stackTrace,
        },
      );
    }
  });
}

class Doova extends StatefulWidget {
  final ThemeProvider themeProvider;
  const Doova({super.key, required this.themeProvider});

  @override
  State<Doova> createState() => _DoovaState();
}

class _DoovaState extends State<Doova> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider(create: (_) => ImageProviderNotifier()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => FocusModeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Doova',
            routerConfig: _router,
            darkTheme: AppTheme.darkTheme(context),
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(context),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails details) {
                return ErrorView(
                  errorMessage: details.exception.toString(),
                  stackTrace: details.stack.toString(),
                );
              };
              return child!;
              // ResponsiveContainer(
              //   child: child!,
              // );
            },
          );
        },
      ),
    );
  }
}
