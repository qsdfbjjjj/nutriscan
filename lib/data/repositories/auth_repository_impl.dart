import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';

/// Локальная авторизация (заглушка до подключения Firebase на неделе 8).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  AppUser? get currentUser => _local.user;

  @override
  Future<AppUser> signIn({required String name, required String email}) async {
    final user = AppUser(name: name.trim(), email: email.trim().toLowerCase());
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<void> signOut() => _local.clear();
}
