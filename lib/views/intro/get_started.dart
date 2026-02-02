import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return SafeArea(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: size.height * 0.15,
                      ),
                      Text(
                        'Welcome to Doova',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: size.width * 0.08),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Please login to your account or create\n new account to continue',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: size.width * 0.04),
                      ),
                      const Spacer(),
                      loginButton(
                        context,
                        size,
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      createAccountButton(
                        context,
                        size,
                      ),
                      SizedBox(
                        height: size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}

createAccountButton(
  BuildContext context,
  Size size,
) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          shape: WidgetStatePropertyAll(OutlinedBorder.lerp(
              BeveledRectangleBorder(
                  side: BorderSide(
                      color: Color(0xff6F24E9), width: size.width * 0.0030)),
              BeveledRectangleBorder(
                  side: BorderSide(
                      color: Color(0xff6F24E9), width: size.width * 0.0030)),
              BorderSide.strokeAlignOutside)),
          backgroundColor:
              WidgetStatePropertyAll(isDarkMode ? Colors.black : Colors.white),
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: () {
        context.go('/IntroScreenDefault/CreateAccount');
      },
      child: Text(
        'CREATE ACCOUNT',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontSize: size.width * 0.04),
      ));
}

loginButton(
  BuildContext context,
  Size size,
) {
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: () {
        context.go('/IntroScreenDefault/Login');
      },
      child: Text(
        'LOGIN',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontSize: size.width * 0.04),
      ));
}
