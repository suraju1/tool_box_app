import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:tool_bocs/features/trades/model/trade_response_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user details from local storage
  Future<UserModel?> getCurrentUser() async {
    final userData = await StorageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Send message
  Future<void> sendMessage(String chatRoomId, String message, String receiverId,
      {TradeResponseModel? tradeResponse}) async {
    try {
      UserModel? currentUser = await getCurrentUser();
      if (currentUser == null) {
        debugPrint("sendMessage: Current user is null");
        return;
      }
      String currentUserId = currentUser.id.toString();
      debugPrint(
          "sendMessage: Sending from $currentUserId to $receiverId in $chatRoomId");

      final Timestamp timestamp = Timestamp.now();

      // Create a new message
      Map<String, dynamic> msgData = {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'text': message,
        'timestamp': timestamp,
        'isRead': false,
      };

      // Add new message to 'messages' subcollection
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(msgData);

      // Update logic: Try to update first (handles existing docs + atomic increment properly)
      try {
        debugPrint(
            "sendMessage: Attempting UPDATE for unreadCounts.$receiverId");
        await _firestore.collection('chat_rooms').doc(chatRoomId).update({
          'users': FieldValue.arrayUnion([currentUserId, receiverId]),
          'lastMessage': {
            'senderId': currentUserId,
            'text': message,
            'timestamp': timestamp,
            'isRead': false,
            'status': 'sent',
          },
          'updatedAt': timestamp,
          'unreadCounts.$receiverId': FieldValue.increment(1),
          if (tradeResponse != null) ...{
            'tradeId': tradeResponse.id,
            'tradeDetails': {
              'itemName': tradeResponse.itemName,
              'postItemName': tradeResponse.postItemName,
              'posterName': tradeResponse.posterName,
              'responderName': tradeResponse.responderName,
              'responseType': tradeResponse.responseType,
              'priceRangeStart': tradeResponse.priceRangeStart,
              'priceRangeEnd': tradeResponse.priceRangeEnd,
              'posterUserId': tradeResponse.posterUserId,
              'responderId': tradeResponse.responderId,
              'posterMobile': tradeResponse.posterMobile,
              'responderMobile': tradeResponse.responderMobile,
              'postType': tradeResponse.postType,
            }
          }
        });
        debugPrint("sendMessage: UPDATE complete");
      } catch (e) {
        // If update fails (likely doc doesn't exist), use SET to create it
        debugPrint("sendMessage: UPDATE failed ($e), attempting SET");
        await _firestore.collection('chat_rooms').doc(chatRoomId).set({
          'users': [currentUserId, receiverId],
          'lastMessage': {
            'senderId': currentUserId,
            'text': message,
            'timestamp': timestamp,
            'isRead': false,
            'status': 'sent',
          },
          'updatedAt': timestamp,
          'unreadCounts': {
            receiverId: 1, // Initial count
            currentUserId: 0,
          },
          'firstMessageAt': timestamp, // Set this once when the room is created
          if (tradeResponse != null) ...{
            'tradeId': tradeResponse.id,
            'tradeDetails': {
              'itemName': tradeResponse.itemName,
              'postItemName': tradeResponse.postItemName,
              'posterName': tradeResponse.posterName,
              'responderName': tradeResponse.responderName,
              'responseType': tradeResponse.responseType,
              'priceRangeStart': tradeResponse.priceRangeStart,
              'priceRangeEnd': tradeResponse.priceRangeEnd,
              'posterUserId': tradeResponse.posterUserId,
              'responderId': tradeResponse.responderId,
              'posterMobile': tradeResponse.posterMobile,
              'responderMobile': tradeResponse.responderMobile,
              'postType': tradeResponse.postType,
            }
          }
        });
        debugPrint("sendMessage: SET complete");
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        debugPrint(
            "sendMessage PERMISSION_DENIED: The user does not have permission to write to chat_rooms or messages. Please check Firestore rules.");
      } else {
        debugPrint("sendMessage Error: $e");
      }
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
      String chatRoomId, String currentUserId) async {
    try {
      // 0. Check if there's anything to update to avoid redundant writes/looping
      final roomDoc =
          await _firestore.collection('chat_rooms').doc(chatRoomId).get();
      if (roomDoc.exists) {
        final data = roomDoc.data() as Map<String, dynamic>;
        final unreadCounts = data['unreadCounts'] as Map<String, dynamic>?;
        if (unreadCounts != null && unreadCounts[currentUserId] == 0) {
          debugPrint(
              "markMessagesAsRead: Count is already 0 for $currentUserId. Skipping update.");
          return;
        }
      }

      debugPrint(
          "markMessagesAsRead: Resetting count for $currentUserId in $chatRoomId");
      // 1. Reset unread count for current user
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'unreadCounts.$currentUserId': 0,
      });

      // 2. Mark unread messages as read
      var snapshot = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'isRead': true, 'status': 'read'});
        }
        await batch.commit();
        debugPrint(
            "markMessagesAsRead: Marked ${snapshot.docs.length} messages as read");
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        debugPrint(
            "markMessagesAsRead PERMISSION_DENIED: The user does not have permission to update chat_rooms. Please check Firestore rules.");
      } else {
        debugPrint("markMessagesAsRead Error: $e");
      }
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    if (FirebaseAuth.instance.currentUser == null) {
      debugPrint(
          "getMessages: No Firebase user signed in. Returning empty stream.");
      return const Stream.empty();
    }
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          "getMessages FULL LOG for $chatRoomId: ${snapshot.docs.map((e) => e.data()).toList()}");
      return snapshot;
    }).asBroadcastStream(); // Firestore snapshots are broadcast-friendly
  }

  // Get chat rooms stream for current user
  Stream<QuerySnapshot> getChatRooms() async* {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        debugPrint("getChatRooms: No local user data found.");
        yield* Stream.error('permission-denied');
        return;
      }

      if (FirebaseAuth.instance.currentUser == null) {
        debugPrint("getChatRooms: No Firebase user signed in. Attempting anonymous sign-in...");
        try {
          await FirebaseAuth.instance.signInAnonymously();
        } catch (error) {
          debugPrint("getChatRooms anonymous sign-in error: $error");
          yield* Stream.error('permission-denied');
          return;
        }
      }

      final String userId = currentUser.id.toString();
      debugPrint("getChatRooms: Auth ready. Fetching rooms where 'users' contains $userId");

      yield* _firestore
          .collection('chat_rooms')
          .where('users', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        debugPrint("getChatRooms FULL LOG: ${snapshot.docs.map((e) => e.data()).toList()}");
        return snapshot;
      });
    } catch (e) {
      debugPrint("getChatRooms Error: $e");
      yield* Stream.error('permission-denied');
    }
  }

  // Get total unread count stream
  Stream<int> getTotalUnreadCount() async* {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        yield 0;
        return;
      }

      if (FirebaseAuth.instance.currentUser == null) {
        debugPrint("getTotalUnreadCount: No Firebase user. Yielding 0.");
        yield 0;
        return;
      }

      String currentUserId = currentUser.id.toString();

      yield* _firestore
          .collection('chat_rooms')
          .where('users', arrayContains: currentUserId)
          .snapshots()
          .map((snapshot) {
        int total = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final unreadCounts = data['unreadCounts'] as Map<String, dynamic>?;
          if (unreadCounts != null) {
            total += (unreadCounts[currentUserId] as int? ?? 0);
          }
        }
        return total;
      });
    } catch (e) {
      debugPrint("getTotalUnreadCount Error: $e");
      yield 0;
    }
  }

  // Generate chat room ID (for 1-on-1 chat)
  String getChatRoomId(String userId1, String userId2, {int? tradeId}) {
    String baseId;
    if (userId1.hashCode <= userId2.hashCode) {
      baseId = '${userId1}_$userId2';
    } else {
      baseId = '${userId2}_$userId1';
    }

    // If tradeId is provided, append it to allow multiple trades between same users
    return tradeId != null ? '${baseId}_t$tradeId' : baseId;
  }

  // Method to mark messages as read could go here
}
