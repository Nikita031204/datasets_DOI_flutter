# doi_catalog — Каталог датасетов и DOI

Flutter-приложение: каталог научных записей (датасеты, статьи, софт, препринты)
по данным [DataCite](https://support.datacite.org/docs/api)
(`GET https://api.datacite.org/dois`). Ответы приходят в формате JSON:API —
обёртка `data` → `attributes`, для неё написан маппер в доменную модель.

Сейчас список работает **на моках**, отформатированных ровно как ответ
реального API, — переключение на сеть делается одной строкой в репозитории.

## Запуск

```bash
flutter pub get
flutter run
# web: flutter run -d chrome
```

## Что внутри

- **Каталог**: список записей, поиск по названию (+ по DOI), pull-to-refresh.
- **Детали**: метаданные записи, статистика цитирований/просмотров, аннотация,
  авторы, тематика, лицензии, даты.
- **Переход по relatedIdentifiers**: на экране деталей тап по связанному DOI
  открывает его карточку внутри каталога; внешние ссылки (URL/arXiv и т.п.)
  и DOI вне моков показывают снекбар/экран «нет в каталоге».

## Структура (feature-first, как в референсе)

```
lib/
  main.dart                      # точка входа
  app.dart                       # MaterialApp.router, go_router, тема
  common/
    theme/app_colors.dart        # палитра + цвета/иконки типов ресурсов
    theme/app_theme.dart         # светлая и тёмная Material 3 темы
    widgets/                     # AppScaffold, SectionCard, LabelChip
  features/doi/
    domain/doi_record.dart       # модель + маппер JSON:API (data/attributes)
    data/mock_dois.dart          # мок-каталог в формате JSON:API
    data/doi_api.dart            # реальный клиент api.datacite.org (http)
    data/doi_repository.dart     # фасад для UI: моки сейчас, API — флагом
    presentation/
      bloc/list|detail/          # cubit'ы и состояния экранов
      view/                      # DoiListScreen, DoiDetailScreen
      view/widgets/              # DoiCard, ResourceTypeChip и др.
```

## Навигация

- `/` — каталог (список + поиск);
- `/doi/<doi>` — детали. DOI содержит `/`, поэтому в путь кодируется
  percent-ом: `/doi/10.82152%2Fsst-global-1980-2023`.

## Как включить реальный API

В `lib/features/doi/data/doi_repository.dart`:

```dart
DoiRepository({bool useApi = false}) → useApi: true
```

`DoiApi` уже умеет `GET /dois?query=...&page[size]=..&page[number]=..`
и `GET /dois/{id}`; парсинг тот же — `DoiRecord.fromJsonApi`.

## Стек

flutter_bloc (cubit) • go_router • http • equatable • Material 3.
