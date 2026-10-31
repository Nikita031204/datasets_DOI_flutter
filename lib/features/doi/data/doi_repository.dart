import '../domain/doi_record.dart';
import 'doi_api.dart';
import 'mock_dois.dart';

/// Единая точка доступа к каталогу для UI.
///
/// Сейчас работает на моках, но прогоняет их через настоящий маппер
/// JSON:API, так что переключение на реальный api.datacite.org
/// (`useApi: true`) не требует правок в UI.
class DoiRepository {
  DoiRepository({this.useApi = false, DoiApi? api})
      : _api = api ?? DoiApi();

  final bool useApi;

  final DoiApi _api;

  /// Каталог, распарсенный из моков. Как и в реальном API, ответы
  /// «находятся» мгновенно, но возвращаем Future, чтобы сигнатуры
  /// cubit'ов не пришлось менять при переходе на сеть.
  List<DoiRecord> get _catalog =>
      DoiRecord.listFromJsonApi(kDoiCatalogJsonApi);

  Future<List<DoiRecord>> getDois({String? query}) async {
    if (useApi) {
      return _api.fetchDois(query: query);
    }
    // Имитация задержки сети, чтобы показать состояния загрузки.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = _catalog;
    return filterByQuery(all, query);
  }

  /// Одна запись по DOI. Бросает [DoiNotFoundException], если записи нет.
  Future<DoiRecord> getByDoi(String doi) async {
    if (useApi) {
      return _api.fetchDoi(doi);
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final found = _catalog.where((r) => r.doi == doi).firstOrNull;
    if (found == null) throw DoiNotFoundException(doi);
    return found;
  }

  /// Есть ли запись в локальном каталоге — для обработчика тапа по
  /// relatedIdentifier до навигации.
  Future<bool> containsDoi(String doi) async {
    if (useApi) return _api.fetchDoi(doi).then((_) => true);
    return _catalog.any((r) => r.doi == doi);
  }

  /// Поиск по названию (регистронезависимо); заодно ищет по DOI —
  /// вводить `10.5880/...` тоже удобно.
  static List<DoiRecord> filterByQuery(
    List<DoiRecord> records,
    String? query,
  ) {
    final q = query?.trim().toLowerCase() ?? '';
    if (q.isEmpty) return records;
    return records
        .where(
          (r) =>
              r.title.toLowerCase().contains(q) ||
              r.doi.toLowerCase().contains(q),
        )
        .toList();
  }
}

class DoiNotFoundException implements Exception {
  DoiNotFoundException(this.doi);

  final String doi;

  @override
  String toString() => 'Запись $doi отсутствует в каталоге';
}
