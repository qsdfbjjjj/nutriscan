import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriscan/core/error/failures.dart';
import 'package:nutriscan/domain/entities/product.dart';
import 'package:nutriscan/domain/entities/search_result.dart';
import 'package:nutriscan/domain/repositories/product_repository.dart';
import 'package:nutriscan/presentation/search/search_bloc.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  const milk = Product(barcode: '111', name: 'Молоко');
  const kefir = Product(barcode: '222', name: 'Кефир');

  setUp(() => repository = MockProductRepository());

  SearchBloc buildBloc() => SearchBloc(repository, debounce: Duration.zero);

  blocTest<SearchBloc, SearchState>(
    'успешный поиск: loading → success',
    setUp: () => when(() => repository.search('молоко', kazakhstanOnly: any(named: 'kazakhstanOnly'))).thenAnswer(
      (_) async => const SearchResult(products: [milk], page: 1, hasMore: true),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('молоко')),
    wait: const Duration(milliseconds: 50),
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'молоко'),
      SearchState(
        status: SearchStatus.success,
        query: 'молоко',
        products: [milk],
        page: 1,
        hasMore: true,
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'пустой ответ: loading → empty',
    setUp: () => when(() => repository.search('абв', kazakhstanOnly: any(named: 'kazakhstanOnly'))).thenAnswer(
      (_) async => const SearchResult(products: [], page: 1, hasMore: false),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('абв')),
    wait: const Duration(milliseconds: 50),
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'абв'),
      SearchState(status: SearchStatus.empty, query: 'абв', page: 1),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'ошибка сети: loading → failure',
    setUp: () => when(() => repository.search('молоко', kazakhstanOnly: any(named: 'kazakhstanOnly'))).thenThrow(const NetworkFailure()),
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('молоко')),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      const SearchState(status: SearchStatus.loading, query: 'молоко'),
      isA<SearchState>()
          .having((s) => s.status, 'status', SearchStatus.failure)
          .having((s) => s.error, 'error', isA<NetworkFailure>()),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'короткий запрос сбрасывает поиск и не ходит в сеть',
    build: buildBloc,
    act: (bloc) => bloc.add(const SearchQueryChanged('м')),
    wait: const Duration(milliseconds: 50),
    expect: () => <SearchState>[],
    verify: (_) => verifyNever(() => repository.search(any(), kazakhstanOnly: any(named: 'kazakhstanOnly'))),
  );

  blocTest<SearchBloc, SearchState>(
    'следующая страница добавляется в конец списка',
    setUp: () => when(() => repository.search('молоко', page: 2, kazakhstanOnly: any(named: 'kazakhstanOnly'))).thenAnswer(
      (_) async => const SearchResult(products: [kefir], page: 2, hasMore: false),
    ),
    build: buildBloc,
    seed: () => const SearchState(
      status: SearchStatus.success,
      query: 'молоко',
      products: [milk],
      page: 1,
      hasMore: true,
    ),
    act: (bloc) => bloc.add(const SearchNextPageRequested()),
    expect: () => const [
      SearchState(
        status: SearchStatus.success,
        query: 'молоко',
        products: [milk],
        page: 1,
        hasMore: true,
        isLoadingMore: true,
      ),
      SearchState(
        status: SearchStatus.success,
        query: 'молоко',
        products: [milk, kefir],
        page: 2,
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'фильтр «Казахстан» перезапускает поиск с новым параметром',
    setUp: () => when(() => repository.search('молоко', kazakhstanOnly: false)).thenAnswer(
      (_) async => const SearchResult(products: [milk, kefir], page: 1, hasMore: false),
    ),
    build: buildBloc,
    seed: () => const SearchState(
      status: SearchStatus.success,
      query: 'молоко',
      products: [milk],
      page: 1,
    ),
    act: (bloc) => bloc.add(const SearchCountryToggled(false)),
    expect: () => const [
      SearchState(status: SearchStatus.loading, query: 'молоко', kazakhstanOnly: false),
      SearchState(
        status: SearchStatus.success,
        query: 'молоко',
        products: [milk, kefir],
        page: 1,
        kazakhstanOnly: false,
      ),
    ],
  );
}
