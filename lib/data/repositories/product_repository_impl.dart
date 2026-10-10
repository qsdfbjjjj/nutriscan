import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/open_food_facts_api.dart';

/// Реализация репозитория со стратегией offline-first:
/// 1. пробуем загрузить из сети и сохраняем результат в кэш;
/// 2. если сети нет — отдаём то, что лежит в кэше;
/// 3. если и в кэше пусто — пробрасываем ошибку дальше.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this._remote,
    required this._local,
  });

  final OpenFoodFactsApi _remote;
  final ProductLocalDataSource _local;

  @override
  Future<SearchResult> search(String query, {int page = 1}) async {
    try {
      final result = await _remote.search(query, page: page);
      await _local.cacheSearch(query, result);
      return result;
    } on NetworkFailure {
      final cached = _local.getCachedSearch(query, page);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<ProductResult> getProduct(String barcode) async {
    try {
      final product = await _remote.getProduct(barcode);
      await _local.cacheProduct(product);
      return ProductResult(product: product);
    } on NetworkFailure {
      final cached = _local.getCachedProduct(barcode);
      if (cached != null) return ProductResult(product: cached, fromCache: true);
      rethrow;
    }
  }

  @override
  List<Product> getFavorites() => _local.getFavorites();

  @override
  bool isFavorite(String barcode) => _local.isFavorite(barcode);

  @override
  Future<void> toggleFavorite(Product product) async {
    if (_local.isFavorite(product.barcode)) {
      await _local.removeFavorite(product.barcode);
    } else {
      await _local.addFavorite(product);
    }
  }

  @override
  List<Product> getHistory() => _local.getHistory();

  @override
  Future<void> addToHistory(Product product) => _local.addToHistory(product);

  @override
  Future<void> clearHistory() => _local.clearHistory();
}
