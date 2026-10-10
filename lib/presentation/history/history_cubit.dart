import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// История просмотренных продуктов (новые сверху).
class HistoryCubit extends Cubit<List<Product>> {
  HistoryCubit(this._repository) : super(const []);

  final ProductRepository _repository;

  void load() => emit(_repository.getHistory());

  Future<void> add(Product product) async {
    await _repository.addToHistory(product);
    load();
  }

  Future<void> clear() async {
    await _repository.clearHistory();
    load();
  }
}
