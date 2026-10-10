import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Избранное. Состояние — список продуктов; хранится в Hive через репозиторий.
class FavoritesCubit extends Cubit<List<Product>> {
  FavoritesCubit(this._repository) : super(const []);

  final ProductRepository _repository;

  void load() => emit(_repository.getFavorites());

  bool isFavorite(String barcode) => state.any((p) => p.barcode == barcode);

  /// Возвращает true, если продукт добавлен, и false, если удалён.
  Future<bool> toggle(Product product) async {
    final wasFavorite = isFavorite(product.barcode);
    await _repository.toggleFavorite(product);
    load();
    return !wasFavorite;
  }
}
