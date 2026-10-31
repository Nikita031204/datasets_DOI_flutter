import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/doi_record.dart';

/// Реальный клиент DataCite API: `GET https://api.datacite.org/dois`.
///
/// Документация: https://support.datacite.org/docs/api
/// Ответ — JSON:API: `{ data: [...], meta: {...}, links: {...} }`, поля
/// записи лежат в `attributes` — их разбирает `DoiRecord.fromJsonApi`.
class DoiApi {
  DoiApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? 'https://api.datacite.org';

  final http.Client _client;
  final String baseUrl;

  static const _pageSize = 25;

  /// Страница каталога. [query] — полнотекстовый поиск DataCite
  /// (`?query=...`), фильтрует и по названию.
  Future<List<DoiRecord>> fetchDois({String? query, int page = 1}) async {
    final uri = Uri.parse('$baseUrl/dois').replace(
      queryParameters: {
        'page[size]': '$_pageSize',
        'page[number]': '$page',
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/vnd.api+json'},
    );

    if (response.statusCode != 200) {
      throw http.ClientException(
        'DataCite API ${response.statusCode}: ${response.reasonPhrase}',
        uri,
      );
    }
    return DoiRecord.listFromJsonApi(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  /// Одна запись по DOI: `GET /dois/{id}`.
  Future<DoiRecord> fetchDoi(String doi) async {
    final uri = Uri.parse('$baseUrl/dois/${Uri.encodeComponent(doi)}');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/vnd.api+json'},
    );

    if (response.statusCode == 404) {
      throw StateError('DOI $doi не найден в DataCite');
    }
    if (response.statusCode != 200) {
      throw http.ClientException(
        'DataCite API ${response.statusCode}: ${response.reasonPhrase}',
        uri,
      );
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Неожиданный формат ответа для $doi');
    }
    return DoiRecord.fromJsonApi(data);
  }
}
