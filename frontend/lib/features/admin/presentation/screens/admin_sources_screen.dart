import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/source_donnee.dart';
import '../../domain/usecases/upload_document.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_shell_chrome.dart';

class AdminSourcesScreen extends ConsumerWidget {
  const AdminSourcesScreen({super.key});

  Color _statutColor(SourceStatut statut) {
    switch (statut) {
      case SourceStatut.actif:
        return AppColors.success;
      case SourceStatut.erreur:
        return AppColors.error;
      case SourceStatut.obsolete:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(sourcesProvider);

    return AdminShellChrome(
      currentIndex: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Sources de données IA'),
          actions: [
            IconButton(
              tooltip: 'Importer un document PDF',
              icon: const Icon(Icons.upload_file_outlined),
              onPressed: () => _uploadDocumentDialog(context, ref),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _sourceFormDialog(context, ref),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add_rounded, color: AppColors.primary),
        ),
        body: sourcesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonCard(height: 90),
                SizedBox(height: 12),
                SkeletonCard(height: 90),
              ],
            ),
          ),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Impossible de charger les sources',
            message: error is Failure ? error.message : null,
          ),
          data: (sources) => sources.isEmpty
              ? const EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Aucune source enregistrée',
                  message:
                      'Ajoutez une URL, un flux API ou importez un document PDF.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: sources.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final source = sources[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statutColor(
                                          source.statut,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Text(
                                        source.statut.label,
                                        style: TextStyle(
                                          color: _statutColor(source.statut),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      source.type.label,
                                      style: context.textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  source.urlOuChemin,
                                  style: context.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (source.derniereErreur != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    source.derniereErreur!,
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(color: AppColors.error),
                                  ),
                                ],
                                if (source.dateDernierCrawl != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dernier crawl : ${DateFormatter.relative(source.dateDernierCrawl!)}',
                                    style: context.textTheme.labelSmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                            onPressed: () async {
                              final failure = await ref
                                  .read(sourcesProvider.notifier)
                                  .delete(source.id);
                              if (failure != null && context.mounted) {
                                context.showSnack(
                                  failure.message,
                                  isError: true,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _sourceFormDialog(BuildContext context, WidgetRef ref) async {
    final urlController = TextEditingController();
    var type = SourceType.url;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SourceType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in SourceType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: (v) => setState(() => type = v ?? type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL ou chemin'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (urlController.text.trim().isEmpty) return;
                final navigator = Navigator.of(context);
                final failure = await ref
                    .read(sourcesProvider.notifier)
                    .create(type: type, urlOuChemin: urlController.text.trim());
                if (context.mounted) {
                  navigator.pop();
                  if (failure != null)
                    context.showSnack(failure.message, isError: true);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadDocumentDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController(text: 'document.pdf');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer un document PDF'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nom du fichier'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final failure = await ref
                  .read(uploadDocumentUseCaseProvider)
                  .call(
                    UploadDocumentParams(
                      bytes: Uint8List(0),
                      filename: nameController.text.trim().isEmpty
                          ? 'document.pdf'
                          : nameController.text.trim(),
                    ),
                  );
              if (context.mounted) {
                navigator.pop();
                failure.fold(
                  (f) => context.showSnack(f.message, isError: true),
                  (_) => context.showSnack('Document envoyé pour indexation'),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
