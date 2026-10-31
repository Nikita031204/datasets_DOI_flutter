/// Доменная модель записи DOI и маппер из JSON:API.
///
/// DataCite отдаёт данные в формате JSON:API: каждая запись — обёртка
/// `{ id, type: "dois", attributes: {...} }`, список — `{ data: [...], meta, links }`.
/// Маппер живёт здесь же (`fromJsonApi`), чтобы слой данных не протаскивал
/// сырые map'ы выше по дереву.
///
/// Документация API: https://support.datacite.org/docs/api
library;

/// Запись каталога: датасет, статья, софт, препринт и т.д.
class DoiRecord {
  const DoiRecord({
    required this.doi,
    this.url,
    this.titles = const [],
    this.publisher,
    this.publicationYear,
    this.creators = const [],
    this.contributors = const [],
    this.descriptions = const [],
    this.subjects = const [],
    this.dates = const [],
    this.rightsList = const [],
    this.relatedIdentifiers = const [],
    this.types = const {},
    this.language,
    this.version,
    this.sizes = const [],
    this.formats = const [],
    this.container,
    this.state,
    this.isActive,
    this.viewCount = 0,
    this.downloadCount = 0,
    this.citationCount = 0,
    this.referenceCount = 0,
    this.created,
    this.updated,
  });

  /// Устойчивый идентификатор, напр. `10.5281/zenodo.1470228`.
  final String doi;
  final String? url;

  /// Заголовки записи: основной + при наличии подзаголовок/переводные.
  final List<DoiTitle> titles;
  final String? publisher;
  final int? publicationYear;
  final List<DoiPerson> creators;
  final List<DoiPerson> contributors;
  final List<DoiDescription> descriptions;
  final List<DoiSubject> subjects;
  final List<DoiDate> dates;
  final List<DoiRights> rightsList;

  /// Связанные записи — по ним строится переход между карточками каталога.
  final List<RelatedIdentifier> relatedIdentifiers;

  /// Словарь типов DataCite: resourceTypeGeneral, resourceType, bibtex…
  final Map<String, String> types;

  final String? language;
  final String? version;
  final List<String> sizes;
  final List<String> formats;
  final DoiContainer? container;

  /// Жизненный цикл метаданных: `draft` / `registered` / `findable`.
  final String? state;
  final bool? isActive;
  final int viewCount;
  final int downloadCount;
  final int citationCount;
  final int referenceCount;
  final DateTime? created;
  final DateTime? updated;

  /// Главный заголовок (без `titleType`); запасной вариант — сам DOI.
  String get title {
    for (final t in titles) {
      if (t.titleType == null || t.titleType!.isEmpty) return t.title;
    }
    return titles.firstOrNull?.title ?? doi;
  }

  String? get subtitle {
    for (final t in titles) {
      if (t.titleType == 'Subtitle') return t.title;
    }
    return null;
  }

  /// Крупная категория ресурса: `Dataset`, `JournalArticle`, `Software`…
  String? get resourceTypeGeneral => types['resourceTypeGeneral'];

  /// Уточнение от регистратора, напр. `master thesis`.
  String? get resourceType => types['resourceType'];

  /// `Иванов A., Petrov B. et al.` — для строки под заголовком в списке.
  String get authorsLine {
    if (creators.isEmpty) return 'Автор не указан';
    final names = creators.take(3).map((c) => c.shortName).toList();
    final suffix = creators.length > 3 ? ' et al.' : '';
    return '${names.join(', ')}$suffix';
  }

  /// Ссылка на карточку записи внутри приложения.
  String get routePath => '/doi/${Uri.encodeComponent(doi)}';

