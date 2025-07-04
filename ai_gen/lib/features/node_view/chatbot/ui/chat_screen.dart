import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/chat_controller.dart';
import '../services/chat_service.dart';
import 'chat_header.dart';
import 'chat_input_field.dart';
import 'chat_message_list.dart';
import 'chat_workflow_buttons.dart';

class ChatScreen extends StatefulWidget {
  final ProjectModel projectModel;
  const ChatScreen({required this.projectModel, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController(
      ChatService(),
      projectId: widget.projectModel.id ?? 0,
      gridNodeViewCubit: context.read<GridNodeViewCubit>(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ChatController>(
        builder: (context, controller, _) {
          return Container(
            width: 350,
            height: MediaQuery.sizeOf(context).height * .75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ChatHeader(),
                // Chat area
                Expanded(
                  child: ChatMessageList(messages: controller.messages),
                ),
                // Workflow buttons
                ChatWorkflowButtons(
                  chatController: _controller,
                  recommendedMessages: const [
                    "Create workflow",
                    "Edit the workflow",
                    "Explain me this workflow",
                  ],
                ),
                // Input field
                ChatInputField(
                  textController: _textController,
                  isLoading: controller.isLoading,
                  onSend: _sendMessage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_controller.isLoading) {
      _controller.sendMessage(text);
      _textController.clear();
    }
  }
}
