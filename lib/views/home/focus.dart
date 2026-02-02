// import 'dart:async';
// import 'dart:typed_data';
// import 'package:delightful_toast/toast/utils/enums.dart';
// import 'package:doova/components/indicator.dart';
// import 'package:doova/provider/focus/app_usage.dart';
// import 'package:doova/r.dart';
// import 'package:doova/utils/helpers/network_checker.dart';
// import 'package:doova/utils/helpers/toast.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

// final String networkMessage =
//     'No internet connection. Connect to the internet and try again';

// class FocusModeScreen extends StatefulWidget {
//   const FocusModeScreen({super.key});

//   @override
//   State<FocusModeScreen> createState() => _FocusModeScreenState();
// }

// class _FocusModeScreenState extends State<FocusModeScreen>
//     with WidgetsBindingObserver {
//   late final StreamSubscription<User?> _authSubscription;
//   final RefreshController _refreshController = RefreshController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       final provider = context.read<FocusModeProvider>();
//       provider.checkPermission();
//       final now = DateTime.now();
//       final startToday = DateTime(now.year, now.month, now.day);
//       provider.fetchUsageStats(start: startToday, end: now);
//       provider.fetchDailyFocusHours();
//       _authSubscription =
//           FirebaseAuth.instance.authStateChanges().listen((user) {
//         if (user != null) {
//           context.read<FocusModeProvider>().fetchDailyFocusHours();
//         } else {
//           context.read<FocusModeProvider>().resetFocusForCurrentUser();
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _authSubscription.cancel();
//     _refreshController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       final provider = context.read<FocusModeProvider>();
//       provider.checkPermission();
//     }
//   }

//   String formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return "$minutes:$secs";
//   }

