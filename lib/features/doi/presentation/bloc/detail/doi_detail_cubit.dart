import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/i_doi_repository.dart';
import 'doi_detail_state.dart';

class DoiDetailCubit extends Cubit<DoiDetailState> {
  DoiDetailCubit(this._repository, this.doi) : super(const DoiDetailLoading());

  final IDoiRepository _repository;
  final String doi;
  int _loadId = 0;

  Future<void> load() async {
    final loadId = ++_loadId;
    emit(const DoiDetailLoading());
    try {
      final record = await _repository.getByDoi(doi);
      if (isClosed || loadId != _loadId) return;
      emit(
        record == null ? const DoiDetailNotFound() : DoiDetailLoaded(record),
      );
    } on Exception {
      if (isClosed || loadId != _loadId) return;
      emit(const DoiDetailError());
    }
  }
}
