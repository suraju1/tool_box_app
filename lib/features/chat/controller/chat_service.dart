import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      debugPrint("sendMessage Error: $e");
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
      String chatRoomId, String currentUserId) async {
    try {
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
      debugPrint("markMessagesAsRead Error: $e");
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get chat rooms stream for current user
  Stream<QuerySnapshot> getChatRooms() async* {
    UserModel? currentUser = await getCurrentUser();
    if (currentUser == null) yield* const Stream.empty();

    yield* _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUser!.id.toString())
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Get total unread count stream
  Stream<int> getTotalUnreadCount() async* {
    UserModel? currentUser = await getCurrentUser();
    if (currentUser == null) {
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
