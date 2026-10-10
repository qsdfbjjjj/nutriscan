import '../entities/app_user.dart';

/// Контракт авторизации. Реализацию можно подменить (локальная → Firebase),
/// не трогая экраны и Cubit.
abstract interface class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({required String name, required String email});

  Future<void> signOut();
}
