import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/chat_provider.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Historique des conversations')),
      body: conversationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [SkeletonLoader(height: 60), SizedBox(height: 10), SkeletonLoader(height: 60)],
          ),
        ),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Impossible de charger l\'historique',
          message: error is Failure ? error.message : null,
        ),
        data: (conversations) => conversations.isEmpty
            ? EmptyState(
                icon: Icons.forum_outlined,
                title: 'Aucune conversation pour le moment',
                actionLabel: 'Ouvrir le chat',
                onAction: () => context.go(RoutePaths.chat),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: conversations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final conv = conversations[i];
                  return Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final failure =
                            await ref.read(chatControllerProvider).openConversation(conv.id);
                        if (!context.mounted) return;
                        if (failure != null) {
                          context.showSnack(failure.message, isError: true);
                        } else {
                          context.go(RoutePaths.chat);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.greenSoft,
                              child: Icon(Icons.forum_rounded, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Conversation', style: context.textTheme.titleMedium),
                                  if (conv.dateDerniereActivite != null)
                                    Text(
                                      'Dernière activité : ${DateFormatter.relative(conv.dateDerniereActivite!)}',
                                      style: context.textTheme.labelSmall,
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
