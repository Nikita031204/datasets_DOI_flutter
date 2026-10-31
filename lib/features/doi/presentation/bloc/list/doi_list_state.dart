import 'package:equatable/equatable.dart';

import '../../../data/doi_repository.dart';
import '../../../domain/doi_record.dart';

enum DoiListStatus { initial, loading, loaded, error }

/// Состояние экрана каталога: полный список + строка поиска.
/// Отфильтрованное подмножество считается на лету — источник правды один.
class DoiListState extends Equatable {
  const DoiListState({
    this.status = DoiListStatus.initial,
    this.records = const [],
    this.query = '',
    this.error,
  });

  final DoiListStatus status;
  final List<DoiRecord> records;
  final String query;
  final String? error;

  /// Записи после фильтрации по поисковому запросу.
  List<DoiRecord> get visible => DoiRepository.filterByQuery(records, query);

  DoiListState copyWith({
    DoiListStatus? status,
    List<DoiRecord>? records,
    String? query,
    String? error,
  }) {
    return DoiListState(
      status: status ?? this.status,
      records: records ?? this.records,
      query: query ?? this.query,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, records, query, error];
}
