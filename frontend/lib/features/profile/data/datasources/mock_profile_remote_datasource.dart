import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/profil_etudiant.dart';
import '../../domain/entities/profil_lyceen.dart';
import '../models/profil_diplome_model.dart';
import '../models/profil_etudiant_model.dart';
import '../models/profil_lyceen_model.dart';
import 'profile_remote_datasource.dart';

/// Jeu de données mocké — profil lycéen partiellement rempli par défaut,
/// pour démontrer la barre de complétude (voir §10 / §4.2). `role` reflète
/// le statut du compte mock actuellement connecté (voir
/// [MockAuthRemoteDataSource.completeProfile], seul point d'écriture avec
/// [completeAs]) plutôt qu'une valeur figée, pour que Mon Profil affiche
/// bien le bon formulaire selon le parcours suivi à l'inscription.
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  static String role = 'lyceen';

  static ProfilLyceenModel _lyceen = const ProfilLyceenModel(
    serieBac: 'S2',
    moyenneGenerale: 13.5,
    passions: ['Informatique', 'Robotique'],
    mobilite: true,
    prefPublicPrive: PrefEtablissement.indifferent,
    anneeTerminale: 2026,
    completude: 50,
  );

  static ProfilEtudiantModel _etudiant = const ProfilEtudiantModel(
    universiteActuelle: 'univ_ucad',
    niveauActuel: NiveauEtudiant.l2,
    domainesInterets: ['Informatique'],
    rechercheStage: true,
  );

  static ProfilDiplomeModel _diplome = const ProfilDiplomeModel();

  int _computeCompletude(ProfilLyceenModel p) {
    final fields = <bool>[
      p.serieBac != null && p.serieBac!.isNotEmpty,
      p.moyenneGenerale != null,
      (p.passions ?? []).isNotEmpty,
      (p.metiersEnvisages ?? []).isNotEmpty,
      p.budgetMaxAnnuel != null,
      p.prefPublicPrive != PrefEtablissement.indifferent,
      p.regionCible != null && p.regionCible!.isNotEmpty,
      p.anneeTerminale != null,
    ];
    final filled = fields.where((f) => f).length;
    return ((filled / fields.length) * 100).round();
  }

  /// Appelé par [MockAuthRemoteDataSource.completeProfile] : enregistre le
  /// statut choisi et les champs saisis dans CompleteProfileScreen (clés au
  /// format backend, ex. `serie_bac`, `universite_actuelle`,
  /// `dernier_diplome`...), pour que [getProfile] les reflète ensuite.
  static void completeAs(UserRole statut, Map<String, dynamic> fields) {
    switch (statut) {
      case UserRole.lyceen:
        role = 'lyceen';
        _lyceen = ProfilLyceenModel.fromJson(fields).copyWith(
          completude: 100,
        );
      case UserRole.etudiant:
        role = 'etudiant';
        _etudiant = ProfilEtudiantModel.fromJson(fields);
      case UserRole.diplome:
        role = 'diplome';
        _diplome = ProfilDiplomeModel.fromJson(fields);
      case UserRole.adminEtablissement:
      case UserRole.superAdmin:
        break;
    }
  }

  @override
  Future<ProfileEnvelope> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final profil = switch (role) {
      'etudiant' => _etudiant.toJson(),
      'diplome' => _diplome.toJson(),
      _ => _lyceen.toJson(),
    };
    return (role: role, profil: profil);
  }

  @override
  Future<ProfilLyceenModel> updateProfilLyceen(ProfilLyceenModel profil) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _lyceen = profil.copyWith(completude: _computeCompletude(profil));
    return _lyceen;
  }

  @override
  Future<ProfilEtudiantModel> updateProfilEtudiant(ProfilEtudiantModel profil) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _etudiant = profil;
    return _etudiant;
  }

  @override
  Future<ProfilDiplomeModel> updateProfilDiplome(ProfilDiplomeModel profil) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _diplome = profil;
    return _diplome;
  }
}
