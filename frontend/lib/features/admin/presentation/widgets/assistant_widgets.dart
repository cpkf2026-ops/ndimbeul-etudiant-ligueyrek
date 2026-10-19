import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Petits éléments communs aux écrans d'ajout assisté (établissement, actualité, offre).

class EtapesAide extends StatelessWidget {
  const EtapesAide({super.key, required this.etapes});
  final List<String> etapes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.smart_toy_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Comment ça marche', style: context.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
          ]),
          const SizedBox(height: 8),
          for (var i = 0; i < etapes.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.primary,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(etapes[i], style: context.textTheme.bodyMedium)),
              ]),
            ),
        ],
      ),
    );
  }
}

class ChargementRecherche extends StatelessWidget {
  const ChargementRecherche({super.key, required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [
        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 12),
        Expanded(child: Text(texte, style: context.textTheme.bodyMedium)),
      ]),
    );
  }
}

class MessageErreur extends StatelessWidget {
  const MessageErreur({super.key, required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error),
        const SizedBox(width: 10),
        Expanded(child: Text(texte)),
      ]),
    );
  }
}

/// « Déjà présent ? » : évite d'ajouter deux fois le même établissement ou contenu.
class AvertissementDoublon extends StatelessWidget {
  const AvertissementDoublon({super.key, required this.titre, required this.lignes, this.onOuvrir});
  final String titre;
  final List<String> lignes;
  final void Function(int index)? onOuvrir;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(titre, style: context.textTheme.titleMedium)),
        ]),
        const SizedBox(height: 6),
        for (var i = 0; i < lignes.length; i++)
          InkWell(
            onTap: onOuvrir == null ? null : () => onOuvrir!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• ${lignes[i]}',
                  style: TextStyle(
                    decoration: onOuvrir == null ? null : TextDecoration.underline,
                  )),
            ),
          ),
        const SizedBox(height: 4),
        Text('Vérifiez avant d\'ajouter : si c\'est le même, inutile de le créer à nouveau.',
            style: context.textTheme.labelSmall),
      ]),
    );
  }
}

class TitreSection extends StatelessWidget {
  const TitreSection(this.texte, {super.key});
  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(texte, style: context.textTheme.headlineMedium),
      );
}

class ChampTexte extends StatelessWidget {
  const ChampTexte({super.key, required this.controleur, required this.label, this.lignes = 1, this.clavier});
  final TextEditingController controleur;
  final String label;
  final int lignes;
  final TextInputType? clavier;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controleur,
          maxLines: lignes,
          minLines: 1,
          keyboardType: lignes > 1 ? TextInputType.multiline : clavier,
          decoration: InputDecoration(labelText: label, alignLabelWithHint: lignes > 1),
        ),
      );
}

/// Choix de l'image parmi celles trouvées (ou aucune).
class ChoixImage extends StatelessWidget {
  const ChoixImage({super.key, required this.images, required this.choisie, required this.onChoix});
  final List<String> images;
  final String? choisie;
  final ValueChanged<String?> onChoix;

  @override
  Widget build(BuildContext context) {
    Widget carte(String? url) {
      final selection = choisie == url;
      return GestureDetector(
        onTap: () => onChoix(url),
        child: Container(
          width: 110,
          height: 90,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selection ? AppColors.primary : AppColors.border, width: selection ? 3 : 1),
          ),
          child: url == null
              ? const Center(child: Text('Aucune', textAlign: TextAlign.center))
              : Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined))),
        ),
      );
    }

    return Wrap(spacing: 10, runSpacing: 10, children: [for (final i in images) carte(i), carte(null)]);
  }
}
