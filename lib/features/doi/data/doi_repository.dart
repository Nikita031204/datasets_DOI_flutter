import '../domain/doi_record.dart';
import '../domain/i_doi_repository.dart';
import 'doi_record_mapper.dart';
import 'mock_dois.dart';

class DoiRepository implements IDoiRepository {
  final _catalog = List<DoiRecord>.unmodifiable(
    DoiRecordMapper.listFromJsonApi(kDoiCatalogJsonApi),
  );

  @override
  Future<List<DoiRecord>> getDois() async => _catalog;

  @override
  Future<DoiRecord?> getByDoi(String doi) async {
    final identifier = doi.toLowerCase();
    return _catalog
        .where((record) => record.doi.toLowerCase() == identifier)
        .firstOrNull;
  }
}
