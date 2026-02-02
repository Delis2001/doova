// import 'package:flutter/material.dart';
// import 'package:doova/r.dart';
// import 'package:package_info_plus/package_info_plus.dart'; // Replace with your own asset paths

// class AboutDoova extends StatefulWidget {
//   const AboutDoova({super.key});

//   @override
//   State<AboutDoova> createState() => _AboutDoovaState();
// }

// class _AboutDoovaState extends State<AboutDoova> {
//   String appName = 'Doova';
//   String version = '';
//   String buildNumber = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadAppInfo();
//   }

//   Future<void> _loadAppInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     setState(() {
//       appName = info.appName;
//       version = info.version;
//       buildNumber = info.buildNumber;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('About Doova'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // App Logo
//             SizedBox(
//               height: size.height * 0.15,
//               child: Image.asset(
//                 AssetsManager.logo, // your app logo
//                 fit: BoxFit.contain,
//               ),
//             ),
//             SizedBox(height: size.height * 0.02),

//             // App Name
//             Text(
//               appName,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),

//             SizedBox(height: size.height * 0.015),

//             // Short description
//             Text(
//               'Doova helps you stay focused, organized, and productive every day. '
//               'Manage your tasks, track your focus, and achieve more.',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),

//             SizedBox(height: size.height * 0.04),

//             // Version info
//             Text(
//               'Version: $version ($buildNumber)',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                   ),
//             ),

//             SizedBox(height: size.height * 0.04),

//             // Privacy Policy & Terms buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 OutlinedButton(
//                   onPressed: () {
//                    Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
//                     );
//                   },
//                   child: const Text('Privacy Policy'),
//                 ),
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
//                     );
//                   },
//                   child: const Text('Terms of Use'),
//                 ),
//               ],
//             ),

//             SizedBox(height: size.height * 0.05),

//             // Contact Info / Credits
//             Text(
//               'Developed by Doova Team\nsupport@doova.app',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class PrivacyPolicyScreen extends StatelessWidget {
//   const PrivacyPolicyScreen({super.key});

//   final String _privacyPolicy = '''
// # Privacy Policy

// _Last updated: July 2025_

// At Doova, your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information when you use our app.

// ## Information We Collect
// We collect information you provide directly to us, such as account registration and tasks.

// ## How We Use Information
// We use this information to provide, improve, and personalize our services.

// ## Data Security
// We take reasonable steps to protect your data from unauthorized access or disclosure.

// ## Sharing Information
// We do not sell your information. We may share with trusted partners only to operate the service.

// ## Your Rights
// You may access, update, or delete your personal information by contacting us.

// ## Changes to This Policy
// We may update this Privacy Policy. Continued use of Doova means you accept these changes.

// For questions, please contact support@doova.app.
// ''';

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Privacy Policy'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: SelectableText(
//           _privacyPolicy,
//           style: TextStyle(
//             fontSize: 14,
//             height: 1.5,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class TermsAndConditionsScreen extends StatelessWidget {
//   const TermsAndConditionsScreen({super.key});

//   final String _termsText = '''
// # Terms and Conditions

// _Last updated: July 2025_

// Welcome to Doova. By using our app, you agree to the following terms and conditions:

// ## Use of the App
// You agree to use Doova legally and respectfully.

// ## Account Responsibilities
// You are responsible for keeping your account secure and for activities under your account.

// ## Intellectual Property
// All content and materials in Doova are protected by law.

// ## Limitation of Liability
// Doova is provided as-is; we disclaim liability for damages arising from use.

// ## Changes to Terms
// We may update these terms. Continued use means acceptance.

// Contact support@doova.app for more info.
// ''';

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Terms & Conditions'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: SelectableText(
//           _termsText,
//           style: TextStyle(
//             fontSize: 14,
//             height: 1.5,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
// }


