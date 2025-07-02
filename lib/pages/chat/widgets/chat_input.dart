
// import 'package:flutter/material.dart';
// import 'package:flutter_openai_stream/core/constants/app_sizes.dart';
// import 'package:flutter_openai_stream/widgets/common/chat_box.dart';

// /// A widget that provides an input box for sending messages in a chat interface without image/file upload.
// class ChatInputBox extends StatelessWidget {
//   final Function(String) onMessageSubmit;
//   final bool disabled;
//   const ChatInputBox({
//     super.key,
//     required this.onMessageSubmit,
//     this.disabled = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxHeight: 700),
//         child: ChatBox(
//           onSubmit: onMessageSubmit,
//           onAttachFile: null,
//           maxHeight: AppSizes.kChatBoxMaxHeight,
//           placeholder: "Type your message here...",
//           disabled: disabled,
//         ),
//       ),
//     );
//   }
// }