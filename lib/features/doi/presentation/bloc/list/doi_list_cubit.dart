import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/doi_repository.dart';
import 'doi_list_state.dart';

/// Загружает каталог и держит поисковый запрос экрана списка.
class DoiListCubit extends Cubit<DoiListState> {
  DoiListCubit(this._repository) : super(const DoiListState());

  final DoiRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: DoiListStatus.loading, error: null));
    try {
      final records = await _repository.getDois();
      emit(state.copyWith(status: DoiListStatus.loaded, records: records));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: DoiListStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// Обновляет поисковый запрос; фильтрация — синхронная по уже
  /// загруженному каталогу.
  void search(String query) => emit(state.copyWith(query: query));

  void resetSearch() => emit(state.copyWith(query: ''));
}
