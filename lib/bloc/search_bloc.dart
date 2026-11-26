
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../data/product_api.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._api) : super(SearchIdle()) {
    on<SearchEvent>(
      _onEvent,
      transformer: restartable(),
    );
  }

  final ProductApi _api;

  Future<void> _onEvent(
    SearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event is SearchCleared) {
      emit(SearchIdle());
      return;
    }

    if (event is! SearchSubmitted) return;

    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchIdle());
      return;
    }

    emit(SearchLoading());

    try {
      final page = await _api.search(query);

      if (emit.isDone) return;

      if (page.products.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchResults(page.products));
      }
    } on ApiException catch (e) {
      if (emit.isDone) return;
      emit(SearchError(e.message));
    } catch (_) {
      if (emit.isDone) return;
      emit(SearchError('Something went wrong.'));
    }
  }
}
