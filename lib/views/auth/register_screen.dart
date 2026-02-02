import 'package:doova/components/indicator.dart';
import 'package:doova/provider/auth/auth_provider.dart';
import 'package:doova/components/auth/social_button.dart';
import 'package:doova/components/auth/textfield.dart';
import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passwordControllerObscureText = false;
  bool confirmPasswordControllerObscureText = false;

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    fullnameController.dispose();
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
                        Text('Welcome to the Doova',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: size.width * 0.08)),
                        SizedBox(
                          height: size.height * 0.055,
                        ),
                        Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: size.width * 0.04)),
                                SizedBox(
                                  height: size.height * 0.005,
                                ),
                                AuthTextField(
                                  size: size,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: fullnameController,
                                  hintText: 'Enter your fullName',
                                  onSaved: (newValue) =>
                                      FocusScope.of(context).unfocus(),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your fullName';
                                    }
                                    final parts =
                                        value.trim().split(RegExp(r'\s+'));
                                    if (parts.length < 2) {
                                      return 'Please enter both first and last name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: size.height * 0.020,
                                ),
                                Text('Email',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: size.width * 0.04)),
                                AuthTextField(
                                  size: size,
                                  textCapitalization: TextCapitalization.none,
                                  hintText: 'Enter your email',
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Invalid email format';
                                    } else if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Invalid email format';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) =>
                                      FocusScope.of(context).unfocus(),
                                ),
                                SizedBox(
                                  height: size.height * 0.020,
                                ),
                                Text('Password',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: size.width * 0.04)),
                                SizedBox(
                                  height: size.height * 0.005,
                                ),
                                PasswordTextfield(
                                  size: size,
                                  obscureText: !passwordControllerObscureText,
                                  onSaved: (newValue) =>
                                      FocusScope.of(context).unfocus(),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password is too weak. It must be at least 6 characters.';
                                    }
                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passwordControllerObscureText =
                                              !passwordControllerObscureText;
                                        });
                                      },
                                      icon: Icon(
                                          size: size.width * 0.05,
                                          passwordControllerObscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: const Color(0xFF2C2C2E))),
                                  controller: passwordController,
                                ),
                                SizedBox(
                                  height: size.height * 0.020,
                                ),
                                Text('Confirm Password',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: size.width * 0.04)),
                                SizedBox(
                                  height: size.height * 0.005,
                                ),
                                PasswordTextfield(
                                  size: size,
                                  obscureText:
                                      !confirmPasswordControllerObscureText,
                                  controller: confirmPasswordController,
                                  onSaved: (newValue) =>
                                      FocusScope.of(context).unfocus(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    } else if (value !=
                                        passwordController.text.trim()) {
                                      return 'Passwords do not match';
                                    } else if (value.length < 6) {
                                      return 'Password is too weak. It must be at least 6 characters.';
                                    }
                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          confirmPasswordControllerObscureText =
                                              !confirmPasswordControllerObscureText;
                                        });
                                      },
                                      icon: Icon(
                                          size: size.width * 0.05,
                                          confirmPasswordControllerObscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: const Color(0xFF2C2C2E))),
                                )
                              ],
                            )),
                        SizedBox(
                          height: size.height * 0.10,
                        ),
                        continueInButton(
                            fullnameController: fullnameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            context: context,
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
                          text: 'sign up with Google',
                          isIcon: false,
                          icon: 'assets/icon/google_logo.png',
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
                          text: 'sign up with Apple',
                          isIcon: true,
                          icons: Icons.apple,
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
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child:  Center(
                child: LoadingIndicator(size: size,),
              ),
            ),
        ]);
      },
    );
  }
}

continueInButton({
  required GlobalKey<FormState> formKey,
  required BuildContext context,
  required Size size,
  required TextEditingController passwordController,
  required TextEditingController emailController,
  required TextEditingController fullnameController,
}) {
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await context.read<AuthProvider>().register(
              fullName: fullnameController.text.trim(),
              email: emailController.text.trim().toLowerCase(),
              password: passwordController.text.trim(),
              context: context);
          if (!context.mounted) return;
          await context.read<ImageProviderNotifier>().clearImagePrefs();
        }
        return;
      },
      child: Text(
        'Continue',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontSize: size.width * 0.04),
      ));
}

divider(BuildContext context, Size size) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Expanded(
      child: Divider(
    thickness: size.width * 0.0050,
    color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
  ));
}

richText(BuildContext context, Size size) {
  return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          children: [
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.go('/IntroScreenDefault/Login'),
                text: ' Sign in Here',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xff6F24E9),
                    fontSize: size.width * 0.04)),
          ],
          text: 'Already have an account?',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontSize: size.width * 0.04)));
}
