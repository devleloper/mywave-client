import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class PerformSearchEvent extends SearchEvent {
  final String query;

  const PerformSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends SearchEvent {}
