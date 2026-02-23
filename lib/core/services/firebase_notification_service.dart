import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tool_bocs/core/services/notification_service.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to access other Firebase services in the background,
  // ensure you call `Firebase.initializeApp()` in main.dart before this.
  debugPrint("Handling a background message: ${message.messageId}");
}

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Background Message Handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 3. Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
              'Message also contained a notification: ${message.notification}');

          // Show local notification
          _notificationService.showNotification(
            id: message.messageId.hashCode,
            title: message.notification!.title ?? 'New Message',
            body: message.notification!.body ?? '',
            payload: jsonEncode(message.data), // Pass data as payload
          );
        }
      });

      // 4. Message Opened App Handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
        // Navigation logic is handled in NotificationService.init() via onDidReceiveNotificationResponse
        // But we might need to handle it here if the app was effectively "woken up" from background to specific screen
      });

      // 5. Get and Save Token
      await saveTokenToFirestore();

      // 6. Listen for Token Refresh
      _firebaseMessaging.onTokenRefresh.listen((token) async {
        final userData = await StorageService.getUserData();
        if (userData != null) {
          final user = UserModel.fromJson(jsonDecode(userData));
          await _saveToken(token, user.id.toString());
        }
      });
    }
  }

  Future<void> saveTokenToFirestore() async {
    // Get current user
    final userData = await StorageService.getUserData();
    if (userData != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userData));
        String userId = user.id.toString();

        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveToken(token, userId);
        }
      } catch (e) {
        debugPrint("Error saving FCM token: $e");
      }
    }
  }

  Future<void> _saveToken(String token, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint("FCM Token saved to Firestore for user $userId");
  }
}
