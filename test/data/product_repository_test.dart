import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriscan/core/error/failures.dart';
import 'package:nutriscan/data/datasources/local/product_local_data_source.dart';
import 'package:nutriscan/data/datasources/remote/open_food_facts_api.dart';
import 'package:nutriscan/data/repositories/product_repository_impl.dart';
import 'package:nutriscan/domain/entities/product.dart';
import 'package:nutriscan/domain/entities/search_result.dart';

class MockApi extends Mock implements OpenFoodFactsApi {}

class MockLocal extends Mock implements ProductLocalDataSource {}

void main() {
  late MockApi api;
  late MockLocal local;
  late ProductRepositoryImpl repository;

  const milk = Product(barcode: '111', name: 'Молоко');

  setUpAll(() {
    registerFallbackValue(milk);
    registerFallbackValue(const SearchResult(products: [], page: 1, hasMore: false));
  });

  setUp(() {
    api = MockApi();
    local = MockLocal();
    repository = ProductRepositoryImpl(remote: api, local: local);
  });

  group('getProduct', () {
    test('есть сеть — грузит из API и сохраняет в кэш', () async {
      when(() => api.getProduct('111')).thenAnswer((_) async => milk);
      when(() => local.cacheProduct(any())).thenAnswer((_) async {});

      final result = await repository.getProduct('111');

      expect(result.product, milk);
      expect(result.fromCache, isFalse);
      verify(() => local.cacheProduct(milk)).called(1);
    });

    test('нет сети — отдаёт продукт из кэша', () async {
      when(() => api.getProduct('111')).thenThrow(const NetworkFailure());
      when(() => local.getCachedProduct('111')).thenReturn(milk);

      final result = await repository.getProduct('111');

      expect(result.product, milk);
      expect(result.fromCache, isTrue);
    });

    test('нет сети и кэша — пробрасывает NetworkFailure', () {
      when(() => api.getProduct('111')).thenThrow(const NetworkFailure());
      when(() => local.getCachedProduct('111')).thenReturn(null);

      expect(repository.getProduct('111'), throwsA(isA<NetworkFailure>()));
    });
  });

  test('search без сети берёт результаты из кэша', () async {
    const cached = SearchResult(products: [milk], page: 1, hasMore: false, fromCache: true);
    when(() => api.search('молоко', page: 1, kazakhstanOnly: false)).thenThrow(const NetworkFailure());
    when(() => local.getCachedSearch('молоко', 1)).thenReturn(cached);

    final result = await repository.search('молоко');

    expect(result, cached);
  });
}
