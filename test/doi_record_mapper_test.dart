import 'package:flutter_test/flutter_test.dart';

import 'package:doi_catalog/features/doi/data/mock_dois.dart';
import 'package:doi_catalog/common/navigation/app_router.dart';
import 'package:doi_catalog/features/doi/data/doi_record_mapper.dart';
import 'package:doi_catalog/features/doi/presentation/utils/doi_display.dart';

void main() {
  group('DoiRecordMapper.fromJsonApi (JSON:API data/attributes)', () {
    test('разбирает обёртку data → attributes', () {
      final records = DoiRecordMapper.listFromJsonApi(kDoiCatalogJsonApi);

      expect(records, isNotEmpty);
      expect(records.length, kDoiCatalogJsonApi['data']!.length as int);

      final sst = records.firstWhere(
        (r) => r.doi == '10.82152/sst-global-1980-2023',
      );
      expect(sst.title, contains('Global Sea Surface Temperature'));
      expect(sst.subtitle, contains('Version 2.1'));
      expect(sst.publisher, 'Marine Data Archive');
      expect(sst.publicationYear, 2024);
      expect(sst.resourceTypeGeneral, 'Dataset');
      expect(sst.state, 'findable');
      expect(sst.citationCount, 57);
      expect(sst.creators, hasLength(2));
      expect(sst.authorsLine, 'Vasquez E., Chen M.');
      expect(sst.relatedIdentifiers, hasLength(3));
      expect(sst.created, isNotNull);
    });

    test('publisher бывает и объектом, и строкой', () {
      final records = DoiRecordMapper.listFromJsonApi(kDoiCatalogJsonApi);

      final objectPublisher = records.firstWhere(
        (r) => r.doi == '10.17882/polar-observatory-42',
      );
      expect(objectPublisher.publisher, 'Polar Data Centre');

      final stringPublisher = records.firstWhere(
        (r) => r.doi == '10.5880/gfz.2024.003',
      );
      expect(stringPublisher.publisher, 'GFZ Data Services');
    });

    test('запись без авторов и описания не падает', () {
      final records = DoiRecordMapper.listFromJsonApi(kDoiCatalogJsonApi);

      final buoy = records.firstWhere((r) => r.doi == '10.17882/polar-buoy-07');
      expect(buoy.creators, isEmpty);
      expect(buoy.descriptions, isEmpty);
      expect(buoy.title, isNotEmpty);
    });

    test('relatedIdentifier различает DOI и внешние ссылки', () {
      final records = DoiRecordMapper.listFromJsonApi(kDoiCatalogJsonApi);

      final sst = records.firstWhere(
        (r) => r.doi == '10.82152/sst-global-1980-2023',
      );
      final doiLink = sst.relatedIdentifiers.firstWhere(
        (r) => r.relatedIdentifier == '10.1029/2023gl107894',
      );
      final urlLink = sst.relatedIdentifiers.firstWhere(
        (r) => r.relatedIdentifierType == 'URL',
      );

      expect(doiLink.isDoi, isTrue);
      expect(
        AppRoutes.detail(doiLink.relatedIdentifier),
        '/doi/10.1029/2023gl107894',
      );
      expect(urlLink.isDoi, isFalse);
    });
  });
}
