import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

// ======================= События =======================

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Пользователь изменил текст запроса.
class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Долистали до конца списка — нужна следующая страница.
class SearchNextPageRequested extends SearchEvent {
  const SearchNextPageRequested();
}

/// Pull-to-refresh или кнопка «Повторить».
/// [completer] завершается, когда загрузка закончилась (нужно для RefreshIndicator).
class SearchRefreshed extends SearchEvent {
  const SearchRefreshed([this.completer]);

  final Completer<void>? completer;
}

/// Включили или выключили фильтр «только Казахстан».
class SearchCountryToggled extends SearchEvent {
  const SearchCountryToggled(this.kazakhstanOnly);

  final bool kazakhstanOnly;

  @override
  List<Object?> get props => [kazakhstanOnly];
}

// ======================= Состояние =======================

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.products = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.fromCache = false,
    this.kazakhstanOnly = true,
    this.error,
  });

  final SearchStatus status;
  final String query;
  final List<Product> products;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool fromCache;
  final bool kazakhstanOnly;
  final Object? error;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Product>? products,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? fromCache,
    bool? kazakhstanOnly,
    Object? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      products: products ?? this.products,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      fromCache: fromCache ?? this.fromCache,
      kazakhstanOnly: kazakhstanOnly ?? this.kazakhstanOnly,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, query, products, page, hasMore, isLoadingMore, fromCache, kazakhstanOnly, error];
}

// ======================= BLoC =======================

/// debounce: ждём паузу в наборе текста; switchMap: если пришёл новый запрос,
/// обработка старого отменяется (ответ на устаревший запрос не попадёт на экран).
EventTransformer<E> debounceRestartable<E>(Duration duration) =>
    (events, mapper) => events.debounce(duration).switchMap(mapper);

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository, {this.debounce = const Duration(milliseconds: 400)})
      : super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged, transformer: debounceRestartable(debounce));
    on<SearchNextPageRequested>(_onNextPage);
    on<SearchRefreshed>(_onRefreshed);
    on<SearchCountryToggled>(_onCountryToggled);
  }

  final ProductRepository _repository;
  final Duration debounce;

  static const minQueryLength = 2;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query && state.status != SearchStatus.failure) return;
    if (query.length < minQueryLength) {
      // Сбрасываем поиск, только если что-то было найдено (иначе лишняя перерисовка).
      final reset = SearchState(kazakhstanOnly: state.kazakhstanOnly);
      if (state != reset) emit(reset);
      return;
    }
    emit(SearchState(
      status: SearchStatus.loading,
      query: query,
      kazakhstanOnly: state.kazakhstanOnly,
    ));
    await _loadFirstPage(query, emit);
  }

  Future<void> _onCountryToggled(
    SearchCountryToggled event,
    Emitter<SearchState> emit,
  ) async {
    if (state.query.length < minQueryLength) {
      emit(state.copyWith(kazakhstanOnly: event.kazakhstanOnly));
      return;
    }
    emit(SearchState(
      status: SearchStatus.loading,
      query: state.query,
      kazakhstanOnly: event.kazakhstanOnly,
    ));
    await _loadFirstPage(state.query, emit);
  }

  Future<void> _onRefreshed(SearchRefreshed event, Emitter<SearchState> emit) async {
    try {
      if (state.query.length >= minQueryLength) {
        if (state.status == SearchStatus.failure) {
          emit(state.copyWith(status: SearchStatus.loading));
        }
        await _loadFirstPage(state.query, emit);
      }
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _loadFirstPage(String query, Emitter<SearchState> emit) async {
    try {
      final kz = state.kazakhstanOnly;
      final result = await _repository.search(query, kazakhstanOnly: kz);
      emit(SearchState(
        status: result.products.isEmpty ? SearchStatus.empty : SearchStatus.success,
        query: query,
        products: result.products,
        page: result.page,
        hasMore: result.hasMore,
        fromCache: result.fromCache,
        kazakhstanOnly: kz,
      ));
    } catch (error) {
      emit(SearchState(
        status: SearchStatus.failure,
        query: query,
        kazakhstanOnly: state.kazakhstanOnly,
        error: error,
      ));
    }
  }

  Future<void> _onNextPage(
    SearchNextPageRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status != SearchStatus.success || !state.hasMore || state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final result = await _repository.search(
        state.query,
        page: state.page + 1,
        kazakhstanOnly: state.kazakhstanOnly,
      );
      // Убираем дубли: API иногда возвращает один продукт на соседних страницах.
      final known = state.products.map((p) => p.barcode).toSet();
      emit(state.copyWith(
        products: [...state.products, ...result.products.where((p) => known.add(p.barcode))],
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      // Ошибка догрузки не ломает уже показанный список — просто прекращаем догрузку.
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }
}
