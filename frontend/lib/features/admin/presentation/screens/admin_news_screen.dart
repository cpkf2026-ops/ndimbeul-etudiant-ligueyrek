import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_shell_chrome.dart';

/// Lecture seule — aucun endpoint backend de création/édition d'actualités
/// n'existe (voir `AdminNewsRepository`). Utile pour vérifier ce qui a été
/// publié tant que la publication elle-même reste hors périmètre backend.
class AdminNewsScreen extends ConsumerWidget {
  const AdminNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(adminNewsProvider);

    return AdminShellChrome(
      currentIndex: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Actualités publiées')),
        body: newsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonCard(height: 70),
                SizedBox(height: 12),
                SkeletonCard(height: 70),
              ],
            ),
          ),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Impossible de charger les actualités',
            message: error is Failure ? error.message : null,
          ),
          data: (news) => news.isEmpty
              ? const EmptyState(
                  icon: Icons.newspaper_outlined,
                  title: 'Aucune actualité publiée',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: news.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final actu = news[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (actu.categorie != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blueSoft,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                actu.categorie!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            actu.titre,
                            style: context.textTheme.titleMedium,
                          ),
                          if (actu.auteur != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${actu.auteur} · ${actu.datePublication != null ? DateFormatter.short(actu.datePublication!) : ''}',
                              style: context.textTheme.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
