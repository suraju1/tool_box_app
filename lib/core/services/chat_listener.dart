import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_bocs/core/services/notification_service.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';
import 'package:flutter/foundation.dart';

class ChatListener {
  static final ChatListener _instance = ChatListener._internal();
  factory ChatListener() => _instance;
  ChatListener._internal();

  bool _isFirstLoad = true;
  final Map<String, Timestamp> _lastMessageTimestamps = {};
  String? _currentUserId;
  // StreamSubscription? _subscription; // Keep track if we need to cancel

  static String? currentChatRoomId;

  Future<void> startListening() async {
    // 1. Get Current User ID
    final userData = await StorageService.getUserData();
    if (userData == null) return;

    try {
      final user = UserModel.fromJson(jsonDecode(userData));
      _currentUserId = user.id.toString();
    } catch (e) {
      debugPrint('Error parsing user data for ChatListener: $e');
      return;
    }

    if (_currentUserId == null) return;

    // 2. Initialize Notification Service
    await NotificationService().init();

    // 3. Listen to Chat Rooms
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('users', arrayContains: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          final lastMessage = data['lastMessage'] as Map<String, dynamic>?;

          if (lastMessage != null) {
            final String roomId = change.doc.id;
            // Check if we are currently in this chat room
            if (currentChatRoomId == roomId) {
              // We are active in this room, no need to notify
              // We should update the timestamp cache though to avoid notifying later if we leave
              final Timestamp? timestamp =
                  lastMessage['timestamp'] as Timestamp?;
              if (timestamp != null) {
                _lastMessageTimestamps[roomId] = timestamp;
              }
              continue;
            }

            final Timestamp timestamp = lastMessage['timestamp'] as Timestamp;
            final String senderId = lastMessage['senderId'].toString();
            final String text = lastMessage['text'] ?? 'New Message';

            // Ignore own messages
            if (senderId == _currentUserId) {
              _lastMessageTimestamps[roomId] = timestamp;
              continue;
            }

            // Initial Load Logic: Just populate cache
            if (_isFirstLoad) {
              _lastMessageTimestamps[roomId] = timestamp;
            } else {
              // Check for NEW message
              final lastKnownTimestamp = _lastMessageTimestamps[roomId];

              if (lastKnownTimestamp == null ||
                  timestamp.compareTo(lastKnownTimestamp) > 0) {
                // It's a new message!

                // Update cache
                _lastMessageTimestamps[roomId] = timestamp;

                // Trigger Notification
                NotificationService().showNotification(
                  id: roomId.hashCode,
                  title: 'New Message', // You might want to fetch sender name
                  body: text,
                  payload: '$roomId|$senderId',
                );
              }
            }
          }
        }
      }
      _isFirstLoad = false;
    });
  }
}
