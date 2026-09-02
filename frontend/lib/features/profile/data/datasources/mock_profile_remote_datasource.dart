import '../../domain/entities/profil_etudiant.dart';
import '../../domain/entities/profil_lyceen.dart';
import '../models/profil_etudiant_model.dart';
import '../models/profil_lyceen_model.dart';
import 'profile_remote_datasource.dart';

/// Jeu de données mocké — profil lycéen partiellement rempli par défaut,
/// pour démontrer la barre de complétude (voir §10 / §4.2).
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

  @override
  Future<ProfileEnvelope> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final profil = role == 'lyceen' ? _lyceen.toJson() : _etudiant.toJson();
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
}
