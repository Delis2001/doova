import 'package:doova/components/indicator.dart';
import 'package:doova/provider/auth/auth_provider.dart';
import 'package:doova/components/auth/social_button.dart';
import 'package:doova/components/auth/textfield.dart';
import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var keyboardSpace = MediaQuery.of(context).viewInsets;
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AuthProvider>().isLoading;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(children: [
          Scaffold(
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: keyboardSpace.bottom),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                context.pop();
                              },
                              icon: Icon(
                                size: size.width * 0.05,
                                color: isDarkMode ? Colors.white : Colors.black,
                                Icons.arrow_back_ios_new,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.020),
                          Text(
                            'Sign into your account',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: size.width * 0.08),
                          ),
                          SizedBox(
                            height: size.height * 0.055,
                          ),
                          Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: size.height * 0.005,
                                  ),
                                  text(context, 'Email', size),
                                  AuthTextField(
                                    size: size,
                                    textCapitalization: TextCapitalization.none,
                                    hintText: 'Enter your email',
                                    controller: emailController,
                                    onSaved: (newValue) =>
                                        FocusScope.of(context).unfocus(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Invalid email format';
                                      } else if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Invalid email format';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: size.height * 0.020,
                                  ),
                                  text(context, 'Password', size),
                                  SizedBox(
                                    height: size.height * 0.005,
                                  ),
                                  PasswordTextfield(
                                    size: size,
                                    obscureText: !obscureText,
                                    onSaved: (newValue) =>
                                        FocusScope.of(context).unfocus(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your password';
                                      } else if (value.length < 6) {
                                        return 'Password is too weak. It must be at least 6 characters.';
                                      }
                                      return null;
                                    },
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscureText = !obscureText;
                                          });
                                        },
                                        icon: Icon(
                                            size: size.width * 0.05,
                                            obscureText
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color(0xFF2C2C2E))),
                                    controller: passwordController,
                                  )
                                ],
                              )),
                          SizedBox(
                            height: size.height * 0.10,
                          ),
                          continueButton(
                              context: context,
                              emailController: emailController,
                              passwordController: passwordController,
                              formKey: _formKey,
                              size: size),
                          SizedBox(
                            height: size.height * 0.030,
                          ),
                          Row(
                            children: [
                              divider(context, size),
                              Text(' or ',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? const Color(0xFF2C2C2E)
                                          : const Color(0xffE5E5E5),
                                      fontSize: size.width * 0.04)),
                              divider(context, size)
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.030,
                          ),
                          SocialButton(
                            size: size,
                            onPressed: () async {
                              final imageProvider =
                                  context.read<ImageProviderNotifier>();
                              imageProvider.resetImageInitialization();
                              await imageProvider.clearImagePrefs();
                              if (!context.mounted) return;
                              await context
                                  .read<AuthProvider>()
                                  .signInWithGoogle(context);
                            },
                            icon: 'assets/icon/google_logo.png',
                            text: 'sign in with Google',
                            isIcon: false,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          SocialButton(
                            size: size,
                            onPressed: () async {
                              final imageProvider =
                                  context.read<ImageProviderNotifier>();
                              imageProvider.resetImageInitialization();
                              await imageProvider.clearImagePrefs();
                              if (!context.mounted) return;
                              await context
                                  .read<AuthProvider>()
                                  .signInWithApple(context);
                            },
                            icons: Icons.apple,
                            text: 'sign in with Apple',
                            isIcon: true,
                          ),
                          SizedBox(
                            height: size.height * 0.060,
                          ),
                          richText(context, size),
                          SizedBox(
                            height: size.height * 0.060,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingIndicator(
                  size: size,
                ),
              ),
            ),
        ]);
      },
    );
  }
}

richText(BuildContext context, Size size) {
  return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          children: [
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap =
                      () => context.go('/IntroScreenDefault/CreateAccount'),
                text: ' Sign Up Here',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xff6F24E9),
                    fontSize: size.width * 0.04)),
          ],
          text: 'Don’t have an account?',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: size.width * 0.04,
              )));
}

divider(BuildContext context, Size size) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Expanded(
      child: Divider(
    thickness: size.width * 0.0050,
    color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
  ));
}

continueButton({
  required GlobalKey<FormState> formKey,
  required BuildContext context,
  required Size size,
  required TextEditingController passwordController,
  required TextEditingController emailController,
}) {
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          final imageProvider = context.read<ImageProviderNotifier>();
          imageProvider.resetImageInitialization();
          await imageProvider.clearImagePrefs();
          if (!context.mounted) return;
          final loginSuccess = await context.read<AuthProvider>().login(
                context: context,
                email: emailController.text.trim().toLowerCase(),
                password: passwordController.text.trim(),
              );

          if (loginSuccess == null) {
            await imageProvider.initializeProfileImages();
          }

          return;
        }
      },
      child: Text(
        'Continue',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontSize: size.width * 0.04),
      ));
}

text(BuildContext context, String text, Size size) {
  return Text(text,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontSize: size.width * 0.04));
}
