
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import '../models/product.dart';

sealed class ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsError extends ProductsState {
  ProductsError(this.message);

  final String message;
}

class ProductsLoaded extends ProductsState {
  ProductsLoaded({
    required this.products,
    required this.total,
    this.isLoadingMore = false,
  });

  final List<Product> products;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => products.length < total;
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._api) : super(ProductsLoading());

  final ProductApi _api;

  Future<void> load() async {
    emit(ProductsLoading());

    try {
      final page = await _api.getProducts();

      if (isClosed) return;

      emit(ProductsLoaded(
        products: page.products,
        total: page.total,
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ProductsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(ProductsError('Something went wrong.'));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;

    if (currentState is! ProductsLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(ProductsLoaded(
      products: currentState.products,
      total: currentState.total,
      isLoadingMore: true,
    ));

    try {
      final page = await _api.getProducts(
        skip: currentState.products.length,
      );

      if (isClosed) return;

      emit(ProductsLoaded(
        products: [...currentState.products, ...page.products],
        total: page.total,
      ));
    } on ApiException {
      if (isClosed) return;

      emit(ProductsLoaded(
        products: currentState.products,
        total: currentState.total,
      ));
    } catch (_) {
      if (isClosed) return;

      emit(ProductsLoaded(
        products: currentState.products,
        total: currentState.total,
      ));
    }
  }
}
