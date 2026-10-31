import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doi_catalog/app.dart';
import 'package:doi_catalog/features/doi/data/doi_repository.dart';
import 'package:doi_catalog/features/doi/presentation/view/doi_list_screen.dart';

void main() {
  testWidgets('список каталога загружается и ищется по названию',
      (tester) async {
    await tester.pumpWidget(const DoiCatalogApp());

    // Первый кадр — состояние загрузки.
    expect(find.byType(DoiListScreen), findsOneWidget);

    // Дожидаемся моковой «загрузки».
    await tester.pumpAndSettle();

    // Заголовок каталога и счётчик записей на месте.
    expect(find.text('Каталог DOI'), findsOneWidget);
    expect(find.text('Записей в каталоге: 10'), findsOneWidget);

    // Ищем по слову из названия.
    await tester.enterText(find.byType(TextField), 'zooplankton');
    await tester.pump();

    expect(find.text('Найдено: 1 из 10'), findsOneWidget);
    expect(
      find.textContaining('Baltic Sea zooplankton'),
      findsOneWidget,
    );
  });

  test('репозиторий ищет по DOI и падает по неизвестному', () async {
    final repo = DoiRepository();

    expect(await repo.containsDoi('10.1029/2023gl107894'), isTrue);
    expect(await repo.containsDoi('10.9999/does-not-exist'), isFalse);
    await expectLater(
      repo.getByDoi('10.9999/does-not-exist'),
      throwsA(isA<DoiNotFoundException>()),
    );
  });

  testWidgets('тап по relatedIdentifier открывает карточку связанной записи',
      (tester) async {
    // Высокий вьюпорт: страница деталей целиком в кадре, секция связей
    // доступна без прокрутки (scrollUntilVisible доводит лишь до кэша
    // ListView, элемент может остаться за нижним краем).
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DoiCatalogApp());
    await tester.pumpAndSettle();

    // Открываем датасет SST с тремя связями.
    await tester.tap(find.textContaining('Global Sea Surface Temperature'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Accelerated warming'), findsNothing);

    // Тап по связи ведёт на экран статьи.
    await tester.tap(find.text('10.1234/ncomms.2024.1987'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Accelerated warming shifts'),
      findsOneWidget,
    );
  });
}
