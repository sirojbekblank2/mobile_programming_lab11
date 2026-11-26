
import '../models/product.dart';

sealed class SearchState {}

class SearchIdle extends SearchState {}

class SearchLoading extends SearchState {}

class SearchEmpty extends SearchState {
  SearchEmpty(this.query);

  final String query;
}

class SearchResults extends SearchState {
  SearchResults(this.products);

  final List<Product> products;
}

class SearchError extends SearchState {
  SearchError(this.message);

  final String message;
}
