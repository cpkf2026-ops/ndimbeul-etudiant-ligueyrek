import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/name_placeholder.dart';
import '../../../../shared/widgets/source_badge.dart';
import '../../domain/entities/formation.dart';
import '../../domain/entities/universite.dart';
import '../providers/formation_provider.dart';
import '../providers/university_provider.dart';

class UniversityDetailScreen extends ConsumerWidget {
  const UniversityDetailScreen({super.key, required this.universityId});

  final String universityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universiteAsync = ref.watch(universityDetailProvider(universityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: universiteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Université introuvable',
            message: error is Failure ? error.message : null,
          ),
        ),
        data: (universite) => _UniversityDetailBody(universite: universite),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // go() : /chat est un branch de la StatefulShellRoute (voir app_router.dart),
        // un push() depuis cet écran hors-shell l'empilerait sans basculer proprement dessus.
        onPressed: () => context.go(RoutePaths.chat),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.smart_toy_outlined, color: AppColors.primary),
        label: const Text(
          'Demander à l\'IA',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _UniversityDetailBody extends StatelessWidget {
  const _UniversityDetailBody({required this.universite});
  final Universite universite;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Builder(
                  builder: (context) {
                    final src = universite.imageUrl;
                    if (src == null || src.isEmpty) {
                      return NamePlaceholder(name: universite.nom, fontSize: 20);
                    }
                    return src.startsWith('assets/')
                        ? Image.asset(src, fit: BoxFit.cover)
                        : Image.network(
                            src,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                NamePlaceholder(name: universite.nom, fontSize: 20),
                          );
                  },
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              universite.nom,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Statut affiché seulement s'il est vérifié (ANAQ-Sup, MESRI...).
                    if (universite.type != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.greenSoft,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          universite.type!.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Icon(Icons.place_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(universite.localisation, style: context.textTheme.bodyMedium),
                    ),
                  ],
                ),
                if (universite.description != null) ...[
                  const SizedBox(height: 16),
                  Text(universite.description!, style: context.textTheme.bodyLarge),
                ],
                if (universite.siteWebOfficiel != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(universite.siteWebOfficiel!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.language_rounded),
                    label: const Text('Site officiel'),
                  ),
                ],
                const SizedBox(height: 28),
                if (universite.domaines.isNotEmpty)
                  _Section(
                    title: 'Domaines de formation',
                    child: _Puces(valeurs: universite.domaines),
                  ),
                if (universite.diplomes.isNotEmpty)
                  _Section(
                    title: 'Diplômes préparés',
                    child: _Puces(valeurs: universite.diplomes, accent: true),
                  ),
                // Sans formations détaillées, on n'affiche "aucune formation" que si la fiche
                // ne donne pas non plus de domaines ni de diplômes (sinon la page dit déjà l'essentiel).
                if (universite.formations.isNotEmpty ||
                    (universite.domaines.isEmpty && universite.diplomes.isEmpty))
                  _Section(
                    title: 'Formations (${universite.formations.length})',
                    child: universite.formations.isEmpty
                        ? const Text('Aucune formation référencée pour le moment.')
                        : Column(
                            children: universite.formations
                                .map((f) => _FormationTile(
                                      formation: f,
                                      universiteId: universite.id,
                                    ))
                                .toList(),
                          ),
                  ),
                if (universite.admission != null ||
                    universite.niveauRequis.isNotEmpty ||
                    universite.piecesAFournir.isNotEmpty)
                  _Section(
                    title: 'Admission',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (universite.admission != null)
                          Text(universite.admission!, style: context.textTheme.bodyMedium),
                        if (universite.niveauRequis.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Niveau requis', style: context.textTheme.titleMedium),
                          _Liste(lignes: universite.niveauRequis),
                        ],
                        if (universite.piecesAFournir.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Pièces à fournir', style: context.textTheme.titleMedium),
                          _Liste(lignes: universite.piecesAFournir),
                        ],
                      ],
                    ),
                  ),
                if (universite.adresse != null ||
                    universite.telephoneContact != null ||
                    universite.emailContact != null)
                  _Section(
                    title: 'Contact',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (universite.adresse != null)
                          _LigneContact(icon: Icons.place_outlined, texte: universite.adresse!),
                        if (universite.telephoneContact != null)
                          _LigneContact(
                            icon: Icons.phone_outlined,
                            texte: universite.telephoneContact!,
                            lien: Uri(
                              scheme: 'tel',
                              path: universite.telephoneContact!.replaceAll(RegExp(r'[^\d+]'), ''),
                            ),
                          ),
                        if (universite.emailContact != null)
                          _LigneContact(
                            icon: Icons.mail_outline_rounded,
                            texte: universite.emailContact!,
                            lien: Uri(scheme: 'mailto', path: universite.emailContact!),
                          ),
                      ],
                    ),
                  ),
                if (universite.bourses.isNotEmpty)
                  _Section(
                    title: 'Bourses',
                    child: Column(
                      children: universite.bourses.map((b) {
                        return _InfoCard(
                          title: b.nom,
                          lines: [
                            if (b.montant != null)
                              '${b.montant!.toStringAsFixed(0)} ${b.devise} / an',
                            if (b.conditions != null) b.conditions!,
                            if (b.dateLimite != null)
                              'Date limite : ${DateFormatter.short(b.dateLimite!)}',
                          ],
                          source: b.source,
                          dateMaj: b.dateMaj,
                        );
                      }).toList(),
                    ),
                  ),
                if (universite.logements.isNotEmpty)
                  _Section(
                    title: 'Logement',
                    child: Column(
                      children: universite.logements.map((l) {
                        return _InfoCard(
                          title: l.nom,
                          lines: [
                            l.type.label,
                            if (l.tarifMensuel != null)
                              '${l.tarifMensuel!.toStringAsFixed(0)} ${l.devise} / mois',
                            if (l.capacite != null) 'Capacité : ${l.capacite} places',
                          ],
                          source: l.source,
                          dateMaj: l.dateMaj,
                        );
                      }).toList(),
                    ),
                  ),
                if (universite.fraisScolarite.isNotEmpty)
                  _Section(
                    title: 'Frais de scolarité',
                    child: Column(
                      children: universite.fraisScolarite.map((f) {
                        return _InfoCard(
                          title: '${f.montant.toStringAsFixed(0)} ${f.devise} / an',
                          lines: [
                            if (f.moyensPaiement != null && f.moyensPaiement!.isNotEmpty)
                              'Paiement : ${f.moyensPaiement!.join(', ')}',
                          ],
                          source: f.source,
                          dateMaj: f.dateMaj,
                        );
                      }).toList(),
                    ),
                  ),
                if (universite.sourceInfos != null) _SourceInfos(url: universite.sourceInfos!),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Domaines / diplômes sous forme de pastilles.
