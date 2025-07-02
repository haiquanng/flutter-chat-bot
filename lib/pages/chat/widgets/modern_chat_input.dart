// widgets/chat/modern_chat_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openai_stream/core/utils/helper.dart';
import 'package:flutter_openai_stream/pages/chat/controllers/chat_controller.dart';
import 'package:flutter_openai_stream/pages/chat/handler/image_handler.dart';
import 'package:flutter_openai_stream/pages/chat/widgets/image_preview.dart';

/// A modern chat input widget that supports text input, image attachment, and sending messages.
/// Layout inspired by Grok/Claude with text area on top and controls below.
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
        showToast(
            context: context,
            message: 'Failed to pick image',
            icon: Icons.error,
            iconColor: Colors.red);
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main input container - Grok/Claude style
          _buildInputContainer(theme, isDark),
          // Helper text
          if (!widget.controller.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                KeyboardShortcutHelper.getShortcutText(),
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

  Widget _buildInputContainer(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus
              // ignore: deprecated_member_use
              ? theme.primaryColor.withOpacity(0.5)
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Text input area (Row 1)
          _buildTextInputArea(),

          // Controls area (Row 2)
          _buildControlsArea(),
        ],
      ),
    );
  }

  Widget _buildTextInputArea() {
    final hasImage = _selectedImage != null;

    return Container(
      constraints: BoxConstraints(
        minHeight: hasImage ? 80 : 48, // Expand when image is present
        maxHeight: 200,
      ),
      padding: EdgeInsets.fromLTRB(
          hasImage ? 8 : 16, // Less left padding when image is present
          12,
          16,
          8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview in top-left
          if (hasImage)
            ImagePreview(
              imageBytes: _selectedImage!,
              onClear: _clearImage,
            ),

          // Text input
          Expanded(
            // ignore: deprecated_member_use
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              // ignore: deprecated_member_use
              onKey: (RawKeyEvent event) {
                // ignore: deprecated_member_use
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    // ignore: deprecated_member_use
                    !event.isShiftPressed) {
                  _handleSubmit();
                }
              },
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
          ),
        ],
      ),
    );
  }

  Widget _buildControlsArea() {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Attachment button
          _buildAttachmentButton(),

          const Spacer(),

          // Send/Stop button
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.controller.isLoading ? null : _handleImagePick,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
    );
  }

  String _getHintText(String defaultText) {
    return defaultText;
  }

  Widget _buildSendButton() {
    final canSend = _isComposing || _selectedImage != null;
    final isActive = widget.controller.isLoading || canSend;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: _getSendButtonColor(isActive),
        borderRadius: BorderRadius.circular(18),
        elevation: isActive ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.controller.isLoading
              ? _handleStop
              : canSend
                  ? _handleSubmit
                  : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              widget.controller.isLoading
                  ? Icons.stop_rounded
                  : Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Color _getSendButtonColor(bool isActive) {
    if (widget.controller.isLoading) {
      return Colors.red.shade600;
    }

    if (isActive) {
      return Theme.of(context).primaryColor;
    }

    return Colors.grey.shade400;
  }
}
