import 'doi_record.dart';

abstract interface class IDoiRepository {
  Future<List<DoiRecord>> getDois();

  /// Возвращает null, если записи с таким DOI нет.
  Future<DoiRecord?> getByDoi(String doi);
}
