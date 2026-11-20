import '../../../domain/doi_record.dart';

sealed class DoiListState {
  const DoiListState(this.query);

  final String query;
}

final class DoiListLoading extends DoiListState {
  const DoiListLoading(super.query);
}

final class DoiListLoaded extends DoiListState {
  DoiListLoaded(super.query, List<DoiRecord> records, this.totalCount)
    : records = List.unmodifiable(records);

  final List<DoiRecord> records;
  final int totalCount;
}

final class DoiListNotFound extends DoiListState {
  const DoiListNotFound(super.query);
}

final class DoiListError extends DoiListState {
  const DoiListError(super.query);
}
