import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  StreamSubscription? _chatSubscription;

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
    
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint("ChatListener WARNING: Firebase Auth is NULL for user $_currentUserId. Listening will likely fail.");
    } else {
      debugPrint("ChatListener: Firebase Auth UID: ${firebaseUser.uid}");
    }

    // 2. Initialize Notification Service
    await NotificationService().init();

    // 3. Listen to Chat Rooms
    _chatSubscription = FirebaseFirestore.instance
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
              final Timestamp? timestamp =
                  lastMessage['timestamp'] as Timestamp?;
              if (timestamp != null) {
                _lastMessageTimestamps[roomId] = timestamp;
              }
              continue;
            }

            final Timestamp timestamp = lastMessage['timestamp'] as Timestamp;
            final String senderId = lastMessage['senderId'].toString();
            final String text = lastMessage['text'] ?? '';

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
                // It's a new message! Update cache.
                _lastMessageTimestamps[roomId] = timestamp;

                // Try to resolve sender name from chat room document first
                final tradeDetails =
                    data['tradeDetails'] as Map<String, dynamic>?;
                _resolveAndNotify(
                  roomId: roomId,
                  senderId: senderId,
                  messageText: text,
                  tradeDetails: tradeDetails,
                );
              }
            }
          }
        }
      }
      _isFirstLoad = false;
    });
  }

  /// Resolves the sender's name (from tradeDetails or Firestore) then shows a notification.
  Future<void> _resolveAndNotify({
    required String roomId,
    required String senderId,
    required String messageText,
    Map<String, dynamic>? tradeDetails,
  }) async {
    String senderName = '';

    // 1. Try to get name from tradeDetails stored in the chat room document
    if (tradeDetails != null) {
      final posterUserId = tradeDetails['posterUserId']?.toString();
      final responderId = tradeDetails['responderId']?.toString();
      if (senderId == posterUserId) {
        senderName = (tradeDetails['posterName'] as String?)?.trim() ?? '';
      } else if (senderId == responderId) {
        senderName = (tradeDetails['responderName'] as String?)?.trim() ?? '';
      }
    }

    // 2. Fallback: fetch from Firestore users collection
    if (senderName.isEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();
        if (userDoc.exists) {
          final name = userDoc.data()?['fullName'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            senderName = name.trim();
          }
        }
      } catch (e) {
        debugPrint('ChatListener: Failed to fetch sender name: $e');
      }
    }

    // 3. Final fallback
    if (senderName.isEmpty) senderName = 'New Message';

    final body = messageText.startsWith('[IMAGE] ') ? '📷 Photo' : messageText;

    NotificationService().showNotification(
      id: roomId.hashCode,
      title: senderName,
      body: body.isNotEmpty ? body : '...',
      payload: '$roomId|$senderId|$senderName',
    );
  }

  /// Stop listening to chat rooms
  Future<void> stopListening() async {
    await _chatSubscription?.cancel();
    _chatSubscription = null;
    _isFirstLoad = true;
    _lastMessageTimestamps.clear();
    _currentUserId = null;
    debugPrint('ChatListener: Stopped listening and cleared state.');
  }
}
