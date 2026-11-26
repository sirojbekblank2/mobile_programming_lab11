
sealed class SearchEvent {}

class SearchSubmitted extends SearchEvent {
  SearchSubmitted(this.query);

  final String query;
}

class SearchCleared extends SearchEvent {}