class _Puces extends StatelessWidget {
  const _Puces({required this.valeurs, this.accent = false});
  final List<String> valeurs;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in valeurs)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent ? AppColors.amberSoft : AppColors.greenSoft,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              v,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _Liste extends StatelessWidget {
  const _Liste({required this.lignes});
  final List<String> lignes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final l in lignes)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(l, style: context.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

class _LigneContact extends StatelessWidget {
  const _LigneContact({required this.icon, required this.texte, this.lien});
  final IconData icon;
  final String texte;
  final Uri? lien;

  @override
  Widget build(BuildContext context) {
    final contenu = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: context.textTheme.bodyMedium?.copyWith(
                color: lien != null ? AppColors.primary : null,
                fontWeight: lien != null ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
    return lien == null ? contenu : InkWell(onTap: () => launchUrl(lien!), child: contenu);
  }
}

/// D'où viennent les informations de la fiche (annuaire, article, site...).
class _SourceInfos extends StatelessWidget {
  const _SourceInfos({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final hote = Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Informations publiques — source : $hote',
                style: context.textTheme.labelSmall?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.headlineMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FormationTile extends ConsumerWidget {
  const _FormationTile({required this.formation, required this.universiteId});
  final Formation formation;
  final String universiteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> toggleFavorite() async {
      final usecase = formation.estFavori
          ? ref.read(unfavoriteFormationUseCaseProvider)
          : ref.read(favoriteFormationUseCaseProvider);
      final result = await usecase.call(formation.id);
      result.fold(
        (failure) => context.showSnack(failure.message, isError: true),
        (_) => ref.invalidate(universityDetailProvider(universiteId)),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formation.intitule, style: context.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${formation.niveau.label} · ${formation.dureeAnnees ?? '?'} an(s) · ${formation.domaine}',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (formation.moyenneMinimale != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amberSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '≥ ${formation.moyenneMinimale}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 4),
          ],
          FavoriteButton(
            isFavorite: formation.estFavori,
            onTap: toggleFavorite,
            background: AppColors.background,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.lines,
    this.source,
    this.dateMaj,
  });

  final String title;
  final List<String> lines;
  final String? source;
  final DateTime? dateMaj;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.titleMedium),
          for (final line in lines) ...[
            const SizedBox(height: 4),
            Text(line, style: context.textTheme.bodyMedium),
          ],
          if (source != null && dateMaj != null) ...[
            const SizedBox(height: 8),
            SourceBadge(source: source!, updatedAt: dateMaj!),
          ],
        ],
      ),
    );
  }
}
