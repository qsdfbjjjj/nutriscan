import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/search_result.dart';
import '../../models/product_model.dart';

/// Имена Hive-коробок.
abstract final class HiveBoxes {
  static const products = 'products_cache';
  static const searches = 'search_cache';
  static const favorites = 'favorites';
  static const history = 'history';

  static const all = [products, searches, favorites, history];
}

/// Локальный источник данных на Hive.
/// В коробках храним JSON-строки, поэтому не нужны TypeAdapter'ы.
class ProductLocalDataSource {
  ProductLocalDataSource({
    required this._products,
    required this._searches,
    required this._favorites,
    required this._history,
  });

  final Box<String> _products;
  final Box<String> _searches;
  final Box<String> _favorites;
  final Box<String> _history;

  static const historyLimit = 50;

  // ---------- Кэш продуктов ----------
  Future<void> cacheProduct(Product product) =>
      _products.put(product.barcode, _encode(product));

  Product? getCachedProduct(String barcode) => _decode(_products.get(barcode));

  // ---------- Кэш поиска ----------
  static String _searchKey(String query, int page) =>
      '${query.trim().toLowerCase()}|$page';

  Future<void> cacheSearch(String query, SearchResult result) {
    final value = jsonEncode({
      'hasMore': result.hasMore,
      'products': result.products.map(ProductModel.toJson).toList(),
    });
    return _searches.put(_searchKey(query, result.page), value);
  }

  SearchResult? getCachedSearch(String query, int page) {
    final raw = _searches.get(_searchKey(query, page));
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final products = (json['products'] as List)
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
    return SearchResult(
      products: products,
      page: page,
      hasMore: json['hasMore'] as bool? ?? false,
      fromCache: true,
    );
  }

  // ---------- Избранное ----------
  List<Product> getFavorites() =>
      _favorites.values.map(_decode).whereType<Product>().toList();

  bool isFavorite(String barcode) => _favorites.containsKey(barcode);

  Future<void> addFavorite(Product product) =>
      _favorites.put(product.barcode, _encode(product));

  Future<void> removeFavorite(String barcode) => _favorites.delete(barcode);

  // ---------- История просмотров ----------
  /// Ключ — время просмотра, чтобы история была отсортирована.
  List<Product> getHistory() {
    final keys = _history.keys.cast<String>().toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) => _decode(_history.get(k))).whereType<Product>().toList();
  }

  Future<void> addToHistory(Product product) async {
    // Убираем прошлую запись этого продукта, чтобы не было дублей.
    final oldKeys = _history.keys.cast<String>().where((k) {
      return _decode(_history.get(k))?.barcode == product.barcode;
    }).toList();
    await _history.deleteAll(oldKeys);

    final key = DateTime.now().millisecondsSinceEpoch.toString().padLeft(16, '0');
    await _history.put(key, _encode(product));

    // Ограничиваем размер истории.
    if (_history.length > historyLimit) {
      final keys = _history.keys.cast<String>().toList()..sort();
      await _history.deleteAll(keys.take(_history.length - historyLimit));
    }
  }

  Future<void> clearHistory() => _history.clear();

  // ---------- Вспомогательное ----------
  static String _encode(Product p) => jsonEncode(ProductModel.toJson(p));

  static Product? _decode(String? raw) {
    if (raw == null) return null;
    return ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
