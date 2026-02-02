
import 'package:installed_apps/app_info.dart';

class AppUsageModel {
  final String packageName;
  final String appName;
  final Duration usageTime;
  final AppInfo? appDetails;


  AppUsageModel({
    required this.packageName,
    required this.appName,
    required this.usageTime,
    this.appDetails,
  });
}
