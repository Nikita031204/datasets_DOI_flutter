/// Мок-каталог DOI в формате JSON:API — ровно как отдаёт
/// `GET https://api.datacite.org/dois` (обёртка `data`, поля в `attributes`).
///
/// Репозиторий прогоняет эти map'ы через `DoiRecord.listFromJsonApi`, так что
/// моки проверяют маппер так же, как реальный ответ API. Часть записей
/// нарочно неполная (без описания, без авторов, publisher объектом) —
/// API так и отвечает на «молодые» записи.
///
/// Записи связаны через relatedIdentifiers: с карточки «Global Sea Surface
/// Temperature» можно уйти к статье, от неё — к препринту и софту и т.д.
/// Пара ссылок ведёт на DOI вне каталога — чтобы показать обработку
/// «запись не найдена».
library;

const Map<String, dynamic> kDoiCatalogJsonApi = {
  'meta': {'total': 10, 'page': 1, 'pageSize': 25},
  'data': [
    // 1. Крупный датасет — хаб, с которого расходится граф связей.
    {
      'id': '10.82152/sst-global-1980-2023',
      'type': 'dois',
      'attributes': {
        'doi': '10.82152/sst-global-1980-2023',
        'identifiers': [
          {'identifier': 'http://hdl.handle.net/11373/sst-1980-2023', 'identifierType': 'uri'},
        ],
        'creators': [
          {
            'name': 'Vasquez, Elena',
            'givenName': 'Elena',
            'familyName': 'Vasquez',
            'affiliation': [
              {'name': 'Marine Data Archive'},
            ],
          },
          {
            'name': 'Chen, Marcus',
            'givenName': 'Marcus',
            'familyName': 'Chen',
            'affiliation': [
              {'name': 'Institute of Oceanography'},
            ],
          },
        ],
        'titles': [
          {'title': 'Global Sea Surface Temperature Analysis 1980–2023', 'lang': 'en'},
          {'title': 'Version 2.1, gap-filled product', 'titleType': 'Subtitle'},
        ],
        'publisher': 'Marine Data Archive',
        'publicationYear': 2024,
        'subjects': [
          {'subject': 'sea surface temperature', 'subjectScheme': 'GCMD'},
          {'subject': 'climate reanalysis'},
          {'subject': 'oceanography'},
        ],
        'dates': [
          {'date': '1980-01-01/2023-12-31', 'dateType': 'Collected'},
          {'date': '2024-03-12', 'dateType': 'Issued'},
        ],
        'language': 'en',
        'types': {
          'resourceTypeGeneral': 'Dataset',
          'resourceType': 'gridded observations',
          'schemaOrg': 'Dataset',
          'bibtex': 'misc',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.1029/2023gl107894',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsReferencedBy',
            'resourceTypeGeneral': 'JournalArticle',
          },
          {
            'relatedIdentifier': '10.1234/ncomms.2024.1987',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsSupplementTo',
            'resourceTypeGeneral': 'JournalArticle',
          },
          {
            'relatedIdentifier': 'https://data.marine-archive.org/sst/v2.1',
            'relatedIdentifierType': 'URL',
            'relationType': 'IsVariantFormOf',
          },
        ],
        'sizes': ['14.2 GB', '3552 grid cells x 16032 time steps'],
        'formats': ['NetCDF-4'],
        'version': '2.1',
        'rightsList': [
          {
            'rights': 'Creative Commons Attribution 4.0 International',
            'rightsUri': 'https://creativecommons.org/licenses/by/4.0/',
          },
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'Gap-filled daily sea surface temperature fields on a 0.25° grid, '
                'blended from in-situ buoy measurements and satellite radiometry. '
                'Bias correction follows the method of Vasquez & Chen (2021). '
                'The product is the base dataset for the subpolar gyre studies '
                'cited below.',
            'lang': 'en',
          },
        ],
        'url': 'https://data.marine-archive.org/sst/v2.1',
        'isActive': true,
        'state': 'findable',
        'viewCount': 18422,
        'downloadCount': 3611,
        'citationCount': 57,
        'referenceCount': 24,
        'created': '2024-03-12T09:14:22.000Z',
        'updated': '2024-11-02T17:40:03.000Z',
      },
    },

    // 2. Сырая телеметрия буйковой сети; publisher объектом, чтобы
    //    проверить этот вариант схемы.
    {
      'id': '10.17882/polar-observatory-42',
      'type': 'dois',
      'attributes': {
        'doi': '10.17882/polar-observatory-42',
        'creators': [
          {'name': 'Polar Observatory Team'},
        ],
        'titles': [
          {'title': 'Polar Observatory Buoy Network: Raw Telemetry 2019–2024'},
        ],
        'publisher': {'name': 'Polar Data Centre', 'publisherIdentifier': 'https://ror.org/04qw2xh42'},
        'publicationYear': 2024,
        'subjects': [
          {'subject': 'polar oceanography'},
          {'subject': 'buoy telemetry'},
        ],
        'dates': [
          {'date': '2019-06-01/2024-05-31', 'dateType': 'Collected'},
        ],
        'types': {
          'resourceTypeGeneral': 'Dataset',
          'resourceType': 'time series',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.82152/sst-global-1980-2023',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsDerivedFrom',
            'resourceTypeGeneral': 'Dataset',
          },
          {
            'relatedIdentifier': '10.17882/polar-buoy-07',
            'relatedIdentifierType': 'DOI',
            'relationType': 'HasPart',
            'resourceTypeGeneral': 'Dataset',
          },
        ],
        'sizes': ['880 MB'],
        'formats': ['CSV', 'JSON Lines'],
        'rightsList': [
          {'rights': 'Creative Commons Zero v1.0 Universal', 'rightsUri': 'https://creativecommons.org/publicdomain/zero/1.0/'},
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'Unprocessed positioning, thermistor and salinity telemetry from '
                '14 drifting buoys deployed across the Fram Strait. Calibrated '
                'per-buoy subsets (see HasPart) feed the gap-filling pipeline of '
                'the global SST product.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 5310,
        'downloadCount': 1204,
        'citationCount': 9,
        'referenceCount': 3,
        'created': '2024-08-01T12:00:00.000Z',
        'updated': '2024-09-15T08:30:00.000Z',
      },
    },

    // 3. Софт для сегментации морского льда.
    {
      'id': '10.5281/zenodo.seaicenet',
      'type': 'dois',
      'attributes': {
        'doi': '10.5281/zenodo.seaicenet',
        'creators': [
          {'name': 'Okafor, Amara', 'affiliation': [{'name': 'NTNU'}]},
          {'name': 'Lindqvist, Johan', 'affiliation': [{'name': 'NTNU'}, {'name': 'MET Norway'}]},
        ],
        'titles': [
          {'title': 'SeaIceNet: U-Net for daily sea-ice concentration mapping'},
        ],
        'publisher': 'Zenodo',
        'publicationYear': 2024,
        'dates': [
          {'date': '2024-02-20', 'dateType': 'Issued'},
        ],
        'language': 'en',
        'types': {
          'resourceTypeGeneral': 'Software',
          'resourceType': 'python package',
          'schemaOrg': 'SoftwareSourceCode',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.5281/zenodo.xarray-sst',
            'relatedIdentifierType': 'DOI',
            'relationType': 'Requires',
            'resourceTypeGeneral': 'Software',
          },
          {
            'relatedIdentifier': '10.82152/sst-global-1980-2023',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsSupplementedBy',
            'resourceTypeGeneral': 'Dataset',
          },
          {
            'relatedIdentifier': '10.48550/arXiv.2401.04321',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsCitedBy',
            'resourceTypeGeneral': 'Preprint',
          },
        ],
        'formats': ['.whl'],
        'version': '1.3.0',
        'rightsList': [
          {'rights': 'MIT License', 'rightsUri': 'https://opensource.org/licenses/MIT'},
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'PyTorch implementation of a U-Net trained on manually charted '
                'ice charts. Produces daily 4 km sea-ice concentration rasters '
                'from passive microwave inputs; used operationally by two '
                'met-ocean services.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 9277,
        'downloadCount': 4106,
        'citationCount': 31,
        'referenceCount': 12,
        'created': '2024-02-20T10:11:00.000Z',
        'updated': '2024-10-19T21:05:41.000Z',
      },
    },

    // 4. Статья, к которой сходятся датасет и софт.
    {
      'id': '10.1234/ncomms.2024.1987',
      'type': 'dois',
      'attributes': {
        'doi': '10.1234/ncomms.2024.1987',
        'creators': [
          {'name': 'Ferreira, Bruno'},
          {'name': 'Sato, Yuki'},
          {'name': 'Kowalski, Piotr'},
          {'name': 'Nguyen, Thao'},
        ],
        'titles': [
          {'title': 'Accelerated warming shifts the North Atlantic bloom season'},
        ],
        'publisher': 'Nature Publishing Group',
        'container': {'title': 'Nature Communications', 'type': 'Journal', 'volume': '15', 'issue': '4'},
        'publicationYear': 2024,
        'subjects': [
          {'subject': 'marine ecology'},
          {'subject': 'subpolar gyre'},
        ],
        'dates': [
          {'date': '2024-04-18', 'dateType': 'Issued'},
        ],
        'types': {
          'resourceTypeGeneral': 'JournalArticle',
          'resourceType': 'Article',
          'bibtex': 'article',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.82152/sst-global-1980-2023',
            'relatedIdentifierType': 'DOI',
            'relationType': 'References',
            'resourceTypeGeneral': 'Dataset',
          },
          {
            'relatedIdentifier': '10.5281/zenodo.seaicenet',
            'relatedIdentifierType': 'DOI',
            'relationType': 'References',
            'resourceTypeGeneral': 'Software',
          },
          {
            'relatedIdentifier': '10.48550/arXiv.2401.04321',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsCitedBy',
            'resourceTypeGeneral': 'Preprint',
          },
        ],
        // Нарочно без sizes/descriptions крупного плана — только аннотация.
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'Using the gap-filled SST product, we show that the spring bloom '
                'onset in the subpolar North Atlantic advanced by 6.4 days per '
                'decade since 1980. The shift is driven by stratification '
                'changes rather than absolute warming.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 30155,
        'downloadCount': 8823,
        'citationCount': 112,
        'referenceCount': 78,
        'created': '2024-04-18T00:00:00.000Z',
        'updated': '2024-12-01T11:11:11.000Z',
      },
    },

    // 5. Модель коры Гренландского шельфа.
    {
      'id': '10.5880/gfz.2024.003',
      'type': 'dois',
      'attributes': {
        'doi': '10.5880/gfz.2024.003',
        'creators': [
          {'name': 'Bergmann, Katja', 'affiliation': [{'name': 'GFZ German Research Centre for Geosciences'}]},
          {'name': 'Almeida, Rafael'},
        ],
        'titles': [
          {'title': 'Crustal structure model of the Greenland shelf from joint inversion'},
        ],
        'publisher': 'GFZ Data Services',
        'publicationYear': 2024,
        'dates': [
          {'date': '2024-06-30', 'dateType': 'Issued'},
        ],
        'types': {
          'resourceTypeGeneral': 'Dataset',
          'resourceType': 'model',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.1029/2023gl107894',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsCitedBy',
            'resourceTypeGeneral': 'JournalArticle',
          },
        ],
        'sizes': ['2.1 GB'],
        'formats': ['VTK', 'GeoTIFF'],
        'rightsList': [
          {'rights': 'Creative Commons Attribution 4.0 International'},
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                '3D density model of the Greenland shelf obtained by joint '
                'inversion of gravity, magnetic and refraction seismic data. '
                'Grid resolution 5 km, 42 depth layers down to the Moho.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 2210,
        'downloadCount': 512,
        'citationCount': 6,
        'referenceCount': 15,
        'created': '2024-06-30T00:00:00.000Z',
        'updated': '2024-06-30T00:00:00.000Z',
      },
    },

    // 6. Калибровочный мини-датасет: без авторов и описания —
    //    проверка «молодой» записи.
    {
      'id': '10.17882/polar-buoy-07',
      'type': 'dois',
      'attributes': {
        'doi': '10.17882/polar-buoy-07',
        'creators': [],
        'titles': [
          {'title': 'Buoy P-07: calibration dataset, drift leg 2022–2023'},
        ],
        'publisher': 'Polar Data Centre',
        'publicationYear': 2023,
        'types': {'resourceTypeGeneral': 'Dataset'},
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.17882/polar-observatory-42',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsPartOf',
            'resourceTypeGeneral': 'Dataset',
          },
        ],
        'formats': ['CSV'],
        'isActive': true,
        'state': 'registered',
        'viewCount': 344,
        'downloadCount': 51,
        'citationCount': 0,
        'referenceCount': 0,
        'created': '2023-11-05T00:00:00.000Z',
        'updated': '2023-11-05T00:00:00.000Z',
      },
    },

    // 7. Питоновские загрузчики климатических архивов.
    {
      'id': '10.5281/zenodo.xarray-sst',
      'type': 'dois',
      'attributes': {
        'doi': '10.5281/zenodo.xarray-sst',
        'creators': [
          {'name': 'Okafor, Amara'},
          {'name': 'Duarte, Ines'},
        ],
        'titles': [
          {'title': 'xarray-sst: streaming loaders for climate data archives'},
        ],
        'publisher': 'Zenodo',
        'publicationYear': 2023,
        'dates': [
          {'date': '2023-09-10', 'dateType': 'Issued'},
        ],
        'types': {
          'resourceTypeGeneral': 'Software',
          'schemaOrg': 'SoftwareSourceCode',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.5281/zenodo.seaicenet',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsRequiredBy',
            'resourceTypeGeneral': 'Software',
          },
          {
            'relatedIdentifier': '10.1029/2023gl107894',
            'relatedIdentifierType': 'DOI',
            'relationType': 'IsCitedBy',
            'resourceTypeGeneral': 'JournalArticle',
          },
        ],
        'version': '0.9.4',
        'rightsList': [
          {'rights': 'Apache License 2.0'},
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'Small companion library providing chunked, cloud-friendly '
                'xarray accessors for NetCDF archives such as the global SST '
                'product. Zero-copy decoding for CF-compliant files.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 4021,
        'downloadCount': 1890,
        'citationCount': 17,
        'referenceCount': 5,
        'created': '2023-09-10T00:00:00.000Z',
        'updated': '2024-01-22T00:00:00.000Z',
      },
    },

    // 8. Обзорный препринт.
    {
      'id': '10.48550/arXiv.2401.04321',
      'type': 'dois',
      'attributes': {
        'doi': '10.48550/arXiv.2401.04321',
        'creators': [
          {'name': 'Haddad, Layla'},
          {'name': 'Sato, Yuki'},
        ],
        'titles': [
          {'title': 'Machine learning for polar oceanography: a survey'},
        ],
        'publisher': 'arXiv',
        'publicationYear': 2024,
        'dates': [
          {'date': '2024-01-09', 'dateType': 'Submitted'},
        ],
        'types': {
          'resourceTypeGeneral': 'Preprint',
          'resourceType': 'survey',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.1234/ncomms.2024.1987',
            'relatedIdentifierType': 'DOI',
            'relationType': 'References',
            'resourceTypeGeneral': 'JournalArticle',
          },
          {
            'relatedIdentifier': 'https://arxiv.org/abs/2401.04321',
            'relatedIdentifierType': 'URL',
            'relationType': 'IsVariantFormOf',
          },
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'We review 214 studies applying machine learning to sea-ice '
                'charting, buoy telemetry and ocean reanalysis, and outline '
                'open problems in uncertainty quantification for operational '
                'forecasting.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 12087,
        'downloadCount': 3022,
        'citationCount': 44,
        'referenceCount': 214,
        'created': '2024-01-09T00:00:00.000Z',
        'updated': '2024-01-09T00:00:00.000Z',
      },
    },

    // 9. Статья ГРЛ о субполярной циркуляции.
    {
      'id': '10.1029/2023gl107894',
      'type': 'dois',
      'attributes': {
        'doi': '10.1029/2023gl107894',
        'creators': [
          {'name': 'Novak, Tomas'},
          {'name': 'Bergmann, Katja'},
        ],
        'titles': [
          {'title': 'Observational constraints on the subpolar gyre overturning'},
        ],
        'publisher': 'American Geophysical Union',
        'container': {'title': 'Geophysical Research Letters', 'type': 'Journal', 'volume': '51', 'issue': '2'},
        'publicationYear': 2024,
        'dates': [
          {'date': '2024-01-28', 'dateType': 'Issued'},
        ],
        'types': {
          'resourceTypeGeneral': 'JournalArticle',
          'bibtex': 'article',
        },
        'relatedIdentifiers': [
          {
            'relatedIdentifier': '10.82152/sst-global-1980-2023',
            'relatedIdentifierType': 'DOI',
            'relationType': 'References',
            'resourceTypeGeneral': 'Dataset',
          },
          {
            'relatedIdentifier': '10.5880/gfz.2024.003',
            'relatedIdentifierType': 'DOI',
            'relationType': 'Cites',
            'resourceTypeGeneral': 'Dataset',
          },
          {
            'relatedIdentifier': '10.5281/zenodo.xarray-sst',
            'relatedIdentifierType': 'DOI',
            'relationType': 'References',
            'resourceTypeGeneral': 'Software',
          },
        ],
        'rightsList': [
          {'rights': 'Creative Commons Attribution 4.0 International'},
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'Moored observations and the shelf density model jointly '
                'constrain the overturning streamfunction; we find a '
                'statistically significant weakening trend of 1.8 Sv per '
                'decade in the western boundary current.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 7841,
        'downloadCount': 1980,
        'citationCount': 26,
        'referenceCount': 61,
        'created': '2024-01-28T00:00:00.000Z',
        'updated': '2024-03-03T00:00:00.000Z',
      },
    },

    // 10. Зоопланктон Балтики — листовой узел без relatedIdentifiers.
    {
      'id': '10.23729/baltic-zooplankton',
      'type': 'dois',
      'attributes': {
        'doi': '10.23729/baltic-zooplankton',
        'creators': [
          {'name': 'Sørensen, Mads', 'affiliation': [{'name': 'Aarhus University'}]},
          {'name': 'Karpova, Irina'},
        ],
        'titles': [
          {'title': 'Baltic Sea zooplankton monitoring collection 1990–2020'},
        ],
        'publisher': 'Danish National Environmental Research Institute',
        'publicationYear': 2021,
        'subjects': [
          {'subject': 'zooplankton'},
          {'subject': 'long-term monitoring'},
          {'subject': 'Baltic Sea'},
        ],
        'dates': [
          {'date': '1990-04-01/2020-10-31', 'dateType': 'Collected'},
        ],
        'types': {
          'resourceTypeGeneral': 'PhysicalObject',
          'resourceType': 'specimen collection',
        },
        'sizes': ['41 200 specimens'],
        'rightsList': [
          {'rights': 'Creative Commons Attribution 4.0 International'},
        ],
        'descriptions': [
          {
            'descriptionType': 'Abstract',
            'description':
                'Thirty years of station-based zooplankton counts across eight '
                'Baltic monitoring transects, digitised from original logbooks. '
                'Taxonomy harmonised to WoRMS in 2021.',
            'lang': 'en',
          },
        ],
        'isActive': true,
        'state': 'findable',
        'viewCount': 1502,
        'downloadCount': 389,
        'citationCount': 13,
        'referenceCount': 7,
        'created': '2021-12-14T00:00:00.000Z',
        'updated': '2022-02-08T00:00:00.000Z',
      },
    },
  ],
};

/// DOI, которого нет в каталоге, — для демонстрации обработки перехода
/// по внешней связи.
const String kMissingDoi = '10.9999/does-not-exist';
