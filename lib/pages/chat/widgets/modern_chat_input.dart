import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_openai_stream/core/utils/helper.dart';
import '../controllers/chat_controller.dart';
import '../handler/image_handler.dart';

/// A modern chat input widget that supports text input, image attachment, and sending messages.
class ModernChatInput extends StatefulWidget {
  final ChatController controller;

  const ModernChatInput({
    super.key,
    required this.controller,
  });

  @override
  State<ModernChatInput> createState() => _ModernChatInputState();
}

class _ModernChatInputState extends State<ModernChatInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImageHandler _imageHandler = ImageHandler();
  
  Uint8List? _selectedImage;
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    if (widget.controller.isLoading) return;

    widget.controller.sendMessage(text, imageBytes: _selectedImage);
    _textController.clear();
    _clearImage();
    setState(() {
      _isComposing = false;
    });
  }

  void _handleStop() {
    widget.controller.stopResponse();
  }

  Future<void> _handleImagePick() async {
    try {
      final imageBytes = await _imageHandler.pickImage();
      if (imageBytes != null) {
        setState(() {
          _selectedImage = imageBytes;
        });
      }
    } catch (e) {
      if (mounted) {
        // Show error message to debug 
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Failed to pick image: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
        showToast(context: context, message: 'Failed to pick image', icon: Icons.error, iconColor: Colors.red);
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview
          if (_selectedImage != null) _buildImagePreview(),
          
          // Input area
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: widget.controller.isLoading ? null : _handleImagePick,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.attach_file_rounded,
                          color: widget.controller.isLoading
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: !widget.controller.isLoading,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: _getHintText("Type a message..."),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: (_) {
                      if (!widget.controller.isLoading) {
                        _handleSubmit();
                      }
                    },
                  ),
                ),
                
                // Send/Stop button
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: _getSendButtonColor(),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: widget.controller.isLoading ? _handleStop : 
                             (_isComposing || _selectedImage != null) ? _handleSubmit : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getSendButtonIcon(),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Helper text
          if (!widget.controller.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _getKeyboardShortcutText(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _selectedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Image ready to send',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _clearImage,
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade600,
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
    );
  }

  String _getKeyboardShortcutText() {
    // Use foundation.dart's defaultTargetPlatform which works on web
    if (kIsWeb) {
      return 'Press Shift+Enter for new line, Enter to send';
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'Press Cmd+Enter for new line, Enter to send';
      default:
        return 'Press Ctrl+Enter for new line, Enter to send';
    }
  }

  String _getHintText(String text) {
    return text;
  }

  Color _getSendButtonColor() {
    if (widget.controller.isLoading) {
      return Colors.red.shade600; // Stop button color
    }
    
    if (_isComposing || _selectedImage != null) {
      return Theme.of(context).primaryColor;
    }
    
    return Colors.grey.shade400;
  }

  IconData _getSendButtonIcon() {
    if (widget.controller.isLoading) {
      return Icons.stop_rounded;
    }
    return Icons.arrow_upward_rounded;
  }
}
