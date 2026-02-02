import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_usage/app_usage.dart';
import 'package:collection/collection.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:doova/model/focus/app_usage.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final String networkMessage =
    'No internet connection. Connect to the internet and try again';

class UserFocusState {
  bool isFocusing;
  int seconds;
  DateTime? startTime;
  Timer? timer;

  UserFocusState({
    this.isFocusing = false,
    this.seconds = 0,
    this.startTime,
    this.timer,
  });

  void cancelTimer() {
    timer?.cancel();
    timer = null;
  }
}

class FocusModeProvider extends ChangeNotifier {
  // ---------------------------
  // Usage stats
  // ---------------------------
  List<AppUsageModel> _usages = [];
  final AppUsage _appUsage = AppUsage();

  bool _hasPermission = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<AppUsageModel> get usages => _usages;
  bool get hasPermission => _hasPermission;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // Future<void> checkPermission() async {
  //   _hasPermission = await UsageStats.checkUsagePermission() ?? false;
  //   notifyListeners();
  // }

  // Future<void> requestPermission() async {
  //   final intent = AndroidIntent(
  //     action: 'android.settings.USAGE_ACCESS_SETTINGS',
  //   );
  //   await intent.launch();
  //   await checkPermission();
  // }

  // Future<void> fetchUsageStats({
  //   required DateTime start,
  //   required DateTime end,
  // }) async {
  //   notifyListeners();
  //   List<UsageInfo> usageStats = await UsageStats.queryUsageStats(start, end);

  //   List<AppInfo> installedApps = await InstalledApps.getInstalledApps(
  //     withIcon: true, // include app icons
  //     excludeNonLaunchableApps:
  //         false, // set true if you only want apps the user can open
  //     excludeSystemApps: false, // set true to ignore system apps
  //     packageNamePrefix: null, // optional: filter apps by package name prefix
  //     platformType: null, // optional: 'android' or 'ios', null = all
  //   );
  //   _usages = usageStats
  //       .where((u) =>
  //           u.packageName != null &&
  //           int.tryParse(u.totalTimeInForeground ?? '0') != null)
  //       .map((u) {
  //         final matchingApp = installedApps.firstWhereOrNull(
  //           (app) => app.packageName == u.packageName,
  //         );

  //         return AppUsageModel(
  //           packageName: u.packageName!,
  //           appName: matchingApp?.name ?? u.packageName!,
  //           usageTime: Duration(
  //             milliseconds: int.tryParse(u.totalTimeInForeground!) ?? 0,
  //           ),
  //           appDetails: matchingApp,
  //         );
  //       })
  //       .where((u) => u.usageTime.inMinutes > 0)
  //       .toList();

  //   _startDate = start;
  //   _endDate = end;

  //   notifyListeners();
  // }

  Future<void> checkPermission() async {
    try {
      await _appUsage.getAppUsage(
        DateTime.now().subtract(const Duration(seconds: 1)),
        DateTime.now(),
      );
      _hasPermission = true;
    } catch (_) {
      _hasPermission = false;
    }

    notifyListeners();
  }

  Future<void> requestPermission() async {
    final intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
    );
    await intent.launch();

    // Small delay to let user grant permission
    await Future.delayed(const Duration(seconds: 1));
    await checkPermission(); // updates _hasPermission & notifies UI
  }

  Future<void> fetchUsageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    notifyListeners();

    // Get installed apps
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(
      withIcon: true,
      excludeNonLaunchableApps: false,
      excludeSystemApps: false,
    );

    // Get usage data using the AppUsage instance
    List<AppUsageInfo> usageStats = [];
    try {
      usageStats = await _appUsage.getAppUsage(start, end);
      _hasPermission = true;
    } catch (e) {
      _hasPermission = false;
      debugPrint("Permission denied or error fetching usage: $e");
    }

    // Map usage data to your AppUsageModel
    _usages = usageStats
        .map((u) {
          final matchingApp = installedApps.firstWhereOrNull(
            (app) => app.packageName == u.packageName,
          );

          return AppUsageModel(
            packageName: u.packageName,
            appName: matchingApp?.name ?? u.packageName,
            usageTime: u.usage, // Already Duration
            appDetails: matchingApp,
          );
        })
        .where((u) => u.usageTime.inMinutes > 0)
        .toList();

    _startDate = start;
    _endDate = end;

    notifyListeners();
  }

  String formatRangeLabel() {
    final sameDay = _startDate.year == _endDate.year &&
        _startDate.month == _endDate.month &&
        _startDate.day == _endDate.day;

    if (sameDay) {
      return "today";
    } else {
      return "${_formatDate(_startDate)} - ${_formatDate(_endDate)}";
    }
  }

  String _formatDate(DateTime date) {
    return "${_monthName(date.month)} ${date.day}";
  }

  String _monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month];
  }

  // ---------------------------
  // FOCUS MODE CORE PER USER
  // ---------------------------

  /// Store per-user focus state keyed by user UID
  final Map<String, UserFocusState> _userFocusStates = {};

  UserFocusState _getCurrentUserFocusState() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("No logged-in user");
    }
    return _userFocusStates.putIfAbsent(uid, () => UserFocusState());
  }

  bool get isFocusing {
    try {
      return _getCurrentUserFocusState().isFocusing;
    } catch (_) {
      return false;
    }
  }

  int get seconds {
    try {
      return _getCurrentUserFocusState().seconds;
    } catch (_) {
      return 0;
    }
  }

  /// Focus time spent today (hours for last 7 days)
  List<double> dailyFocusHours = List.filled(7, 0);

  Future<void> startFocus(BuildContext context) async {
    if (!await hasNetwork()) {
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }
    final state = _getCurrentUserFocusState();

    // Cancel any existing timer to avoid duplicates
    state.cancelTimer();

    state.startTime = DateTime.now();
    state.seconds = 0;
    state.isFocusing = true;

    state.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state.seconds++;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> stopFocus() async {
    final state = _getCurrentUserFocusState();

    state.cancelTimer();
    state.isFocusing = false;

    final endTime = DateTime.now();
    final duration = state.seconds;

    if (state.startTime != null && duration > 0) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && await hasNetwork()) {
        await FirebaseFirestore.instance.collection('focus_sessions').add({
          'userId': uid,
          'start': state.startTime!.toIso8601String(),
          'end': endTime.toIso8601String(),
          'duration': duration,
        });
      } else {
        debugPrint("No network — focus session not saved remotely.");
      }
    }

    state.seconds = 0;
    state.startTime = null;

    await fetchDailyFocusHours();

    notifyListeners();
  }

  /// Fetch daily focus hours for the current user over the last 7 days
  Future<void> fetchDailyFocusHours() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final snapshot = await FirebaseFirestore.instance
        .collection('focus_sessions')
        .where('userId', isEqualTo: uid)
        .where('start', isGreaterThan: weekAgo.toIso8601String())
        .get();

    dailyFocusHours = List.filled(7, 0);
    for (var doc in snapshot.docs) {
      final start = DateTime.parse(doc['start']);
      final duration = doc['duration'] as int;

      int weekday = start.weekday % 7; // Sunday = 0
      dailyFocusHours[weekday] += duration / 3600; // seconds → hours
    }

    notifyListeners();
  }

  /// Call this when user logs out or switches users to clear focus state
  void resetFocusForCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final state = _userFocusStates[uid];
    if (state != null) {
      state.cancelTimer();
    }
    _userFocusStates.remove(uid);
    notifyListeners();
  }
}
