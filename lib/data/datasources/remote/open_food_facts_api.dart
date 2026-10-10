import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/search_result.dart';
import '../../models/product_model.dart';

/// Удалённый источник данных: публичный REST API Open Food Facts.
/// Документация: https://openfoodfacts.github.io/openfoodfacts-server/api/
class OpenFoodFactsApi {
  OpenFoodFactsApi(this._dio);

  final Dio _dio;

  static const pageSize = 20;

  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://world.openfoodfacts.org',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        // В браузере заголовок User-Agent задать нельзя, поэтому только для мобильных.
        headers: kIsWeb ? null : {'User-Agent': 'NutriScan/1.0 (student project)'},
      ),
    );
  }

  /// GET /api/v2/product/{barcode}
  Future<Product> getProduct(String barcode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v2/product/$barcode',
        queryParameters: {'fields': ProductModel.apiFields},
      );
      final data = response.data;
      final product = data?['product'];
      if (data == null || data['status'] == 0 || product is! Map<String, dynamic>) {
        throw NotFoundFailure(barcode);
      }
      return ProductModel.fromApi({'code': barcode, ...product});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// GET /cgi/search.pl — поиск по названию с пагинацией.
  Future<SearchResult> search(String query, {int page = 1, bool kazakhstanOnly = false}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page': page,
          'page_size': pageSize,
          'fields': ProductModel.apiFields,
          // Фильтр по стране продажи.
          if (kazakhstanOnly) ...{
            'tagtype_0': 'countries',
            'tag_contains_0': 'contains',
            'tag_0': 'kazakhstan',
          },
        },
      );
      final data = response.data ?? const <String, dynamic>{};
      final rawProducts = data['products'];
      final products = rawProducts is List
          ? rawProducts
              .whereType<Map<String, dynamic>>()
              .map(ProductModel.fromApi)
              .where((p) => p.barcode.isNotEmpty)
              .toList()
          : <Product>[];
      final count = ProductModel.toDouble(data['count'])?.toInt() ?? 0;
      return SearchResult(
        products: products,
        page: page,
        hasMore: page * pageSize < count && products.isNotEmpty,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// GET /api/v2/search — самые сканируемые продукты, продающиеся в Казахстане.
  /// Оставляем только казахстанские (штрихкод 487…) и с нормальным названием.
  Future<SearchResult> getPopularInKazakhstan() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v2/search',
        queryParameters: {
          'countries_tags_en': 'kazakhstan',
          'sort_by': 'unique_scans_n',
          'page_size': 200,
          'fields': ProductModel.apiFields,
        },
      );
      final raw = response.data?['products'];
      final products = raw is List
          ? raw
              .whereType<Map<String, dynamic>>()
              .map(ProductModel.fromApi)
              .where((p) => p.isMadeInKazakhstan && _hasRealName(p))
              .take(20)
              .toList()
          : <Product>[];
      return SearchResult(products: products, page: 1, hasMore: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// В базе встречаются названия "Unknown" или просто штрихкод вместо имени.
  static bool _hasRealName(Product p) {
    final name = p.name.trim();
    return name.isNotEmpty &&
        name.toLowerCase() != 'unknown' &&
        int.tryParse(name) == null &&
        p.imageUrl != null;
  }

  Failure _mapError(DioException e) {
    if (e.response?.statusCode == 404) return const NotFoundFailure();
    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        NetworkFailure(e.message),
      _ => ServerFailure(e.message),
    };
  }
}
