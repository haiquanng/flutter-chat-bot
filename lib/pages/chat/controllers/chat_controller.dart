import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/message.dart';
import '../../../core/utils/scroll.dart';
import 'dart:async';

class ChatController extends ChangeNotifier {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  String _selectedModel = 'gemini';
  StreamSubscription? _currentStream;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  ScrollController get scrollController => _scrollController;
  bool get isLoading => _isLoading;
  String get selectedModel => _selectedModel;

  @override
  void dispose() {
    _scrollController.dispose();
    _currentStream?.cancel();
    super.dispose();
  }

  // Change model
  void changeModel(String newModel) {
    if (_selectedModel != newModel) {
      _selectedModel = newModel;
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imageBytes == null) return;
    if (_isLoading) return;

    // Add user message
    _addMessage(Message(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
      modelName: _selectedModel,
    ));

    // Add loading message
    _addMessage(Message(
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
      modelName: _selectedModel,
    ));

    _setLoading(true);
    scrollToBottom(_scrollController);

    try {
      String response = '';
      
      _currentStream = ApiService.getChatResponseStream(
        text: text,
        modelName: _selectedModel,
        imageBytes: imageBytes,
      ).listen(
        (chunk) {
          response += chunk;
          _updateLastMessage(Message(
            content: response.trim(),
            isUser: false,
            timestamp: DateTime.now(),
            isLoading: false,
            modelName: _selectedModel,
          ));
        },
        onError: (error) {
          _updateLastMessage(Message(
            content: 'Sorry, I encountered an error. Please try again.\nError: ${error.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
            isLoading: false,
            modelName: _selectedModel,
          ));
          _setLoading(false);
        },
        onDone: () {
          _setLoading(false);
        },
      );
    } catch (e) {
      _updateLastMessage(Message(
        content: 'Sorry, I encountered an error. Please try again.\nError: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: false,
        modelName: _selectedModel,
      ));
      _setLoading(false);
    }
  }

  // Stop current response
  void stopResponse() {
    _currentStream?.cancel();
    _currentStream = null;
    
    if (_messages.isNotEmpty && _messages.last.isLoading) {
      _updateLastMessage(Message(
        content: _messages.last.content.isEmpty 
            ? 'Response stopped by user.' 
            : _messages.last.content,
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: false,
        modelName: _selectedModel,
      ));
    }
    
    _setLoading(false);
  }

  // Private methods
  void _addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void _updateLastMessage(Message message) {
    if (_messages.isNotEmpty) {
      _messages[_messages.length - 1] = message;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}