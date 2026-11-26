
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_api.dart';
import '../models/product.dart';

sealed class DetailsState {}

class DetailsLoading extends DetailsState {}

class DetailsError extends DetailsState {
  DetailsError(this.message);

  final String message;
}

class DetailsLoaded extends DetailsState {
  DetailsLoaded(this.product);

  final Product product;
}

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this._api) : super(DetailsLoading());

  final ProductApi _api;

  Future<void> load(int id) async {
    emit(DetailsLoading());

    try {
      final product = await _api.getProduct(id);

      if (isClosed) return;

      emit(DetailsLoaded(product));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(DetailsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(DetailsError('Something went wrong.'));
    }
  }
}
