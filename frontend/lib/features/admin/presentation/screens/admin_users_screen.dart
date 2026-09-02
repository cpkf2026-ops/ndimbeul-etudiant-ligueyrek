import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/admin_user.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_shell_chrome.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return AdminShellChrome(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Utilisateurs')),
        body: usersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonCard(height: 80),
                SizedBox(height: 12),
                SkeletonCard(height: 80),
              ],
            ),
          ),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Impossible de charger les utilisateurs',
            message: error is Failure ? error.message : null,
          ),
          data: (users) => users.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'Aucun utilisateur',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _UserTile(user: users[i]),
                ),
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = user.statut == UserStatut.actif;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.greenSoft,
            child: Text(
              user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nomComplet, style: context.textTheme.titleMedium),
                Text(user.email, style: context.textTheme.labelSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleDropdown(user: user),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.greenSoft
                            : AppColors.amberSoft,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        user.statut.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.success
                              : AppColors.accentDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeTrackColor: AppColors.primary,
            onChanged: (_) async {
              final failure = await ref
                  .read(adminUsersProvider.notifier)
                  .toggleSuspend(user);
              if (failure != null && context.mounted) {
                context.showSnack(failure.message, isError: true);
              }
            },
          ),
          IconButton(
            tooltip: 'Supprimer le compte',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer ce compte ?'),
                  content: Text(
                    '${user.nomComplet} (${user.email}) ne pourra plus se connecter. '
                    'Cette action est journalisée.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Supprimer',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              final failure = await ref
                  .read(adminUsersProvider.notifier)
                  .deleteUser(user.id);
              if (failure != null && context.mounted) {
                context.showSnack(failure.message, isError: true);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RoleDropdown extends ConsumerWidget {
  const _RoleDropdown({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<UserRole>(
      value: user.role,
      underline: const SizedBox.shrink(),
      style: context.textTheme.labelSmall,
      items: [
        for (final role in UserRole.values)
          DropdownMenuItem(value: role, child: Text(role.label)),
      ],
      onChanged: (role) async {
        if (role == null || role == user.role) return;
        final failure = await ref
            .read(adminUsersProvider.notifier)
            .updateRole(user.id, role);
        if (failure != null && context.mounted) {
          context.showSnack(failure.message, isError: true);
        }
      },
    );
  }
}
