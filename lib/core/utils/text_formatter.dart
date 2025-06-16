import 'package:flutter/material.dart';
import 'package:flutter_openai_stream/models/message.dart';

Widget formattedMessage(BuildContext context, bool isDark, Message message) {
  return SelectableText.rich(
    _parseFormattedText(message.content, isDark),
    style: TextStyle(
      color: isDark ? Colors.grey[100] : Colors.grey[800],
      fontSize: 15,
      height: 1.6,
      letterSpacing: 0.2,
    ),
  );
}

TextSpan _parseFormattedText(String text, bool isDark) {
  final List<TextSpan> spans = [];
  final lines = text.split('\n');

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line.trim().isEmpty) {
      spans.add(const TextSpan(text: '\n'));
      continue;
    }

    // Handle bullet points
    if (line.trim().startsWith('*') || line.trim().startsWith('-')) {
      spans.add(_createBulletPoint(line, isDark));
    }
    // Handle numbered lists
    else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
      spans.add(_createNumberedPoint(line, isDark));
    }
    // Handle headers (lines with ** text **)
    else if (line.contains('**')) {
      spans.add(_parseMarkdown(line, isDark));
    }
    // Regular text
    else {
      spans.add(TextSpan(
        text: line,
        style: TextStyle(
          color: isDark ? Colors.grey[100] : Colors.grey[800],
        ),
      ));
    }

    // Add line break if not the last line
    if (i < lines.length - 1) {
      spans.add(const TextSpan(text: '\n'));
    }
  }

  return TextSpan(children: spans);
}

// This list of functions handles the parsing of formatted text, including bullet points,
TextSpan _createBulletPoint(String line, bool isDark) {
  final cleanLine = line.replaceFirst(RegExp(r'^\s*[\*\-]\s*'), '');
  return TextSpan(
    children: [
      TextSpan(
        text: '• ',
        style: TextStyle(
          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      _parseMarkdown(cleanLine, isDark),
    ],
  );
}

TextSpan _createNumberedPoint(String line, bool isDark) {
  final match = RegExp(r'^(\d+\.)\s*(.*)').firstMatch(line.trim());
  if (match != null) {
    return TextSpan(
      children: [
        TextSpan(
          text: '${match.group(1)} ',
          style: TextStyle(
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        _parseMarkdown(match.group(2)!, isDark),
      ],
    );
  }
  return TextSpan(text: line);
}

TextSpan _parseMarkdown(String text, bool isDark) {
  final List<TextSpan> spans = [];
  final regex = RegExp(r'\*\*(.*?)\*\*');
  int lastEnd = 0;

  for (final match in regex.allMatches(text)) {
    // Add text before the match
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: TextStyle(
          color: isDark ? Colors.grey[100] : Colors.grey[800],
        ),
      ));
    }

    // Add bold text
    spans.add(TextSpan(
      text: match.group(1),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    ));

    lastEnd = match.end;
  }

  // Add remaining text
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: TextStyle(
        color: isDark ? Colors.grey[100] : Colors.grey[800],
      ),
    ));
  }

  return TextSpan(children: spans.isEmpty ? [TextSpan(text: text)] : spans);
}