import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController textController;
  final bool isLoading;
  final VoidCallback onSend;
  const ChatInputField({
    required this.textController,
    required this.isLoading,
    required this.onSend,
    super.key,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.textController,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: 'Ask anything',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          const SizedBox(width: 8),
          widget.isLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon:
                      const Icon(Icons.arrow_upward, color: Colors.blueAccent),
                  onPressed: widget.onSend,
                ),
        ],
      ),
    );
  }
}
