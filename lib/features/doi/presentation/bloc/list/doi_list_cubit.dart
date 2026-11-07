import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/doi_record.dart';
import '../../../domain/i_doi_repository.dart';
import 'doi_list_state.dart';

class DoiListCubit extends Cubit<DoiListState> {
  DoiListCubit(this._repository) : super(const DoiListLoading(''));

  final IDoiRepository _repository;
  List<DoiRecord> _catalog = const [];
  int _loadId = 0;

  Future<void> load() async {
    final loadId = ++_loadId;
    emit(DoiListLoading(state.query));
    try {
      final records = await _repository.getDois();
      if (isClosed || loadId != _loadId) return;
      _catalog = records;
      _showResults(state.query);
    } on Exception {
      if (isClosed || loadId != _loadId) return;
      emit(DoiListError(state.query));
    }
  }

  void search(String query) {
    switch (state) {
      case DoiListLoading():
        emit(DoiListLoading(query));
      case DoiListError():
        emit(DoiListError(query));
      case DoiListLoaded() || DoiListNotFound():
        _showResults(query);
    }
  }

  void _showResults(String query) {
    final term = query.trim().toLowerCase();
    final matches = term.isEmpty
        ? _catalog
        : _catalog
              .where(
                (record) =>
                    record.title.toLowerCase().contains(term) ||
                    record.doi.toLowerCase().contains(term),
              )
              .toList();
    emit(
      matches.isEmpty
          ? DoiListNotFound(query)
          : DoiListLoaded(query, matches, _catalog.length),
    );
  }
}
