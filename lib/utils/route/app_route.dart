// import 'package:doova/provider/auth_provider.dart';
import 'package:doova/views/error/error.dart';
import 'package:doova/views/intro/intro.dart';
import 'package:doova/views/navBar/bottom_nav.dart';
import 'package:doova/components/profile/app_settings.dart';
import 'package:doova/views/intro/onboading.dart';
import 'package:doova/views/auth/login_screen.dart';
import 'package:doova/views/auth/register_screen.dart';
import 'package:doova/views/supports/customer_support.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AppRoutes {
  static GoRouter goRoute(GlobalKey<NavigatorState> navigatorKey) {
    final GoRouter router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
            path: '/IntroScreenDefault',
            builder: (context, state) => const IntroScreenDefault(),
            routes: [
              GoRoute(
                path: 'CreateAccount',
                builder: (context, state) => const RegisterScreen(),
              ),
              GoRoute(
                path: 'Login',
                builder: (context, state) => const LoginScreen(),
              ),
            ]),
        GoRoute(
            path: '/HomeScreen',
            builder: (context, state) => const BottomNavBar(),
            routes: [
              GoRoute(
                path: 'AppSettingScreen',
                builder: (context, state) => const AppSettings(),
              ),
            ]),
        GoRoute(
          path: '/CustomerSupport',
          builder: (context, state) => const CustomerSupport(),
        ),
        GoRoute(
            path: '/ErrorScreen',
            builder: (context, state) {
              final extras = state.extra as Map<String, String>? ?? {};
              return ErrorView(
                errorMessage: extras['errorMessage'] ?? 'Unknown error',
                stackTrace: extras['stackTrace'] ?? '',
              );
            }),
      ],
    );
    return router;
  }
}
