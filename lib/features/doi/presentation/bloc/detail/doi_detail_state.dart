import 'package:equatable/equatable.dart';

import '../../../domain/doi_record.dart';

enum DoiDetailStatus { loading, loaded, notFound, error }

/// Состояние экрана деталей одной записи DOI.
class DoiDetailState extends Equatable {
  const DoiDetailState({
    this.status = DoiDetailStatus.loading,
    this.record,
    this.error,
  });

  final DoiDetailStatus status;
  final DoiRecord? record;
  final String? error;

  DoiDetailState copyWith({
    DoiDetailStatus? status,
    DoiRecord? record,
    String? error,
  }) {
    return DoiDetailState(
      status: status ?? this.status,
      record: record ?? this.record,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, record, error];
}
