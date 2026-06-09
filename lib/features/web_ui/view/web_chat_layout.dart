import 'package:flutter/material.dart';
import 'package:tool_bocs/features/chat/view/chat_list_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_chat_screen.dart';
import 'package:tool_bocs/features/trades/model/trade_response_model.dart';
import 'package:tool_bocs/util/colors.dart';

class WebChatLayout extends StatefulWidget {
  const WebChatLayout({super.key});

  @override
  State<WebChatLayout> createState() => _WebChatLayoutState();
}

class _WebChatLayoutState extends State<WebChatLayout> {
  String? selectedChatRoomId;
  String? selectedOtherUserId;
  String? selectedOtherUserName;
  String? selectedOtherUserImage;
  TradeResponseModel? selectedTradeResponse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Pane: Chat List
        Container(
          width: 350,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: greyColor.withOpacity(0.2))),
          ),
          child: ChatListScreen(
            onChatTap: (chatRoomId, otherUserId, otherUserName, otherUserImage, tradeResponse) {
              setState(() {
                selectedChatRoomId = chatRoomId;
                selectedOtherUserId = otherUserId;
                selectedOtherUserName = otherUserName;
                selectedOtherUserImage = otherUserImage;
                selectedTradeResponse = tradeResponse;
              });
            },
          ),
        ),
        
        // Right Pane: Active Chat Window
        Expanded(
          child: selectedChatRoomId == null
              ? _buildPlaceholder()
              : WebChatScreen(
                  // Ensure a unique key so it completely rebuilds when switching chats
                  key: ValueKey(selectedChatRoomId),
                  chatRoomId: selectedChatRoomId!,
                  otherUserId: selectedOtherUserId!,
                  otherUserName: selectedOtherUserName ?? 'User',
                  otherUserImage: selectedOtherUserImage,
                  tradeResponse: selectedTradeResponse,
                  showBackButton: false,
                ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Your Messages",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select a chat from the left to start messaging.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
