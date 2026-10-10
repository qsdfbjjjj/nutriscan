/// Ошибки, которые репозитории отдают наверх.
/// Экран по типу ошибки решает, какое сообщение показать.
sealed class Failure implements Exception {
  const Failure([this.details]);

  final String? details;

  @override
  String toString() => '$runtimeType(${details ?? ''})';
}

/// Нет сети или истёк таймаут, а в кэше ничего нет.
class NetworkFailure extends Failure {
  const NetworkFailure([super.details]);
}

/// Продукт с таким штрихкодом не найден в базе.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.details]);
}

/// Сервер ответил ошибкой или прислал неожиданные данные.
class ServerFailure extends Failure {
  const ServerFailure([super.details]);
}
