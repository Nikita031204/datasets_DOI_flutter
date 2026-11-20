import '../../../domain/doi_record.dart';

sealed class DoiDetailState {
  const DoiDetailState();
}

final class DoiDetailLoading extends DoiDetailState {
  const DoiDetailLoading();
}

final class DoiDetailLoaded extends DoiDetailState {
  const DoiDetailLoaded(this.record);

  final DoiRecord record;
}

final class DoiDetailNotFound extends DoiDetailState {
  const DoiDetailNotFound();
}

final class DoiDetailError extends DoiDetailState {
  const DoiDetailError();
}
