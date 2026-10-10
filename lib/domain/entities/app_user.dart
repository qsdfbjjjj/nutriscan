import 'package:equatable/equatable.dart';

/// Пользователь приложения.
/// Сейчас вход локальный; на неделе 8 его заменит Firebase Authentication.
class AppUser extends Equatable {
  const AppUser({required this.name, required this.email});

  final String name;
  final String email;

  @override
  List<Object?> get props => [name, email];
}
