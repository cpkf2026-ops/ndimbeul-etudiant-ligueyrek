import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Jeu de données mocké — permet de développer/visualiser tous les écrans
/// sans backend branché (voir §10 : `--dart-define=USE_MOCK=true`).
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  MockAuthRemoteDataSource({required SecureStorageService storage})
      : _storage = storage;

  final SecureStorageService _storage;

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
  static final Map<String, UserModel> _users = {
    'moussa.diop@ucad.edu.sn': UserModel(
      id: 'usr_1',
      nom: 'Diop',
      prenom: 'Moussa',
      email: 'moussa.diop@ucad.edu.sn',
      role: UserRole.lyceen,
      region: 'Dakar',
      dateInscription: DateTime(2026, 1, 12),
    ),
    'lyceen@demo.sn': UserModel(
      id: 'usr_lyceen_demo',
      nom: 'Diop',
      prenom: 'Aminata',
      email: 'lyceen@demo.sn',
      role: UserRole.lyceen,
      region: 'Dakar',
      dateInscription: DateTime(2026, 1, 1),
    ),
    'etudiant@demo.sn': UserModel(
      id: 'usr_etudiant_demo',
      nom: 'Ndiaye',
      prenom: 'Moussa',
      email: 'etudiant@demo.sn',
      role: UserRole.etudiant,
      region: 'Thiès',
      dateInscription: DateTime(2026, 1, 1),
    ),
    'superadmin@demo.sn': UserModel(
      id: 'usr_superadmin_demo',
      nom: 'Sy',
      prenom: 'Fatou',
      email: 'superadmin@demo.sn',
      role: UserRole.superAdmin,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'admin.ucad@demo.sn': UserModel(
      id: 'usr_admin_ucad_demo',
      nom: 'Fall',
      prenom: 'Ibrahima',
      email: 'admin.ucad@demo.sn',
      role: UserRole.adminEtablissement,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'paya@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_paya',
      nom: 'Niang',
      prenom: 'Paya',
      email: 'paya@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'khady@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_khady',
      nom: 'Gadiaga',
      prenom: 'Khady',
      email: 'khady@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'coumba@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_coumba',
      nom: 'Cissokho',
      prenom: 'Coumba',
      email: 'coumba@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
      dateInscription: DateTime(2026, 1, 1),
    ),
    'fatou@ndimbeul-etudiant.sn': UserModel(
      id: 'usr_admin_fatou',
      nom: 'Sarr',
      prenom: 'Fatou',
      email: 'fatou@ndimbeul-etudiant.sn',
      role: UserRole.superAdmin,
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
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final normalized = email.trim().toLowerCase();
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      nom: nom,
      prenom: prenom,
      email: normalized,
      role: role,
      dateInscription: DateTime.now(),
    );
    _users[normalized] = user;
    _passwords[normalized] = password;
    await _persistSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _storage.clear();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final hasSession = await _storage.hasSession;
    if (!hasSession) return null;
    final email = await _storage.accessToken;
    final match = _users.values.where((u) => u.id == email);
    return match.isNotEmpty ? match.first : _users.values.first;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _persistSession(UserModel user) async {
    await _storage.saveTokens(
      accessToken: user.id,
      refreshToken: '${user.id}_refresh',
    );
    await _storage.saveRole(user.role.name);
  }
}
