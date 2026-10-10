import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

enum PopularStatus { loading, success, failure }

class PopularState extends Equatable {
  const PopularState({
    this.status = PopularStatus.loading,
    this.products = const [],
    this.fromCache = false,
  });

  final PopularStatus status;
  final List<Product> products;
  final bool fromCache;

  @override
  List<Object?> get props => [status, products, fromCache];
}

/// Популярные казахстанские продукты для главного экрана.
class PopularCubit extends Cubit<PopularState> {
  PopularCubit(this._repository) : super(const PopularState());

  final ProductRepository _repository;

  Future<void> load() async {
    emit(const PopularState());
    try {
      final result = await _repository.getPopularInKazakhstan();
      if (isClosed) return;
      emit(PopularState(
        status: PopularStatus.success,
        products: result.products,
        fromCache: result.fromCache,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(const PopularState(status: PopularStatus.failure));
    }
  }
}
