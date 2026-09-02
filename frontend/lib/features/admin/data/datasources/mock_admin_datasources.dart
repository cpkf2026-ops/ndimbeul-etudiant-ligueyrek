import 'dart:typed_data';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/source_donnee.dart';
import '../models/actualite_admin_model.dart';
import '../models/admin_user_model.dart';
import '../models/quality_metrics_model.dart';
import '../models/source_donnee_model.dart';
import 'admin_news_remote_datasource.dart';
import 'quality_remote_datasource.dart';
import 'source_remote_datasource.dart';
import 'user_admin_remote_datasource.dart';

/// Jeux de données mockés du back-office — sources IA, utilisateurs,
/// métriques qualité et actualités (voir §10).
class MockSourceRemoteDataSource implements SourceRemoteDataSource {
  static final List<SourceDonneeModel> _sources = [
    SourceDonneeModel(
      id: 'src_1',
      universiteId: 'univ_ucad',
      type: SourceType.url,
      urlOuChemin: 'https://ucad.sn/formations',
      categorie: 'formations',
      statut: SourceStatut.actif,
      dateDernierCrawl: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    SourceDonneeModel(
      id: 'src_2',
      universiteId: 'univ_ugb',
      type: SourceType.pdf,
      urlOuChemin: 'brochure-ugb-2026.pdf',
      categorie: 'bourses',
      statut: SourceStatut.erreur,
      derniereErreur: 'Timeout lors du parsing du PDF (page 12).',
      dateDernierCrawl: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SourceDonneeModel(
      id: 'src_3',
      type: SourceType.api,
      urlOuChemin: 'https://campusen.sn/api/etablissements',
      categorie: 'universites',
      statut: SourceStatut.obsolete,
      dateDernierCrawl: DateTime.now().subtract(const Duration(days: 40)),
    ),
  ];

  @override
  Future<List<SourceDonneeModel>> getSources() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.of(_sources);
  }

  @override
  Future<SourceDonneeModel> createSource({
    String? universiteId,
    required String type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final source = SourceDonneeModel(
      id: 'src_${DateTime.now().millisecondsSinceEpoch}',
      universiteId: universiteId,
      type: SourceType.values.firstWhere((t) => t.name == type),
      urlOuChemin: urlOuChemin,
      categorie: categorie,
      statut: SourceStatut.actif,
    );
    _sources.add(source);
    return source;
  }

  @override
  Future<SourceDonneeModel> updateSource({
    required String id,
    String? universiteId,
    required String type,
    required String urlOuChemin,
    String? categorie,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _sources.indexWhere((s) => s.id == id);
    final updated = _sources[index].copyWith(
      universiteId: universiteId,
      type: SourceType.values.firstWhere((t) => t.name == type),
      urlOuChemin: urlOuChemin,
      categorie: categorie,
    );
    _sources[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteSource(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _sources.removeWhere((s) => s.id == id);
  }

  @override
  Future<Map<String, dynamic>> uploadDocument({
    required Uint8List bytes,
    required String filename,
    String? sourceId,
    String? universiteId,
    String? categorie,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return {
      'message': 'Document "$filename" envoyé pour indexation (simulation).',
    };
  }
}

class MockUserAdminRemoteDataSource implements UserAdminRemoteDataSource {
  static final List<AdminUserModel> _users = [
    AdminUserModel(
      id: 'usr_1',
      nom: 'Diop',
      prenom: 'Moussa',
      email: 'moussa.diop@ucad.edu.sn',
      role: _roleLyceen,
      region: 'Dakar',
      statut: UserStatut.actif,
      dateInscription: DateTime(2026, 1, 12),
      dateDerniereConnexion: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AdminUserModel(
      id: 'usr_2',
      nom: 'Ndiaye',
      prenom: 'Fatou',
      email: 'fatou.ndiaye@ugb.edu.sn',
      role: _roleEtudiant,
      region: 'Saint-Louis',
      statut: UserStatut.actif,
      dateInscription: DateTime(2025, 9, 3),
      dateDerniereConnexion: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AdminUserModel(
      id: 'usr_3',
      nom: 'Sow',
      prenom: 'Ibrahima',
      email: 'ibrahima.sow@isep.sn',
      role: _roleAdmin,
      region: 'Dakar',
      statut: UserStatut.suspendu,
      dateInscription: DateTime(2025, 3, 20),
    ),
  ];

  @override
  Future<List<AdminUserModel>> getUsers({
    String? role,
    String? statut,
    int page = 1,
    int perPage = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    return _users.where((u) {
      if (role != null && _roleName(u.role) != role) return false;
      if (statut != null && u.statut.name != statut) return false;
      return true;
    }).toList();
  }

  @override
  Future<AdminUserModel> updateUserRole({
    required String id,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final index = _users.indexWhere((u) => u.id == id);
    final updated = _users[index].copyWith(role: _roleFromName(role));
    _users[index] = updated;
    return updated;
  }

  @override
  Future<void> suspendUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _users.indexWhere((u) => u.id == id);
    _users[index] = _users[index].copyWith(statut: UserStatut.suspendu);
  }

  @override
  Future<void> reactivateUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _users.indexWhere((u) => u.id == id);
    _users[index] = _users[index].copyWith(statut: UserStatut.actif);
  }

  @override
  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _users.removeWhere((u) => u.id == id);
  }
}

class MockQualityRemoteDataSource implements QualityRemoteDataSource {
  @override
  Future<QualityMetricsModel> getQualityMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const QualityMetricsModel(
      metriquesIa: {
        'couverture_rag': 0.82,
        'taux_erreur_llm': 0.03,
        'cache_hit_rate': 0.61,
        'temps_reponse_moyen_ms': 1450,
      },
      metriquesLaravel: QualityMetricsLaravelModel(
        sourcesActives: 24,
        sourcesEnErreur: 2,
        sourcesObsoletes: 5,
        offresActives: 138,
        offresExpirees: 47,
        actionsAdmin7DerniersJours: 19,
      ),
    );
  }
}

class MockAdminNewsRemoteDataSource implements AdminNewsRemoteDataSource {
  @override
  Future<List<ActualiteAdminModel>> getNews() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      ActualiteAdminModel(
        id: 'news_1',
        titre: 'Ouverture des inscriptions CAMPUSEN 2026-2027',
        categorie: 'formation',
        datePublication: DateTime(2026, 8, 10),
        auteur: 'Ministère de l\'Enseignement supérieur',
      ),
      ActualiteAdminModel(
        id: 'news_2',
        titre:
            'Nouvelles bourses d\'excellence pour les filières scientifiques',
        categorie: 'bourse',
        datePublication: DateTime(2026, 8, 5),
        auteur: 'DBFC',
      ),
    ];
  }
}

const _roleLyceen = UserRole.lyceen;
const _roleEtudiant = UserRole.etudiant;
const _roleAdmin = UserRole.adminEtablissement;

String _roleName(UserRole role) => switch (role) {
  UserRole.lyceen => 'lyceen',
  UserRole.etudiant => 'etudiant',
  UserRole.adminEtablissement => 'admin_etablissement',
  UserRole.superAdmin => 'super_admin',
};

UserRole _roleFromName(String name) => switch (name) {
  'lyceen' => UserRole.lyceen,
  'etudiant' => UserRole.etudiant,
  'admin_etablissement' => UserRole.adminEtablissement,
  'super_admin' => UserRole.superAdmin,
  _ => UserRole.etudiant,
};
