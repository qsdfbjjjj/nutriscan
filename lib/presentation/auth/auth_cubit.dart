import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState extends Equatable {
  const AuthState({this.user, this.isLoading = false});

  final AppUser? user;
  final bool isLoading;

  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [user, isLoading];
}

/// Состояние авторизации. На него подписан GoRouter (redirect).
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(AuthState(user: _repository.currentUser));

  final AuthRepository _repository;

  Future<void> signIn({required String name, required String email}) async {
    emit(AuthState(user: state.user, isLoading: true));
    final user = await _repository.signIn(name: name, email: email);
    emit(AuthState(user: user));
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthState());
  }
}
