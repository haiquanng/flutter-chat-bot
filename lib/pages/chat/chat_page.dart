import 'package:flutter/material.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/chat_empty.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/chat_header.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/messages_list.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/sidebar.dart';
import 'controllers/chat_controller.dart';
import 'widgets/modern_chat_input.dart';

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

    // Handle initial message from router
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is String && extra.isNotEmpty) {
        _chatController.sendMessage(extra);
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
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

                          // Modern Chat Input (new design)
                          AnimatedBuilder(
                            animation: _chatController,
                            builder: (context, child) {
                              return ModernChatInput(
                                controller: _chatController,
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