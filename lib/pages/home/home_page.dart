// pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_openai_stream/core/utils/id_generator.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/chat_input.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../widgets/common/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleMessageSubmit(String message, {Uint8List? imageBytes}) {
    if (message.trim().isNotEmpty || imageBytes != null) {
      final chatId = generateChatId();
      
      // Create initial message data to pass to chat page
      final initialMessage = {
        'text': message,
        'imageBytes': imageBytes,
      };
      
      context.go('/chat/$chatId', extra: initialMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            isCollapsed: _isSidebarCollapsed,
            onToggle: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            
                            // Main Title
                            Text(
                              'How can I help you today?',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Unified Chat Input - can switch between classic and modern
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700),
                              child: ChatInput(
                                onSubmit: _handleMessageSubmit,
                                placeholder: 'Message AI Assistant...',
                                mode: ChatInputMode.homepage,
                                style: ChatInputStyle.modern, // or ChatInputStyle.classic
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Suggestion Cards (if you have them)
                            // const SuggestionCards(),
                            
                            // const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}