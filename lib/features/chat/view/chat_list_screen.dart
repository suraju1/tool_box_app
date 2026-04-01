import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/shimmer_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/chat/controller/chat_service.dart';
import 'package:tool_bocs/features/chat/view/chat_screen.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/trades/model/trade_response_model.dart';
import 'dart:convert';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  String? _currentUserId;
  Stream<QuerySnapshot>? _chatRoomsStream;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userData = await StorageService.getUserData();
    if (userData != null) {
      final user = UserModel.fromJson(jsonDecode(userData));
      setState(() {
        _currentUserId = user.id.toString();
        _chatRoomsStream = _chatService.getChatRooms();
      });
    }
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(time.year, time.month, time.day);

    if (dateToCheck == today) {
      return DateFormat('hh:mm a').format(time);
    } else if (dateToCheck == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shimmer = context.watch<ShimmerController>();

    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: shimmer.isLoading
          ? _buildShimmer(context)
          : Column(
              children: [
                Container(
                  height: 65.h,
                  color: context.appBarColor,
                ),
                _buildSearchBox(context),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chatRoomsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        final error = snapshot.error.toString();
                        if (error.contains('permission-denied')) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Text(
                                'Your chats will appear here once you are logged in.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.subTextColor,
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                            ),
                          );
                        }
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmer(context);
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No chats yet',
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final lastMessage =
                              data['lastMessage'] as Map<String, dynamic>?;

                          if (lastMessage == null) {
                            return const SizedBox.shrink();
                          }

                          final timestamp =
                              lastMessage['timestamp'] as Timestamp?;
                          final timeString = timestamp != null
                              ? _formatMessageTime(timestamp.toDate())
                              : '';

                          String text = lastMessage['text'] as String? ?? '';
                          if (lastMessage['senderId'] == _currentUserId) {
                            text = "You: $text";
                          }

                          final isRead = lastMessage['isRead'] as bool? ??
                              true; // Default to true if not present for logic sake
                          // Get unread count
                          final unreadCounts =
                              data['unreadCounts'] as Map<String, dynamic>?;
                          int unreadCountInt = 0;
                          if (unreadCounts != null && _currentUserId != null) {
                            debugPrint("UnreadCounts Map: $unreadCounts");
                            debugPrint("Current User ID: $_currentUserId");
                            debugPrint(
                                "Value for Key: ${unreadCounts[_currentUserId]}");
                            unreadCountInt = unreadCounts[_currentUserId] ?? 0;
                          } else {
                            debugPrint(
                                "UnreadCounts is null or Current User ID is null");
                            debugPrint("Data: $data");
                          }

                          String unreadCountStr = '';
                          if (unreadCountInt > 0) {
                            unreadCountStr = unreadCountInt.toString();
                          } else if (unreadCounts == null &&
                              !isRead &&
                              lastMessage['senderId'] != _currentUserId) {
                            // Fallback for old messages ONLY if unreadCounts doesn't exist
                            unreadCountStr = '1';
                          }

                          // Determine other user ID (simple implementation assumes 2 users)
                          final users = List<String>.from(data['users'] ?? []);
                          final otherUserId = users.firstWhere(
                              (id) => id != _currentUserId,
                              orElse: () => 'Unknown');

                          // Determine if chat is disabled (72 hours from first message)
                          final firstMsgAt =
                              data['firstMessageAt'] as Timestamp?;
                          final lastUpdatedAt = data['updatedAt'] as Timestamp?;
                          bool isDisabled = false;

                          if (firstMsgAt != null) {
                            isDisabled = DateTime.now()
                                    .difference(firstMsgAt.toDate())
                                    .inHours >=
                                72;
                          } else if (lastUpdatedAt != null) {
                            // Fallback for existing chats without firstMessageAt:
                            // If even the LAST update is > 72 hours ago, the chat is definitely disabled.
                            isDisabled = DateTime.now()
                                    .difference(lastUpdatedAt.toDate())
                                    .inHours >=
                                72;
                          }

                          // Fetch real user name from Firestore
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(otherUserId)
                                .snapshots(),
                            builder: (context, userSnapshot) {
                              String displayName = "User $otherUserId";
                              String? otherUserImage;
                              if (userSnapshot.hasData &&
                                  userSnapshot.data!.exists) {
                                final userData = userSnapshot.data!.data()
                                    as Map<String, dynamic>?;
                                if (userData != null &&
                                    userData.containsKey('fullName')) {
                                  displayName = userData['fullName'];
                                }
                                if (userData != null &&
                                    userData.containsKey('profileImage')) {
                                  otherUserImage =
                                      userData['profileImage'] as String?;
                                }
                              }

                              final tradeDetails =
                                  data['tradeDetails'] as Map<String, dynamic>?;
                              TradeResponseModel? tradeResponse;
                              if (tradeDetails != null &&
                                  data['tradeId'] != null) {
                                tradeResponse = TradeResponseModel(
                                  id: data['tradeId'],
                                  postId: tradeDetails['postId'] ?? 0,
                                  responderId: tradeDetails['responderId'] ?? 0,
                                  posterUserId:
                                      tradeDetails['posterUserId'] ?? 0,
                                  responderName:
                                      tradeDetails['responderName'] ?? '',
                                  responseType:
                                      tradeDetails['responseType'] ?? 'item',
                                  priceRangeStart:
                                      tradeDetails['priceRangeStart']
                                          ?.toDouble(),
                                  priceRangeEnd:
                                      tradeDetails['priceRangeEnd']?.toDouble(),
                                  itemName: tradeDetails['itemName'],
                                  postItemName: tradeDetails['postItemName'],
                                  posterName: tradeDetails['posterName'],
                                  createdAt:
                                      '', // Not stored in details but required by model
                                  status:
                                      'accepted', // Assume accepted if they are chatting
                                  posterMobile: tradeDetails['posterMobile'],
                                  responderMobile:
                                      tradeDetails['responderMobile'],
                                  postType: tradeDetails['postType'],
                                );
                              }

                              Widget? subtitleWidget;
                              if (tradeResponse != null) {
                                final isOwner = context
                                        .read<AuthController>()
                                        .currentUser
                                        ?.id ==
                                    tradeResponse.posterUserId;
                                final isGivePost =
                                    tradeResponse.postType?.toLowerCase() ==
                                            'give' ||
                                        tradeResponse.postType?.toLowerCase() ==
                                            'giving';

                                final myItem = isOwner
                                    ? (isGivePost
                                        ? tradeResponse.postItemName
                                        : (tradeResponse.itemName ?? 'Price'))
                                    : (isGivePost
                                        ? (tradeResponse.itemName ?? 'Price')
                                        : tradeResponse.postItemName);
                                final theirItem = isOwner
                                    ? (isGivePost
                                        ? (tradeResponse.itemName ?? 'Price')
                                        : tradeResponse.postItemName)
                                    : (isGivePost
                                        ? tradeResponse.postItemName
                                        : (tradeResponse.itemName ?? 'Price'));

                                subtitleWidget = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(text: "Trade: "),
                                          TextSpan(
                                            text: myItem,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: " for "),
                                          TextSpan(
                                            text: theirItem,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: context.subTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: context.subTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                subtitleWidget = Text(
                                  text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: context.subTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }

                              return _buildChatItem(
                                context,
                                docs[index].id, // Pass chatRoomId
                                displayName,
                                subtitleWidget,
                                timeString,
                                unreadCountStr,
                                false, // Online status not implemented
                                otherUserImage ??
                                    '', // Actual profile image from Firestore
                                otherUserId: otherUserId,
                                tradeResponse: tradeResponse,
                                isDisabled: isDisabled,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75.h,
          color: context.appBarColor,
        ),
        Container(
          color: context.appBarColor,
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          child: ShimmerBox(height: 50.h, width: double.infinity, radius: 10.r),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 8,
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.dividerColor)),
              ),
              child: Row(
                children: [
                  ShimmerBox(height: 60.r, width: 60.r, radius: 30.r),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerBox(height: 20.h, width: 120.w),
                            ShimmerBox(height: 14.h, width: 40.w),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                                child: ShimmerBox(
                                    height: 16.h, width: double.infinity)),
                            SizedBox(width: 8.w),
                            ShimmerBox(height: 18.h, width: 18.w, radius: 6.r),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Container(
      color: context.appBarColor,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        height: 50.h,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: context.dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: context.subTextColor),
            SizedBox(width: 10.w),
            Text(
              'Search ...',
              style: TextStyle(color: context.subTextColor, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    String chatRoomId,
    String name,
    Widget messageWidget,
    String time,
    String unreadCount,
    bool isOnline,
    String imagePath, {
    required String otherUserId,
    TradeResponseModel? tradeResponse,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: chatRoomId,
              otherUserId: otherUserId,
              otherUserName: name,
              otherUserImage: imagePath.isNotEmpty ? imagePath : null,
              tradeResponse: tradeResponse,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? (context.isDarkMode ? Colors.white12 : Colors.grey.shade100)
              : null,
          border: Border(bottom: BorderSide(color: context.dividerColor)),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: isDisabled
              ? ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: _buildChatItemContent(name, imagePath, time,
                      isDisabled, messageWidget, unreadCount),
                )
              : _buildChatItemContent(name, imagePath, time, isDisabled,
                  messageWidget, unreadCount),
        ),
      ),
    );
  }

  Widget _buildChatItemContent(String name, String imagePath, String time,
      bool isDisabled, Widget messageWidget, String unreadCount) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: AppCachedImage(
            imageUrl: imagePath,
            userName: name,
            width: 60.r,
            height: 60.r,
            radius: 30.r,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isDisabled ? Colors.grey : greenColor,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Expanded(
                    child: messageWidget,
                  ),
                  if (unreadCount.isNotEmpty &&
                      unreadCount != '0' &&
                      !isDisabled)
                    Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        unreadCount,
                        style: TextStyle(
                          color: context.onPrimaryColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
