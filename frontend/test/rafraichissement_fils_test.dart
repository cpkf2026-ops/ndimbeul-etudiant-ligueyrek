import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndimbeul_etudiant/core/constants/app_constants.dart';
import 'package:ndimbeul_etudiant/core/utils/result.dart';
import 'package:ndimbeul_etudiant/features/news/domain/entities/actualite.dart';
import 'package:ndimbeul_etudiant/features/news/domain/repositories/news_repository.dart';
import 'package:ndimbeul_etudiant/features/news/presentation/providers/news_provider.dart';

/// Faux dépôt : compte les appels à l'API et renvoie une actualité de plus à
/// chaque appel, comme si la veille IA en avait ajouté une entre-temps.
class _DepotCompteur implements NewsRepository {
  int appels = 0;

  @override
  Future<Result<ActualitePage>> getActualites({
    CategorieActualite? categorie,
    int page = 1,
    int perPage = 10,
  }) async {
    appels++;
    return Right(ActualitePage(
      items: [
        for (var i = 0; i < appels; i++)
          Actualite(
            id: '$i',
            titre: 'Actualité $i',
            contenu: '',
            categorie: CategorieActualite.general,
            datePublication: DateTime(2026, 10, 5),
          ),
      ],
      currentPage: 1,
      lastPage: 1,
      total: appels,
    ));
  }

  @override
  Future<Result<Actualite>> getActualiteDetail(String id) => throw UnimplementedError();
}

void main() {
  testWidgets('le fil se recharge seul toutes les 15 min et garde la liste affichée',
      (tester) async {
    final depot = _DepotCompteur();
    final container = ProviderContainer(
      overrides: [newsRepositoryProvider.overrideWithValue(depot)],
    );
    container.listen(newsListProvider, (_, _) {});

    await tester.pump();
    await tester.pump();
    expect(depot.appels, 1);
    expect(container.read(newsListProvider).value!.items, hasLength(1));

    // Juste avant l'échéance : pas encore de rechargement.
    await tester.pump(kRafraichissementFils - const Duration(seconds: 1));
    expect(depot.appels, 1);

    // Échéance atteinte : rechargement automatique, la nouveauté apparaît.
    await tester.pump(const Duration(seconds: 1));
    final pendant = container.read(newsListProvider);
    expect(pendant.hasValue, isTrue, reason: 'la liste reste visible pendant le rechargement');
    await tester.pump();
    await tester.pump();
    expect(depot.appels, 2);
    expect(container.read(newsListProvider).value!.items, hasLength(2));

    // Et ainsi de suite, sans intervention de l'utilisateur.
    await tester.pump(kRafraichissementFils);
    await tester.pump();
    await tester.pump();
    expect(depot.appels, 3);

    // Fermer l'app annule le minuteur (aucun rechargement fantôme).
    container.dispose();
  });
}
