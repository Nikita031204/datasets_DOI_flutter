import '../domain/doi_record.dart';

abstract final class DoiRecordMapper {
  /// Обёртка JSON:API `{ id, type, attributes }` → модель.
  static DoiRecord fromJsonApi(Map<String, dynamic> json) {
    final attrs = _map(json['attributes']) ?? const {};

    final types = _map(attrs['types']);
    final publisherRaw = attrs['publisher'];
    // Свежие версии схемы отдают publisher объектом { name: ... },
    // старые — строкой. Маппер принимает оба варианта.
    final publisher = switch (publisherRaw) {
      final Map<String, dynamic> m => _str(m['name']),
      final String s => s,
      _ => null,
    };

    return DoiRecord(
      doi: _str(json['doi']) ?? _str(json['id']) ?? _str(attrs['doi']) ?? '',
      url: _str(attrs['url']),
      titles: List.unmodifiable(
        _mapList(
          attrs['titles'],
          (m) => DoiTitle(
            title: _str(m['title']) ?? '',
            titleType: _str(m['titleType']),
            lang: _str(m['lang']),
          ),
        ).where((t) => t.title.isNotEmpty),
      ),
      publisher: publisher,
      publicationYear: _int(attrs['publicationYear']),
      creators: List.unmodifiable(_parsePeople(attrs['creators'])),
      contributors: List.unmodifiable(_parsePeople(attrs['contributors'])),
      descriptions: List.unmodifiable(_parseDescriptions(attrs)),
      subjects: List.unmodifiable(
        _mapList(
          attrs['subjects'],
          (m) => DoiSubject(
            subject: _str(m['subject']) ?? '',
            scheme: _str(m['subjectScheme']),
          ),
        ).where((s) => s.subject.isNotEmpty),
      ),
      dates: List.unmodifiable(
        _mapList(
          attrs['dates'],
          (m) => DoiDate(
            date: _str(m['date']) ?? '',
            dateType: _str(m['dateType']),
          ),
        ).where((d) => d.date.isNotEmpty),
      ),
      rightsList: List.unmodifiable(
        _mapList(
          attrs['rightsList'],
          (m) => DoiRights(
            rights: _str(m['rights']) ?? '',
            rightsUri: _str(m['rightsUri']),
          ),
        ).where((r) => r.rights.isNotEmpty),
      ),
      relatedIdentifiers: List.unmodifiable(
        _mapList(
          attrs['relatedIdentifiers'],
          (m) => RelatedIdentifier(
            relatedIdentifier: _str(m['relatedIdentifier']) ?? '',
            relatedIdentifierType: _str(m['relatedIdentifierType']),
            relationType: _str(m['relationType']),
            resourceTypeGeneral: _str(m['resourceTypeGeneral']),
          ),
        ).where((r) => r.relatedIdentifier.isNotEmpty),
      ),
      resourceTypeGeneral: _str(types?['resourceTypeGeneral']),
      resourceType: _str(types?['resourceType']),
      citationFormats: Map.unmodifiable({
        for (final entry in (types ?? const <String, dynamic>{}).entries)
          if (entry.key != 'resourceTypeGeneral' && entry.key != 'resourceType')
            entry.key: entry.value?.toString() ?? '',
      }),
      language: _str(attrs['language']),
      version: _str(attrs['version']),
      sizes: List.unmodifiable(_stringList(attrs['sizes'])),
      formats: List.unmodifiable(_stringList(attrs['formats'])),
      container: _map(attrs['container']) == null
          ? null
          : DoiContainer(
              title: _str(attrs['container']['title']),
              type: _str(attrs['container']['type']),
              volume: _str(attrs['container']['volume']),
              issue: _str(attrs['container']['issue']),
            ),
      state: _str(attrs['state']),
      isActive: _bool(attrs['isActive']),
      viewCount: _int(attrs['viewCount']) ?? 0,
      downloadCount: _int(attrs['downloadCount']) ?? 0,
      citationCount: _int(attrs['citationCount']) ?? 0,
      referenceCount: _int(attrs['referenceCount']) ?? 0,
      created: _date(attrs['created']),
      updated: _date(attrs['updated']),
    );
  }

  /// Ответ каталога `{ data: [ ...records ] }` → список моделей.
  static List<DoiRecord> listFromJsonApi(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! List) return const [];
    return data.map(_map).nonNulls.map(fromJsonApi).toList();
  }

  static List<DoiPerson> _parsePeople(Object? raw) => _mapList(raw, (m) {
    final name =
        _str(m['name']) ??
        [_str(m['familyName']), _str(m['givenName'])].nonNulls.join(' ');
    final affiliations = _stringList(m['affiliation']);
    return DoiPerson(
      name: name,
      affiliation: affiliations.isEmpty ? null : affiliations.join(', '),
      contributorType: _str(m['contributorType']),
    );
  }).where((p) => p.name.isNotEmpty).toList();

  /// Поле называется descriptions; старые ответы отдают description
  /// одной строкой — принимаем и такой вариант.
  static List<DoiDescription> _parseDescriptions(Map<String, dynamic> attrs) {
    final list = _mapList(
      attrs['descriptions'],
      (m) => DoiDescription(
        description: _str(m['description']) ?? '',
        descriptionType: _str(m['descriptionType']),
      ),
    ).where((d) => d.description.isNotEmpty).toList();

    if (list.isEmpty) {
      final legacy = attrs['description'];
      if (legacy is String && legacy.isNotEmpty) {
        list.add(DoiDescription(description: legacy));
      }
    }
    return list;
  }
}

Map<String, dynamic>? _map(Object? raw) =>
    raw is Map ? raw.cast<String, dynamic>() : null;

String? _str(Object? raw) {
  if (raw is String) return raw.isEmpty ? null : raw;
  if (raw is num) return raw.toString();
  return null;
}

int? _int(Object? raw) => switch (raw) {
  final int i => i,
  final num n => n.round(),
  final String s => int.tryParse(s),
  _ => null,
};

bool? _bool(Object? raw) => switch (raw) {
  final bool b => b,
  final String s => s.toLowerCase() == 'true',
  _ => null,
};

DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;

List<String> _stringList(Object? raw) => switch (raw) {
  final List l => l.map(_str).nonNulls.toList(),
  final String s => [s],
  _ => const [],
};

List<T> _mapList<T>(Object? raw, T Function(Map<String, dynamic>) map) =>
    switch (raw) {
      final List l => l.map(_map).nonNulls.map(map).toList(),
      _ => const [],
    };
