import 'package:flutter/material.dart';
import 'package:flutter_openai_stream/core/utils/id_generator.dart';
import 'package:flutter_openai_stream/widgets/common/chat_box.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/sidebar.dart';
import '../../widgets/suggestion_cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  void _handleMessageSubmit(String message) {
    if (message.trim().isNotEmpty) {
      final chatId = generateChatId();
      context.go('/chat/$chatId', extra: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Row(
        children: [
          const SideBar(),
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
                            
                            const SizedBox(height: 12),
                            
                            // Subtitle
                            Text(
                              'Ask a clinical question or type \'/\' for commands',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Chat Input
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700),
                              child: ChatBox(
                                onSubmit: _handleMessageSubmit,
                                placeholder: 'Message AI Assistant...',
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Suggestion Cards
                            const SuggestionCards(),
                            
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Footer
                  _buildFooter(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 12,
        children: [
          'Pro',
          'Enterprise',
          'Store',
          'Blog',
          'Careers',
          'Privacy Policy',
          'Terms of Service',
        ].map((text) => Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        )).toList(),
      ),
    );
  }
}