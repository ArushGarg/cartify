import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/debounce.dart';
import '../data/product_repository.dart';
import '../models/product_model.dart';

// ── Events ──
sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => const [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}

// ── State ──
enum SearchStatus { idle, loading, success, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.error,
  });

  final SearchStatus status;
  final String query;
  final List<Product> results;
  final String? error;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Product>? results,
    String? error,
  }) =>
      SearchState(
        status: status ?? this.status,
        query: query ?? this.query,
        results: results ?? this.results,
        error: error,
      );

  @override
  List<Object?> get props => [status, query, results, error];
}

// ── Bloc ──
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repo) : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(const Duration(milliseconds: 350)),
    );
    on<SearchCleared>((event, emit) => emit(const SearchState()));
  }

  final ProductRepository _repo;

  Future<void> _onQueryChanged(
      SearchQueryChanged event,
      Emitter<SearchState> emit,
      ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    try {
      final results = await _repo.search(query);
      emit(state.copyWith(status: SearchStatus.success, results: results));
    } catch (_) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        error: 'Search failed. Check your connection.',
      ));
    }
  }
}