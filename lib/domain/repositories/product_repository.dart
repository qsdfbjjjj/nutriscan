import '../entities/product.dart';
import '../entities/search_result.dart';

/// Контракт репозитория продуктов.
///
/// Presentation-слой работает только с этим интерфейсом и не знает,
/// откуда приходят данные: из сети или из локального кэша.
/// Ошибки выбрасываются как [Failure] (см. core/error/failures.dart).
abstract interface class ProductRepository {
  /// [kazakhstanOnly] — искать только среди продуктов, которые продаются в Казахстане.
  Future<SearchResult> search(String query, {int page = 1, bool kazakhstanOnly = false});

  /// Популярные казахстанские продукты (штрихкод 487…).
  Future<SearchResult> getPopularInKazakhstan();

  Future<ProductResult> getProduct(String barcode);

  List<Product> getFavorites();
  bool isFavorite(String barcode);
  Future<void> toggleFavorite(Product product);

  List<Product> getHistory();
  Future<void> addToHistory(Product product);
  Future<void> clearHistory();
}