//   String formatDuration(Duration duration) {
//     if (duration.inHours > 0) {
//       return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
//     }
//     return "${duration.inMinutes}m";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final provider = Provider.of<FocusModeProvider>(context);
//     final percent = (provider.seconds / (25 * 60)).clamp(0.0, 1.0);
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final topPadding = MediaQuery.of(context).padding.top;
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: size.width > 600
//             ? topPadding +
//                 size.height * 0.08 // Gives room for notch + your content
//             : kToolbarHeight, // Use default on phones
//         elevation: 0,
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         backgroundColor: isDarkMode ? Colors.black : Colors.white,
//         title:
//             Text("Focus Mode", style: Theme.of(context).textTheme.titleSmall),
//       ),
//       body: SafeArea(
//         child: !provider.hasPermission
//             ? Center(
//                 child: ElevatedButton(
//                   onPressed: provider.requestPermission,
//                   child: Text('Grant Usage Access',
//                       style: Theme.of(context).textTheme.titleMedium),
//                 ),
//               )
//             : SmartRefresher(
//                 controller: _refreshController,
//                 enablePullDown: true,
//                 enablePullUp: false,
//                 header: CustomHeader(
//                   height: size.height * 0.1,
//                   builder: (context, mode) {
//                     return Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: buildCustomSpinner(context),
//                       ),
//                     );
//                   },
//                 ),
//                 onRefresh: () async {
//                   await onRefresh();
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.only(bottom: size.height * 0.02),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         CircularPercentIndicator(
//                           radius:
//                               size.width * 0.25, // 👈 Responsive circle radius
//                           lineWidth:
//                               size.width * 0.03, // 👈 Responsive line width
//                           percent: percent,
//                           center: Text(
//                             formatTime(provider.seconds),
//                             style: TextStyle(
//                               color: isDarkMode ? Colors.white : Colors.black,
//                               fontSize: size.width * 0.08, // 👈 Responsive time
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           progressColor: const Color(0xff6F24E9),
//                           backgroundColor: isDarkMode
//                               ? const Color(0xFF2C2C2E)
//                               : const Color(0xffE5E5E5),
//                           circularStrokeCap: CircularStrokeCap.round,
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Text(
//                             "While your focus mode is on, all of your notifications will be off",
//                             textAlign: TextAlign.center,
//                             style: Theme.of(context).textTheme.titleMedium),
//                         ElevatedButton(
//                           onPressed: () async {
//                             if (provider.isFocusing) {
//                               await provider.stopFocus();
//                             } else {
//                               if (!await hasNetwork()) {
//                                 errorToast(context, networkMessage,
//                                     color: Colors.red,
//                                     position: DelightSnackbarPosition.top);
//                                 return;
//                               }
//                               await provider.startFocus(context);
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff6F24E9),
//                             padding: EdgeInsets.symmetric(
//                               horizontal: size.width * 0.1,
//                               vertical: size.height * 0.02,
//                             ),
//                           ),
//                           child: Text(
//                               provider.isFocusing
//                                   ? "Stop Focusing"
//                                   : "Start Focusing",
//                               style: Theme.of(context).textTheme.titleMedium),
//                         ),
//                         SizedBox(height: size.height * 0.04),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Overview",
//                                 style: Theme.of(context).textTheme.titleSmall),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: size.width * 0.03,
//                                 vertical: size.height * 0.008,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isDarkMode
//                                     ? const Color(0xFF2C2C2E)
//                                     : const Color(0xffE5E5E5),
//                                 borderRadius:
//                                     BorderRadius.circular(size.width * 0.02),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     "This Week",
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleMedium
//                                         ?.copyWith(
//                                           fontSize: size.width * 0.032,
//                                         ),
//                                   ),
//                                   SizedBox(width: size.width * 0.02),
//                                   SizedBox(
//                                     height: size.height * 0.03,
//                                     width: size.width * 0.03,
//                                     child: Image.asset(
//                                       fit: BoxFit.contain,
//                                       IconManager.arrowDown,
//                                       width: size.width * 0.045,
//                                       color: isDarkMode
//                                           ? Colors.white
//                                           : Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: size.height * 0.03),
//                         SizedBox(
//                           height:
//                               size.height * 0.25, // 👈 Responsive chart height
//                           child: WeeklyBarChart(
//                             dailyFocusHours: provider.dailyFocusHours,
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.03),
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text("Applications",
//                               style: Theme.of(context).textTheme.titleSmall),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         if (kIsWeb)
//                           // 🌐 Web message
//                           Container(
//                             padding: EdgeInsets.all(size.width * 0.04),
//                             decoration: BoxDecoration(
//                               color: isDarkMode
//                                   ? const Color(0xFF2C2C2E)
//                                   : const Color(0xffE5E5E5),
//                               borderRadius:
//                                   BorderRadius.circular(size.width * 0.02),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "Application usage data is not available on web.",
//                                 style: Theme.of(context).textTheme.titleMedium,
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           )
//                         else
//                           // Mobile: display actual apps
//                           ...provider.usages.map(
//                             (app) => Container(
//                               height: size.height * 0.1,
//                               margin: EdgeInsets.symmetric(
//                                   vertical: size.height * 0.008),
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: size.width * 0.03),
//                               decoration: BoxDecoration(
//                                 color: isDarkMode
//                                     ? const Color(0xFF2C2C2E)
//                                     : const Color(0xffE5E5E5),
//                                 borderRadius:
//                                     BorderRadius.circular(size.width * 0.02),
//                               ),
//                               child: ListTile(
//                                 leading: app.appDetails != null
//                                     ? Image.memory(
//                                         app.appDetails?.icon ?? Uint8List(0),
//                                         width: size.width * 0.1,
//                                         height: size.width * 0.1,
//                                       )
//                                     : Icon(
//                                         Icons.apps,
//                                         color: isDarkMode
//                                             ? Colors.white
//                                             : Colors.black,
//                                         size: size.width * 0.08,
//                                       ),
//                                 title: Text(
//                                   app.appName,
//                                   softWrap: true,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleSmall
//                                       ?.copyWith(
//                                         fontSize: size.width * 0.038,
//                                       ),
//                                 ),
//                                 subtitle: Text(
//                                   "Used ${formatDuration(app.usageTime)} ${provider.formatRangeLabel()}",
//                                   softWrap: true,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium
//                                       ?.copyWith(
//                                         fontSize: size.width * 0.032,
//                                       ),
//                                 ),
//                                 trailing: SizedBox(
//                                   width: size.width * 0.15,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Image.asset(
//                                         IconManager.usageLine,
//                                         fit: BoxFit.contain,
//                                         height: size.height * 0.04,
//                                         color: const Color(0xff979797),
//                                       ),
//                                       SizedBox(width: size.width * 0.02),
//                                       Image.asset(
//                                         IconManager.infoCircle,
//                                         height: size.height * 0.035,
//                                         fit: BoxFit.contain,
//                                         color: isDarkMode
//                                             ? Colors.white
//                                             : Colors.black,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Future<void> onRefresh() async {
//     final size = MediaQuery.of(context).size;
//     final provider = context.read<FocusModeProvider>();
//     final isConnected = await hasNetwork();
//     if (!isConnected) {
//       if (!mounted) return;
//       errorToast(
//         isYellow: true,
//         leading: SizedBox(
//             height: size.height * 0.07,
//             width: size.width * 0.07,
//             child: Image.asset(
//               IconManager.wifi,
//               fit: BoxFit.contain,
//               color: Colors.yellow,
//             )),
//         context,
//         'No internet connection. Connect to the internet and try again',
//         color: Colors.black.withOpacity(0.5),
//         position: DelightSnackbarPosition.bottom,
//       );
//       _refreshController.refreshFailed();
//       return;
//     }