  /// Обёртка JSON:API `{ id, type, attributes }` → модель.
  factory DoiRecord.fromJsonApi(Map<String, dynamic> json) {
    final attrs = _map(json['attributes']) ?? const {};

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
      titles: _mapList(
        attrs['titles'],
        (m) => DoiTitle(
          title: _str(m['title']) ?? '',
          titleType: _str(m['titleType']),
          lang: _str(m['lang']),
        ),
      ).where((t) => t.title.isNotEmpty).toList(),
      publisher: publisher,
      publicationYear: _int(attrs['publicationYear']),
      creators: _parsePeople(attrs['creators']),
      contributors: _parsePeople(attrs['contributors']),
      descriptions: _parseDescriptions(attrs),
      subjects: _mapList(
        attrs['subjects'],
        (m) => DoiSubject(
          subject: _str(m['subject']) ?? '',
          scheme: _str(m['subjectScheme']),
        ),
      ).where((s) => s.subject.isNotEmpty).toList(),
      dates: _mapList(
        attrs['dates'],
        (m) => DoiDate(
          date: _str(m['date']) ?? '',
          dateType: _str(m['dateType']),
        ),
      ).where((d) => d.date.isNotEmpty).toList(),
      rightsList: _mapList(
        attrs['rightsList'],
        (m) => DoiRights(
          rights: _str(m['rights']) ?? '',
          rightsUri: _str(m['rightsUri']),
        ),
      ).where((r) => r.rights.isNotEmpty).toList(),
      relatedIdentifiers: _mapList(
        attrs['relatedIdentifiers'],
        (m) => RelatedIdentifier(
          relatedIdentifier: _str(m['relatedIdentifier']) ?? '',
          relatedIdentifierType: _str(m['relatedIdentifierType']),
          relationType: _str(m['relationType']),
          resourceTypeGeneral: _str(m['resourceTypeGeneral']),
        ),
      ).where((r) => r.relatedIdentifier.isNotEmpty).toList(),
      types: _map(attrs['types'])?.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ) ??
          const {},
      language: _str(attrs['language']),
      version: _str(attrs['version']),
      sizes: _stringList(attrs['sizes']),
      formats: _stringList(attrs['formats']),
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
    return data
        .map(_map)
        .nonNulls
        .map(DoiRecord.fromJsonApi)
        .toList();
  }

  static List<DoiPerson> _parsePeople(Object? raw) => _mapList(
        raw,
        (m) {
          final name = _str(m['name']) ??
              [
                _str(m['familyName']),
                _str(m['givenName']),
              ].nonNulls.join(' ');
          final affiliations = _stringList(m['affiliation']);
          return DoiPerson(
            name: name,
            affiliation: affiliations.isEmpty ? null : affiliations.join(', '),
            contributorType: _str(m['contributorType']),
          );
        },
      ).where((p) => p.name.isNotEmpty).toList();

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

/// Заголовок записи. `titleType == null` — основной заголовок.
class DoiTitle {
  const DoiTitle({required this.title, this.titleType, this.lang});

  final String title;
  final String? titleType;
  final String? lang;
}

/// Автор или контрибutor записи.
class DoiPerson {
  const DoiPerson({
    required this.name,
    this.affiliation,
    this.contributorType,
  });

  final String name;
  final String? affiliation;
  final String? contributorType;

  /// Короткая форма для списка: `Фамилия И. О.`, если удалось распознать.
  String get shortName {
    final parts = name.split(RegExp(r',\s*'));
    if (parts.length == 2 && parts[1].isNotEmpty) {
      final initials = parts[1]
          .split(RegExp(r'\s+'))
          .where((g) => g.isNotEmpty)
          .map((g) => '${g[0].toUpperCase()}.')
          .join();
      return '${parts[0]} $initials';
    }
    return name;
  }
}

/// Абстракт или прочее описание записи.
class DoiDescription {
  const DoiDescription({required this.description, this.descriptionType});

  final String description;
  final String? descriptionType;
}

class DoiSubject {
  const DoiSubject({required this.subject, this.scheme});

  final String subject;
  final String? scheme;
}

class DoiDate {
  const DoiDate({required this.date, this.dateType});

  final String date;
  final String? dateType;
}

class DoiRights {
  const DoiRights({required this.rights, this.rightsUri});

  final String rights;
  final String? rightsUri;
}

/// Журнал/сборник, в котором вышла запись.
class DoiContainer {
  const DoiContainer({this.title, this.type, this.volume, this.issue});

  final String? title;
  final String? type;
  final String? volume;
  final String? issue;
}

/// Связанный идентификатор из `attributes.relatedIdentifiers`.
class RelatedIdentifier {
  const RelatedIdentifier({
    required this.relatedIdentifier,
    this.relatedIdentifierType,
    this.relationType,
    this.resourceTypeGeneral,
  });

  final String relatedIdentifier;

  /// `DOI`, `URL`, `arXiv`, `PMID`…
  final String? relatedIdentifierType;

  /// `References`, `IsCitedBy`, `IsSupplementTo`…
  final String? relationType;
  final String? resourceTypeGeneral;

  /// По DOI можно перейти внутри каталога, остальное — внешние ссылки.
  bool get isDoi =>
      relatedIdentifierType?.toUpperCase() == 'DOI' ||
      relatedIdentifier.toLowerCase().startsWith('10.');

  /// Ссылка на карточку внутри приложения.
  String get routePath => '/doi/${Uri.encodeComponent(relatedIdentifier)}';
}

// ---------------------------------------------------------------------------
// Хелперы разбора: ответ API редко приходит идеальным, поэтому всё через
// try-подобные приведения, без исключений на неожиданных типах.
// ---------------------------------------------------------------------------

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

DateTime? _date(Object? raw) =>
    raw is String ? DateTime.tryParse(raw) : null;

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
