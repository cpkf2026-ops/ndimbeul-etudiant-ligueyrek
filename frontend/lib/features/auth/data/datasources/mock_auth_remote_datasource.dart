import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../profile/data/datasources/mock_profile_remote_datasource.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Jeu de données mocké — permet de développer/visualiser tous les écrans
/// sans backend branché (voir §10 : `--dart-define=USE_MOCK=true`).
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  MockAuthRemoteDataSource({required SecureStorageService storage})
      : _storage = storage;

  final SecureStorageService _storage;

  /// Référence en mémoire de la session active, tenue à jour par
  /// [_persistSession] — évite de relire le secure storage juste après
  /// l'avoir écrit dans [completeProfile] (flutter_secure_storage_web peut
  /// lever un `OperationError` sur une lecture trop rapprochée d'une
  /// écriture, dans la même session de page).
  static UserModel? _currentSessionUser;

  static final Map<String, String> _passwords = {
    'moussa.diop@ucad.edu.sn': 'password',
    'lyceen@demo.sn': '***MOT-DE-PASSE-RETIRE***',
    'etudiant@demo.sn': '***MOT-DE-PASSE-RETIRE***',
    'superadmin@demo.sn': '***MOT-DE-PASSE-RETIRE***',
    'admin.ucad@demo.sn': '***MOT-DE-PASSE-RETIRE***',
    'paya@ndimbeul-etudiant.sn': '***MOT-DE-PASSE-RETIRE***',
    'khady@ndimbeul-etudiant.sn': '***MOT-DE-PASSE-RETIRE***',
    'coumba@ndimbeul-etudiant.sn': '***MOT-DE-PASSE-RETIRE***',
    'fatou@ndimbeul-etudiant.sn': '***MOT-DE-PASSE-RETIRE***',
  };

  // Comptes alignés sur UtilisateurSeeder.php / AdminUsersSeeder.php côté
  // Laravel — mêmes emails, mêmes rôles, pour que le mode mock (par défaut,
  // kUseMock=true) reflète fidèlement ce que renverrait le vrai backend.
  // Tous les comptes de démo ont déjà un profil complété : seul un compte
  // fraîchement créé via [register] passe par [completeProfile].
  static final Map<String, UserModel> _users = {
    'moussa.diop@ucad.edu.sn': UserModel(
      id: 'usr_1',
      nom: 'Diop',
      prenom: 'Moussa',
      email: 'moussa.diop@ucad.edu.sn',
      role: UserRole.lyceen,
      region: 'Dakar',
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 12),
    ),
    'lyceen@demo.sn': UserModel(
      id: 'usr_lyceen_demo',
      nom: 'Diop',
      prenom: 'Aminata',
      email: 'lyceen@demo.sn',
      role: UserRole.lyceen,
      region: 'Dakar',
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'etudiant@demo.sn': UserModel(
      id: 'usr_etudiant_demo',
      nom: 'Ndiaye',
      prenom: 'Moussa',
      email: 'etudiant@demo.sn',
      role: UserRole.etudiant,
      region: 'Thiès',
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'superadmin@demo.sn': UserModel(
      id: 'usr_superadmin_demo',
      nom: 'Sy',
      prenom: 'Fatou',
      email: 'superadmin@demo.sn',
      role: UserRole.superAdmin,
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'admin.ucad@demo.sn': UserModel(
      id: 'usr_admin_ucad_demo',
      nom: 'Fall',
      prenom: 'Ibrahima',
      email: 'admin.ucad@demo.sn',
      role: UserRole.adminEtablissement,
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'paya@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_paya',
      nom: 'Niang',
      prenom: 'Paya',
      email: 'paya@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'khady@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_khady',
      nom: 'Gadiaga',
      prenom: 'Khady',
      email: 'khady@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'coumba@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_coumba',
      nom: 'Cissokho',
      prenom: 'Coumba',
      email: 'coumba@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'fatou@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_fatou',
      nom: 'Sarr',
      prenom: 'Fatou',
      email: 'fatou@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      profilComplete: true,
      dateInscription: DateTime(2026, 1, 1),
    ),
  };

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final normalized = email.trim().toLowerCase();
    if (!_users.containsKey(normalized)) {
      // Faille corrigée : plus aucun compte démo générique créé à la volée
      // pour un email inconnu — la présentation redirige vers l'inscription
      // (voir login_screen.dart / Failure.accountNotFound).
      throw const AccountNotFoundException();
    }
    if (_passwords[normalized] != password) {
      throw const ValidationException(
        message: 'Email ou mot de passe incorrect',
      );
    }
    final user = _users[normalized]!;
    await _persistSession(user);
    return user;
  }

  @override
  Future<UserModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final normalized = email.trim().toLowerCase();
    // `role` reste null et `profilComplete` à false : le statut est choisi
    // séparément via [completeProfile] (CompleteProfileScreen, forcé par le
    // redirect du router tant que ce n'est pas fait).
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      nom: nom,
      prenom: prenom,
      email: normalized,
      dateInscription: DateTime.now(),
    );
    _users[normalized] = user;
    _passwords[normalized] = password;
    await _persistSession(user);
    return user;
  }

  @override
  Future<UserModel> completeProfile({
    required UserRole statut,
    required Map<String, dynamic> fields,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final current = _currentSessionUser ?? await getCurrentUser();
    if (current == null) throw const UnauthorizedException();

    final updated = current.copyWith(role: statut, profilComplete: true);
    _users[current.email] = updated;
    _currentSessionUser = updated;
    MockProfileRemoteDataSource.completeAs(statut, fields);
    return updated;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentSessionUser = null;
    await _storage.clear();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final hasSession = await _storage.hasSession;
    if (!hasSession) return null;
    final id = await _storage.accessToken;
    final match = _users.values.where((u) => u.id == id);
    return match.isNotEmpty ? match.first : _users.values.first;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _persistSession(UserModel user) async {
    _currentSessionUser = user;
    await _storage.saveTokens(
      accessToken: user.id,
      refreshToken: '${user.id}_refresh',
    );
    if (user.role != null) await _storage.saveRole(user.role!.name);
  }
}
