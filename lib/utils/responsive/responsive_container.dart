// import 'package:doova/utils/helpers/toast.dart';
// import 'package:flutter/material.dart';

// class ResponsiveContainer extends StatelessWidget {
//   final Widget child;

//   const ResponsiveContainer({
//     super.key,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         Toast.setScreenWidth(constraints.maxWidth);
//         return Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isDark
//                       ? [
//                           const Color(0xFF0F0F0F),
//                           const Color(0xFF1A1A1A),
//                           const Color(0xFF0F0F0F),
//                         ]
//                       : [
//                           const Color(0xFFF5F7FA),
//                           const Color(0xFFFFFFFF),
//                           const Color(0xFFF0F2F5),
//                         ],
//                 ),
//               ),
//             ),
//             Center(
//               child: Container(
//                 width: constraints.maxWidth > 600 ? 600 : constraints.maxWidth,
//                 height: constraints.maxHeight  < 600  ? 600 : constraints.maxHeight,
//                 decoration: BoxDecoration(
//                   color: isDark
//                       ? Colors.black.withOpacity(0.25)
//                       : Colors.white.withOpacity(0.85),
//                   borderRadius: BorderRadius.circular(16),
//                   border: constraints.maxWidth > 600
//                       ? Border.all(
//                           color: isDark ? Colors.white24 : Colors.black12,
//                         )
//                       : null,
//                   boxShadow: constraints.maxWidth > 600
//                       ? [
//                           BoxShadow(
//                             blurRadius: 20,
//                             spreadRadius: 2,
//                             offset: const Offset(0, 8),
//                             color: isDark ? Colors.black54 : Colors.black12,
//                           )
//                         ]
//                       : null,
//                 ),
//                 child: child,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
