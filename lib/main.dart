import 'package:chat_service/firebase_options.dart';
import 'package:chat_service/services/auth/auth_gate.dart';
import 'package:chat_service/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import for local notifications
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin(); // Initialize plugin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Configure Local Notifications (for foreground)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Listen to foreground messages
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   _showNotification(message); // Show notification when in foreground
  // });

  // Background messages (iOS/Android)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
        create: (context) => ThemeProvider(), child: const MyApp()),
  );
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// Function to display local notifications when app is in the foreground
// void _showNotification(RemoteMessage message) async {
//   const AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails(
//     'channel_id', // Channel ID for notification
//     'channel_name', // Channel Name
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: true,
//   );
//   const NotificationDetails notificationDetails =
//       NotificationDetails(android: androidNotificationDetails);

//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     message.notification?.title, // Notification Title
//     message.notification?.body, // Notification Body
//     notificationDetails,
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
