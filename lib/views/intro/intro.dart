import 'package:doova/r.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Navigate after splash duration
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        context.go('/HomeScreen');
      } else {
        context.go('/IntroScreenDefault');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
          Toast.setScreenWidth(constraints.maxWidth);
        return Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.logo,
                  height: constraints.maxHeight * 0.15,
                  width: constraints.maxWidth * 0.15,
                  color: const Color(0xff6F24E9),
                ),
                const SizedBox(width: 12),
                Text(
                  'Doova',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: constraints.maxWidth * 0.1, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
      },)
    );
  }
}
