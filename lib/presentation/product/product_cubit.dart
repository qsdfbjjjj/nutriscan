import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  const ProductLoaded(this.product, {this.fromCache = false});

  final Product product;
  final bool fromCache;

  @override
  List<Object?> get props => [product, fromCache];
}

class ProductError extends ProductState {
  const ProductError(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

/// Загрузка карточки продукта по штрихкоду.
class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repository) : super(const ProductLoading());

  final ProductRepository _repository;
  String? _barcode;

  Future<void> load(String barcode) async {
    _barcode = barcode;
    emit(const ProductLoading());
    try {
      final result = await _repository.getProduct(barcode);
      // Экран мог закрыться, пока шёл запрос.
      if (isClosed) return;
      emit(ProductLoaded(result.product, fromCache: result.fromCache));
    } catch (error) {
      if (isClosed) return;
      emit(ProductError(error));
    }
  }

  Future<void> retry() async {
    final barcode = _barcode;
    if (barcode != null) await load(barcode);
  }
}
