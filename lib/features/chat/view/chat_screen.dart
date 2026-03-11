import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/chat/controller/chat_service.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/user_review_dialog.dart';
import 'package:tool_bocs/features/trades/model/trade_response_model.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:tool_bocs/core/services/chat_listener.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';

class ChatScreen extends StatefulWidget {
  final String? chatRoomId;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserImage;
  final TradeResponseModel? tradeResponse;

  const ChatScreen({
    super.key,
    this.chatRoomId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserImage,
    this.tradeResponse,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserId;
  String _chatRoomId = '';

  // For simplicity, we'll initialize these. In a real app, handle loading states.
  late String otherUserName;

  @override
  void initState() {
    super.initState();
    otherUserName = widget.otherUserName ?? "Chat";
    _initializeChat();
  }

  @override
  void dispose() {
    ChatListener.currentChatRoomId = null;
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final user = await _chatService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUserId = user.id.toString();
        // If chatRoomId is passed, use it. Otherwise, generate it.
        if (widget.chatRoomId != null) {
          _chatRoomId = widget.chatRoomId!;
        } else if (widget.otherUserId != null) {
          _chatRoomId = _chatService.getChatRoomId(
            _currentUserId!,
            widget.otherUserId!,
            tradeId: widget.tradeResponse?.id,
          );
        }
      });

      if (_chatRoomId.isNotEmpty) {
        ChatListener.currentChatRoomId = _chatRoomId;
        _chatService.markMessagesAsRead(_chatRoomId, _currentUserId!);
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _currentUserId == null ||
        widget.otherUserId == null) {
      return;
    }

    // Check if chatRoomId needs to be generated (if first message)
    if (_chatRoomId.isEmpty) {
      _chatRoomId = _chatService.getChatRoomId(
        _currentUserId!,
        widget.otherUserId!,
        tradeId: widget.tradeResponse?.id,
      );
    }

    await _chatService.sendMessage(
        _chatRoomId, _messageController.text.trim(), widget.otherUserId!,
        tradeResponse: widget.tradeResponse);
    _messageController.clear();
  }

