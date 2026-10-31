import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/doi_repository.dart';
import 'doi_detail_state.dart';

/// Загружает одну запись по DOI из пути `/doi/<doi>`.
class DoiDetailCubit extends Cubit<DoiDetailState> {
  DoiDetailCubit(this._repository, this.doi) : super(const DoiDetailState()) {
    load();
  }

  final DoiRepository _repository;
  final String doi;

  Future<void> load() async {
    emit(const DoiDetailState(status: DoiDetailStatus.loading));
    try {
      final record = await _repository.getByDoi(doi);
      emit(DoiDetailState(status: DoiDetailStatus.loaded, record: record));
    } on DoiNotFoundException {
      emit(DoiDetailState(status: DoiDetailStatus.notFound, error: doi));
    } on Exception catch (e) {
      emit(DoiDetailState(status: DoiDetailStatus.error, error: e.toString()));
    }
  }
}
