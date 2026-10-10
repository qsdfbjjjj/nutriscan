import 'package:equatable/equatable.dart';

import 'product.dart';

/// Одна страница результатов поиска.
class SearchResult extends Equatable {
  const SearchResult({
    required this.products,
    required this.page,
    required this.hasMore,
    this.fromCache = false,
  });

  final List<Product> products;
  final int page;
  final bool hasMore;

  /// true — данные взяты из локального кэша (нет интернета).
  final bool fromCache;

  @override
  List<Object?> get props => [products, page, hasMore, fromCache];
}

/// Результат загрузки одного продукта.
class ProductResult extends Equatable {
  const ProductResult({required this.product, this.fromCache = false});

  final Product product;
  final bool fromCache;

  @override
  List<Object?> get props => [product, fromCache];
}
