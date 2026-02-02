import 'package:doova/r.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorView extends StatelessWidget {
  const ErrorView(
      {super.key, required this.errorMessage, required this.stackTrace});
  final String errorMessage;
  final String stackTrace;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return SafeArea(
                child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.050),
                    Image.asset(AssetsManager.errorImage),
                    SizedBox(height: size.height * 0.020),
                    Text(
                      'Oops!',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.black87, fontSize: size.width * 0.08),
                    ),
                    Text(
                        textAlign: TextAlign.center,
                        'Well, this is unexpected...',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Colors.black54,
                                fontSize: size.width * 0.04)),
                    SizedBox(height: size.height * 0.015),
                    Text(
                        textAlign: TextAlign.center,
                        errorMessage,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Colors.black45,
                                fontSize: size.width * 0.04)),
                    SizedBox(height: size.height * 0.055),
                    homePageButton(context, size),
                    helpButton(context, size)
                  ],
                ),
              ),
            ));
          },
        ));
  }
}

homePageButton(
  BuildContext context,
  Size size,
) {
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor:
              WidgetStatePropertyAll(const Color.fromARGB(255, 21, 126, 212)),
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: () {
        final user = FirebaseAuth.instance.currentUser;
        user != null
            ? context.go('/HomeScreen')
            : context.go('/IntroScreenDefault');
      },
      child: Text(
        'Back to HomePage',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Colors.white, fontSize: size.width * 0.04),
      ));
}

helpButton(BuildContext context, Size size) {
  return TextButton(
      onPressed: () async {
        final String whatsappUrl = "https://wa.link/fhi1ng";
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl),
              mode: LaunchMode.externalApplication);
        } else {
          debugPrint("❌ Could not open WhatsApp.");
        }

        // context.pushReplacement('/CustomerSupport');
      },
      child: Text('Visit our help center',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.black, fontSize: size.width * 0.04)));
}
