import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/ia_response_card.dart';
import '../../../../shared/widgets/loading_dots.dart';
import '../../domain/entities/message_ia.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    _scrollToBottom();
    await ref.read(chatControllerProvider).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isStreaming = ref.watch(chatIsStreamingProvider);

    ref.listen(chatStreamingTextProvider, (_, _) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assistant IA'),
        actions: [
          IconButton(
            tooltip: 'Historique des conversations',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(RoutePaths.chatHistory),
          ),
          IconButton(
            tooltip: 'Nouvelle conversation',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => ref.read(chatControllerProvider).startNewConversation(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !isStreaming
                ? const _ChatWelcome()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length + (isStreaming ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: _StreamingBubble(),
                        );
                      }
                      final message = messages[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: message.role == MessageRole.user
                            ? UserMessageBubble(text: message.contenu)
                            : IaResponseCard(
                                text: message.contenu,
                                sources: message.sources,
                              ),
                      );
                    },
                  ),
          ),
          _ChatInputBar(controller: _inputController, onSend: _send, enabled: !isStreaming),
        ],
      ),
    );
  }
}

/// Bulle en cours de streaming — le SEUL widget qui se reconstruit à chaque
/// token reçu, grâce à l'isolation dans [chatStreamingTextProvider] (§8).
class _StreamingBubble extends ConsumerWidget {
  const _StreamingBubble();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(chatStreamingTextProvider) ?? '';
    return IaResponseCard(text: text, isStreaming: true);
  }
}

class _ChatWelcome extends StatelessWidget {
  const _ChatWelcome();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Bonjour 👋 Posez-moi une question sur les universités, bourses, '
              'logements ou formations du Sénégal.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({required this.controller, required this.onSend, required this.enabled});

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre question...',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (!enabled)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: LoadingDots(),
              )
            else
              IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
