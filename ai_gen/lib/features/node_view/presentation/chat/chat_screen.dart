import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../data/services/chat_service.dart';
import '../controller/chat_controller.dart';

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
            height: 700,
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(AssetsPaths.projectLogoIcon),
                          const SizedBox(width: 8),
                          const Text('AINO', style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chat area
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      final isUser = msg.sender == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isUser ? AppColors.grey200 : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Text(msg.text, style: AppTextStyles.black14Bold),
                        ),
                      );
                    },
                  ),
                ),
                // Workflow buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _controller.sendMessage("Create workflow");
                        },
                        child: const Text('Create workflow'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _controller.sendMessage('Edit the workflow');
                        },
                        child: const Text('Edit the workflow'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _controller.sendMessage('Explain me this workflow');
                        },
                        child: const Text('Explain me this workflow'),
                      ),
                    ],
                  ),
                ),
                // Input field
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !controller.isLoading,
                          decoration: InputDecoration(
                            hintText: 'Ask anything',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (value) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      controller.isLoading
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_upward,
                                  color: Colors.blueAccent),
                              onPressed: _sendMessage,
                            ),
                    ],
                  ),
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