//     try {
//       final now = DateTime.now();
//       final startToday = DateTime(now.year, now.month, now.day);
//       await provider.fetchUsageStats(start: startToday, end: now);
//       await provider.fetchDailyFocusHours();
//       _refreshController.refreshCompleted();
//     } catch (e) {
//       _refreshController.refreshFailed();
//       if (mounted) {
//         errorToast(
//             isYellow: true,
//             leading: SizedBox(
//                 height: size.height * 0.07,
//                 width: size.width * 0.07,
//                 child: Image.asset(
//                   IconManager.wifi,
//                   fit: BoxFit.contain,
//                   color: Colors.yellow,
//                 )),
//             context,
//             "We ran into a problem. Please try again shortly",
//             color: Colors.black.withOpacity(0.5),
//             position: DelightSnackbarPosition.bottom);
//       }
//     }
//   }
// }

import 'dart:async';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/components/indicator.dart';
import 'package:doova/provider/focus/app_usage.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final String networkMessage =
    'No internet connection. Connect to the internet and try again';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with WidgetsBindingObserver {
  late final StreamSubscription<User?> _authSubscription;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<FocusModeProvider>();

      if (!kIsWeb) {
        // Only request/check permission on mobile
        provider.checkPermission();

        final now = DateTime.now();
        final startToday = DateTime(now.year, now.month, now.day);
        provider.fetchUsageStats(start: startToday, end: now);
      }

      provider.fetchDailyFocusHours();

      // Listen to auth changes
      _authSubscription =
          FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          context.read<FocusModeProvider>().fetchDailyFocusHours();
        } else {
          context.read<FocusModeProvider>().resetFocusForCurrentUser();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      context.read<FocusModeProvider>().checkPermission();
    }
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    }
    return "${duration.inMinutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FocusModeProvider>(context);
    final percent = (provider.seconds / (25 * 60)).clamp(0.0, 1.0);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: size.width > 600
                ? topPadding + size.height * 0.08
                : kToolbarHeight,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            title: Text("Focus Mode",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: size.width * 0.06)),
          ),
          body: SafeArea(
            child: kIsWeb
                ? _buildWebUI(size, provider, percent, isDarkMode)
                : _buildMobileUI(size, provider, percent, isDarkMode),
          ),
        );
      },
    );
  }

  // 🌐 Web UI: Timer, overview, chart, apps placeholder
  Widget _buildWebUI(
      Size size, FocusModeProvider provider, double percent, bool isDarkMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04, vertical: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFocusTimer(size, provider, percent, isDarkMode),
          SizedBox(height: size.height * 0.04),
          _buildOverview(size, provider, isDarkMode),
          SizedBox(height: size.height * 0.03),
          WeeklyBarChart(dailyFocusHours: provider.dailyFocusHours,size: size,),
          SizedBox(height: size.height * 0.03),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Applications",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: size.width * 0.06)),
          ),
          SizedBox(height: size.height * 0.02),
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xffE5E5E5),
              borderRadius: BorderRadius.circular(size.width * 0.02),
            ),
            child: Center(
              child: Text(
                "Application usage data is not available on web.",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontSize: size.width * 0.04),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📱 Mobile UI: Full focus + permission check
  Widget _buildMobileUI(
      Size size, FocusModeProvider provider, double percent, bool isDarkMode) {
    if (!provider.hasPermission) {
      return Center(
        child: ElevatedButton(
          onPressed: provider.requestPermission,
          child: Text('Grant Usage Access',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: size.width * 0.04)),
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      header: CustomHeader(
        height: size.height * 0.1,
        builder: (context, mode) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildCustomSpinner(context, size),
          ),
        ),
      ),
      onRefresh:(){onRefresh(size);}, 
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFocusTimer(size, provider, percent, isDarkMode),
              SizedBox(height: size.height * 0.04),
              _buildOverview(size, provider, isDarkMode),
              SizedBox(height: size.height * 0.03),
              WeeklyBarChart(dailyFocusHours: provider.dailyFocusHours,size: size,),
              SizedBox(height: size.height * 0.03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Applications",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: size.width * 0.06)),
              ),
              SizedBox(height: size.height * 0.02),
              ...provider.usages
                  .map((app) => _buildAppTile(app, size, isDarkMode)),
            ],
          ),
        ),
      ),
    );
  }

  // Timer + Start/Stop button
  Widget _buildFocusTimer(
      Size size, FocusModeProvider provider, double percent, bool isDarkMode) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: size.width * 0.25,
          lineWidth: size.width * 0.03,
          percent: percent,
          center: Text(
            formatTime(provider.seconds),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: size.width * 0.08,
              fontWeight: FontWeight.bold,
            ),
          ),
          progressColor: const Color(0xff6F24E9),
          backgroundColor:
              isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          "While your focus mode is on, all of your notifications will be off",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: size.width * 0.04),
        ),
        SizedBox(height: size.height * 0.02),
        ElevatedButton(
          onPressed: () async {
            if (provider.isFocusing) {
              await provider.stopFocus();
            } else {
              if (!kIsWeb && !await hasNetwork()) {
                Toast.errorToast(context, networkMessage,
                    color: Colors.red, position: DelightSnackbarPosition.top);
                return;
              }
              await provider.startFocus(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff6F24E9),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1,
              vertical: size.height * 0.02,
            ),
          ),
          child: Text(
            provider.isFocusing ? "Stop Focusing" : "Start Focusing",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: size.width * 0.04),
          ),
        ),
      ],
    );
  }

  // Overview section
  Widget _buildOverview(
      Size size, FocusModeProvider provider, bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Overview", style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: size.width * 0.04)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03, vertical: size.height * 0.008),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xffE5E5E5),
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
              child: Row(
                children: [
                  Text(
                    "This Week",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: size.width * 0.032),
                  ),
                  SizedBox(width: size.width * 0.02),
                  SizedBox(
                    height: size.height * 0.03,
                    width: size.width * 0.03,
                    child: Image.asset(
                      fit: BoxFit.contain,
                      IconManager.arrowDown,
                      width: size.width * 0.045,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }

  // Mobile app tile
  Widget _buildAppTile(app, Size size, bool isDarkMode) {
    return Container(
      height: size.height * 0.1,
      margin: EdgeInsets.symmetric(vertical: size.height * 0.008),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
        borderRadius: BorderRadius.circular(size.width * 0.02),
      ),
      child: ListTile(
        leading: app.appDetails != null
            ? Image.memory(
                app.appDetails?.icon ?? Uint8List(0),
                width: size.width * 0.1,
                height: size.width * 0.1,
              )
            : Icon(Icons.apps,
                color: isDarkMode ? Colors.white : Colors.black,
                size: size.width * 0.08),
        title: Text(
          app.appName,
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontSize: size.width * 0.038),
        ),
        subtitle: Text(
          "Used ${formatDuration(app.usageTime)} ${Provider.of<FocusModeProvider>(context, listen: false).formatRangeLabel()}",
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: size.width * 0.032),
        ),
        trailing: SizedBox(
          width: size.width * 0.15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                IconManager.usageLine,
                fit: BoxFit.contain,
                height: size.height * 0.04,
                color: const Color(0xff979797),
              ),
              SizedBox(width: size.width * 0.02),
              Image.asset(
                IconManager.infoCircle,
                height: size.height * 0.035,
                fit: BoxFit.contain,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refresh logic
  Future<void> onRefresh(Size size) async {
    if (kIsWeb) {
      _refreshController.refreshCompleted();
      return;
    }
    final provider = context.read<FocusModeProvider>();
    final isConnected = await hasNetwork();

    if (!isConnected) {
      if (!mounted) return;
      Toast.errorToast(
        isYellow: true,
        leading: SizedBox(
            height: size.height * 0.07,
            width: size.width * 0.07,
            child: Image.asset(
              IconManager.wifi,
              fit: BoxFit.contain,
              color: Colors.yellow,
            )),
        context,
        networkMessage,
        color: Colors.black.withOpacity(0.5),
        position: DelightSnackbarPosition.bottom,
      );
      _refreshController.refreshFailed();
      return;
    }

    try {
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      await provider.fetchUsageStats(start: startToday, end: now);
      await provider.fetchDailyFocusHours();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      if (mounted) {
        Toast.errorToast(
            isYellow: true,
            leading: SizedBox(
                height: size.height * 0.07,
                width: size.width * 0.07,
                child: Image.asset(
                  IconManager.wifi,
                  fit: BoxFit.contain,
                  color: Colors.yellow,
                )),
            context,
            "We ran into a problem. Please try again shortly",
            color: Colors.black.withOpacity(0.5),
            position: DelightSnackbarPosition.bottom);
      }
    }
  }
}

class WeeklyBarChart extends StatelessWidget {
  final List<double> dailyFocusHours;
  final Size size;

  const WeeklyBarChart({
    super.key,
    required this.dailyFocusHours,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday % 7;
    final screenWidth = size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Responsive height: 25% of screen height or min 220px
    final chartHeight = size.height * 0.25;
    return SizedBox(
      height: chartHeight < 300 ? 300 : chartHeight,
      child: BarChart(
        BarChartData(
          maxY: 6,
          minY: 0,
          groupsSpace: screenWidth * 0.02,
          barGroups: dailyFocusHours.asMap().entries.map((entry) {
            final index = entry.key;
            final hours = entry.value;

            Color color;
            if (index == 0 || index == 6) {
              color = Colors.red;
            } else if (index == today) {
              color = const Color(0xff6F24E9);
            } else {
              color = isDarkMode ? Color(0xFF2C2C2E) : Color(0xffE5E5E5);
            }

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hours,
                  width: screenWidth * 0.07,
                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
                  color: color,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: () {
                      if (index == 0) return 2.5;
                      if (index == 1) return 3.5;
                      if (index == 2) return 6.0;
                      if (index == 3) return 2.8;
                      if (index == 6) return 2.0;
                      if (index == today) return 5.0;
                      return 4.5;
                    }(),
                    color: const Color(0xff979797),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenWidth * 0.08,
                interval: 1,
                getTitlesWidget: (value, _) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    "${value.toInt()}h",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: screenWidth * 0.035,
                        ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenWidth * 0.05,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= dailyFocusHours.length) {
                    return const SizedBox();
                  }

                  final hours = dailyFocusHours[i];
                  if (hours == 0) return const SizedBox();

                  final text = hours % 1 == 0
                      ? "${hours.toInt()}h"
                      : "${hours.floor()}h ${(hours % 1 * 60).round()}m";

                  return Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: screenWidth * 0.03,
                        ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: size.height * 0.05,
                getTitlesWidget: (value, _) {
                  const days = [
                    'SUN',
                    'MON',
                    'TUE',
                    'WED',
                    'THU',
                    'FRI',
                    'SAT'
                  ];
                  final i = value.toInt();
                  return Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.015),
                    child: Text(
                      days[i],
                      style: TextStyle(
                        color: (i == 0 || i == 6)
                            ? Colors.red
                            : isDarkMode
                                ? Colors.white
                                : Colors.black,
                        fontSize: screenWidth * 0.030,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: false,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                width: screenWidth * 0.008,
                color: const Color(0xff979797),
              ),
              left: BorderSide(
                width: screenWidth * 0.008,
                color: const Color(0xff979797),
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }
}