  Future<void> _sendImage() async {
    if (_currentUserId == null || widget.otherUserId == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String fileName = const Uuid().v4();

      try {
        // Upload to Firebase Storage
        var ref =
            FirebaseStorage.instance.ref().child('chat_images').child(fileName);
        await ref.putFile(file);
        String imageUrl = await ref.getDownloadURL();

        // Send message with image URL (handled as text for now, or could modify schema)
        // For this example, sending as text. Ideally, schema supports 'type': 'image'
        // We will send it as a text message containing the URL for simplicity in this iteration
        // or you can modify sendMessage to accept 'type'

        if (_chatRoomId.isEmpty) {
          _chatRoomId = _chatService.getChatRoomId(
            _currentUserId!,
            widget.otherUserId!,
            tradeId: widget.tradeResponse?.id,
          );
        }

        // Modify ChatService to handle image/text differentiation if needed.
        // For now, we prepend [IMAGE] to detect it
        await _chatService.sendMessage(
            _chatRoomId, "[IMAGE] $imageUrl", widget.otherUserId!,
            tradeResponse: widget.tradeResponse);
      } catch (e) {
        debugPrint("Error uploading image: $e");
        if (!mounted) return;
        ToastService.showErrorToast(context, 'Error uploading image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTradeStatusBanner(),
          Expanded(
            child: _chatRoomId.isEmpty || _currentUserId == null
                ? const Center(child: Text('Start a conversation'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatService.getMessages(_chatRoomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      // Mark messages as read if we have data and we are the valid user
                      if (docs.isNotEmpty &&
                          _currentUserId != null &&
                          _chatRoomId.isNotEmpty) {
                        // We defer this call to avoid build-phase side effects causing errors
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _chatService.markMessagesAsRead(
                              _chatRoomId, _currentUserId!);
                        });
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                        itemCount: docs.length,
                        // Reverse if you want latest at bottom and ListView is reversed.
                        // But here we ordered by timestamp ascending, so standard list view is fine if we scroll to bottom.
                        // Typically chat uses reverse: true and desc timestamp.
                        // Let's stick to standard for now and valid alignment.
                        itemBuilder: (_, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          return _buildMessageBubble(data);
                        },
                      );
                    },
                  ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.appBarColor,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.0.w),
        child: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: context.textColor, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Row(
          children: [
            // SizedBox(width: 10.w),
            IconButton(
              padding: EdgeInsets.only(right: 16.w),
              icon: const Icon(Icons.info_outline),
              color: context.textColor,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                      // title: Text(
                      //   '',
                      //   style: TextStyle(
                      //     color: context.textColor,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 16.sp,
                      //     fontFamily: FontFamily.openSans,
                      //   ),
                      // ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• This Chat stays on for next 48 hours.',
                            style: TextStyle(
                              color: context.textColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '• Do Not cheat, Negative remarks stays on your profile forever.',
                            style: TextStyle(
                              color: context.textColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '• Good Luck, Happy Innovation!.',
                            style: TextStyle(
                              color: context.textColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: context.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              fontFamily: FontFamily.openSans,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            //SizedBox(width: 8.w),
            IconButton(
              padding: EdgeInsets.only(right: 16.w),
              icon: const Icon(Icons.more_vert),
              color: context.textColor,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => UserReviewDialog(
                    userId: int.tryParse(widget.otherUserId ?? '0') ?? 0,
                    userName: otherUserName,
                  ),
                );
              },
            ),
          ],
        ),
      ],
      centerTitle: true,
      title: Text(
        'Message',
        style: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 15.h),
          child: InkWell(
            onTap: () {
              if (widget.otherUserId != null) {
                final int? userId = int.tryParse(widget.otherUserId!);
                if (userId != null) {
                  ProfileController.navigateToUserProfile(context, userId);
                }
              }
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28.r),
                  child: (widget.tradeResponse != null)
                      ? AppCachedImage(
                          imageUrl:
                              (context.read<AuthController>().currentUser?.id ==
                                      widget.tradeResponse!.posterUserId)
                                  ? (widget.tradeResponse!.responderImage ??
                                      widget.otherUserImage ??
                                      '')
                                  : (widget.tradeResponse!.posterImage ??
                                      widget.otherUserImage ??
                                      ''),
                          userName: otherUserName,
                          width: 56.r,
                          height: 56.r,
                          fit: BoxFit.cover,
                          radius: 28.r,
                        )
                      : (widget.otherUserImage != null &&
                              widget.otherUserImage!.isNotEmpty)
                          ? AppCachedImage(
                              imageUrl: widget.otherUserImage!,
                              userName: otherUserName,
                              width: 56.r,
                              height: 56.r,
                              fit: BoxFit.cover,
                              radius: 28.r,
                            )
                          : _buildLetterPlaceholder(otherUserName, 56.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      if (widget.tradeResponse != null) ...[
                        Builder(builder: (context) {
                          if (_currentUserId == null) {
                            return const SizedBox.shrink();
                          }
                          final trade = widget.tradeResponse!;
                          final isOwner =
                              context.read<AuthController>().currentUser?.id ==
                                  trade.posterUserId;
                          final partnerMobile = isOwner
                              ? trade.responderMobile
                              : trade.posterMobile;

                          return Text(
                            partnerMobile != null && partnerMobile.isNotEmpty
                                ? partnerMobile
                                : 'NA',
                            style: TextStyle(
                              color: context.subTextColor,
                              fontSize: 12.sp,
                              fontFamily: FontFamily.openSans,
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                //no need to show video and phone icon
                // IconButton(
                //   icon: Icon(Icons.videocam_outlined, color: context.textColor),
                //   onPressed: () {},
                // ),
                // IconButton(
                //   icon: Icon(Icons.phone_outlined, color: context.textColor),
                //   onPressed: () {},
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeStatusBanner() {
    if (widget.tradeResponse == null || _currentUserId == null) {
      return const SizedBox.shrink();
    }

    final trade = widget.tradeResponse!;
    final isOwner =
        context.read<AuthController>().currentUser?.id == trade.posterUserId;

    String givingItem = '';
    String takingItem = '';
    String partnerName = '';

    final isGivePost = trade.postType?.toLowerCase() == 'give' ||
        trade.postType?.toLowerCase() == 'giving';

    partnerName = otherUserName;

    if (isOwner) {
      if (isGivePost) {
        givingItem = trade.postItemName ?? 'Item';
        takingItem = trade.responseType.toLowerCase() == 'price'
            ? '₹${trade.priceRangeStart} - ₹${trade.priceRangeEnd}'
            : (trade.itemName ?? 'Item');
      } else {
        givingItem = trade.responseType.toLowerCase() == 'price'
            ? '₹${trade.priceRangeStart} - ₹${trade.priceRangeEnd}'
            : (trade.itemName ?? 'Item');
        takingItem = trade.postItemName ?? 'Item';
      }
    } else {
      //actual owner name
      if (isGivePost) {
        givingItem = trade.responseType.toLowerCase() == 'price'
            ? '₹${trade.priceRangeStart} - ₹${trade.priceRangeEnd}'
            : (trade.itemName ?? 'Item');
        takingItem = trade.postItemName ?? 'Item';
      } else {
        givingItem = trade.postItemName ?? 'Item';
        takingItem = trade.responseType.toLowerCase() == 'price'
            ? '₹${trade.priceRangeStart} - ₹${trade.priceRangeEnd}'
            : (trade.itemName ?? 'Item');
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.tradeDetails,
          arguments: trade.id,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.white10 : const Color(0xFFF1F6FF),
          border: Border(
            bottom: BorderSide(color: context.dividerColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.swap_horiz, color: context.primaryColor, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.textColor,
                    fontFamily: FontFamily.openSans,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    const TextSpan(text: "You chose "),
                    TextSpan(
                      text: "Giving $givingItem to $partnerName ",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                    const TextSpan(text: "and "),
                    TextSpan(
                      text: "Taking $takingItem ",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                    const TextSpan(text: "in return"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final String senderId = msg['senderId'].toString();
    final bool isMe = senderId == _currentUserId;
    final Timestamp? timestamp = msg['timestamp'];
    final String time =
        timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : '';
    String text = msg['text'] ?? '';
    bool isImage = false;

    // Check for image prefix
    if (text.startsWith("[IMAGE] ")) {
      isImage = true;
      text = text.substring(8); // Remove prefix
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1D5CBB) : context.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            isImage
                ? Image.network(
                    text,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, color: context.onPrimaryColor),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                          width: 150,
                          height: 150,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: context.onPrimaryColor)));
                    },
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : context.textColor,
                      fontSize: 14,
                    ),
                  ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : context.subTextColor,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: (msg['isRead'] ?? false)
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          //no need to show attachment icon
          // IconButton(
          //   icon: Icon(Icons.attach_file, color: context.primaryColor, size: 28),
          //   onPressed: _showAttachmentMenu,
          // ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white10
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message ...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: context.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: context.onPrimaryColor, size: 20),
              onPressed: _sendMessage,
            ),
          )
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _attachmentItem(Icons.camera_alt, 'Camera', Colors.lightBlue,
                onTap: _sendImage),
            _attachmentItem(Icons.image, 'Gallery', Colors.lightBlue,
                onTap: _sendImage),
            // Add other items logic later
            _attachmentItem(Icons.mic, 'Record', Colors.grey),
            _attachmentItem(Icons.person, 'Contact', Colors.grey),
            _attachmentItem(Icons.location_on, 'My Location', Colors.grey),
            _attachmentItem(Icons.insert_drive_file, 'Document', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
        onTap: () {
          Navigator.pop(context);
          if (onTap != null) onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textColor,
              ),
            ),
          ],
        ));
  }

  Widget _buildLetterPlaceholder(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.trim().isNotEmpty
            ? name.trim().substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
          color: context.primaryColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
