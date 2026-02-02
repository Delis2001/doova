// messaging_handler.dart

import 'package:doova/firebase_options.dart';
import 'package:doova/model/add_task/task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doova/views/task/edit_task.dart';
import 'package:doova/main.dart'; // For navigatorKey

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Background message handler (must be top-level or static)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📡 BG message: ${message.messageId}');
}

/// Initialize local notifications plugin
Future<void> initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      debugPrint('📌 Local notification tapped with payload: $payload');

      if (payload != null && payload.isNotEmpty) {
        final task = await _fetchTaskById(payload);
        if (task != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (_) => EditTaskView(task: [task]),
            ),
          );
        } else {
          debugPrint('❌ Task not found for ID: $payload');
        }
      }
    },
  );
}

/// Initialize push notifications and handlers
void initPushMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission
  NotificationSettings settings = await messaging.requestPermission();
  debugPrint('🔑 FCM permission: ${settings.authorizationStatus}');

  // Set background handler
 if(!kIsWeb){
   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
 }

  // Foreground message handler - show local notification
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 FCM foreground message: ${message.notification?.title}');
    if(!kIsWeb){
      _showLocalNotification(message);
    }else{
      debugPrint('🌐 Web foreground message received');
      // Show in-app banner instead
    }
  });

  // When notification tapped (app opened/resumed)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    debugPrint('📲 Notification tapped!');
    final taskId = message.data['taskId'];
    if (taskId != null && taskId.isNotEmpty) {
      final task = await _fetchTaskById(taskId);
      if (task != null && !kIsWeb) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => EditTaskView(task: [task]),
          ),
        );
      } else {
        debugPrint('❌ Task not found for ID: $taskId');
      }
    }
  });
}

/// Show a local notification for foreground FCM messages
void _showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'doova_channel_id',
          'Doova Notifications',
          channelDescription: 'Doova task notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: message.data['taskId'] ?? '',
    );
  }
}

/// Helper: Fetch TaskModel by taskId from Firestore
Future<TaskModel?> _fetchTaskById(String taskId) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection('tasks').doc(taskId).get();
    if (doc.exists && doc.data() != null) {
      return TaskModel.fromMap(doc.data()!, doc.id);
    }
  } catch (e) {
    debugPrint('❌ Error fetching task by ID $taskId: $e');
  }
  return null;
}
