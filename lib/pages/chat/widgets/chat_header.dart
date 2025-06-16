import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatHeader extends StatelessWidget {
  final String chatId;

  const ChatHeader({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            // ignore: deprecated_member_use
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Chat $chatId',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
          ),
        ],
      ),
    );
  }
}
