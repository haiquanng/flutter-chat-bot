// pages/chat/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/chat_empty.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/chat_header.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/chat_input.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/messages_list.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../widgets/common/sidebar.dart';
import 'controllers/chat_controller.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _chatController;
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController();

    // Handle initial message from router with proper delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialMessage();
    });
  }

  void _handleInitialMessage() {
    final extra = GoRouterState.of(context).extra;
    
    if (extra != null) {
      // Handle both old string format and new map format
      if (extra is String && extra.isNotEmpty) {
        // Legacy support for old string-based navigation
        _chatController.sendMessage(extra);
      } else if (extra is Map<String, dynamic>) {
        // New format with both text and image support
        final text = extra['text'] as String? ?? '';
        final imageBytes = extra['imageBytes'] as Uint8List?;
        
        if (text.isNotEmpty || imageBytes != null) {
          _chatController.sendMessage(text, imageBytes: imageBytes);
        }
      }
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _handleMessageSubmit(String message, {Uint8List? imageBytes}) {
    _chatController.sendMessage(message, imageBytes: imageBytes);
  }

  void _handleStop() {
    _chatController.stopResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SideBar(
            isCollapsed: _isSidebarCollapsed,
            onToggle: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),

          // Main chat area
          Expanded(
            child: Column(
              children: [
                // Chat Header
                ChatHeader(chatId: widget.chatId),
                
                // Messages Area
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Messages
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _chatController,
                              builder: (context, child) {
                                return _chatController.messages.isEmpty
                                    ? const ChatEmptyState()
                                    : MessagesList(
                                        messages: _chatController.messages,
                                        scrollController: _chatController.scrollController,
                                      );
                              },
                            ),
                          ),
                          
                          // Unified Chat Input for chat mode
                          AnimatedBuilder(
                            animation: _chatController,
                            builder: (context, child) {
                              return ChatInput(
                                onSubmit: _handleMessageSubmit,
                                onStop: _handleStop,
                                placeholder: 'Type a message...',
                                disabled: false,
                                isLoading: _chatController.isLoading,
                                mode: ChatInputMode.chat,
                                style: ChatInputStyle.modern,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}