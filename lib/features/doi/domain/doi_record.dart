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
    this.resourceTypeGeneral,
    this.resourceType,
    this.citationFormats = const {},
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

  final String? resourceTypeGeneral;
  final String? resourceType;
  final Map<String, String> citationFormats;

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
  const DoiPerson({required this.name, this.affiliation, this.contributorType});

  final String name;
  final String? affiliation;
  final String? contributorType;
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
}
