part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchFile extends SearchEvent {
  final String query;
  final String? directory;
  const SearchFile(this.directory, this.query);

  @override
  List<Object> get props => [query];
}

class SearchClear extends SearchEvent {
  const SearchClear();
}
