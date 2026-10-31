import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/theme/app_colors.dart';
import '../../../../common/widgets/app_scaffold.dart';
import '../../../../common/widgets/label_chip.dart';
import '../../../../common/widgets/section_card.dart';
import '../../data/doi_repository.dart';
import '../../domain/doi_record.dart';
import '../bloc/detail/doi_detail_cubit.dart';
import '../bloc/detail/doi_detail_state.dart';
import 'widgets/resource_type_chip.dart';

/// Экран деталей записи: метаданные, статистика и связанные записи
/// (relatedIdentifiers) с переходом внутрь каталога.
class DoiDetailScreen extends StatelessWidget {
  const DoiDetailScreen({super.key, required this.doi});

  final String doi;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoiDetailCubit(context.read<DoiRepository>(), doi),
      child: const _DoiDetailView(),
    );
  }
}

class _DoiDetailView extends StatelessWidget {
  const _DoiDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoiDetailCubit, DoiDetailState>(
      builder: (context, state) {
        final cubit = context.read<DoiDetailCubit>();
        return switch (state.status) {
          DoiDetailStatus.loading => const _LoadingView(),
          DoiDetailStatus.notFound => _NotFoundView(
              doi: state.error ?? '',
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go('/'),
            ),
          DoiDetailStatus.error => _ErrorView(
              message: state.error ?? 'Ошибка загрузки',
              onRetry: () => cubit.load(),
            ),
          DoiDetailStatus.loaded => _LoadedView(record: state.record!),
        };
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.record});

  final DoiRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;

    final abstracts = record.descriptions
        .where((d) => d.descriptionType == 'Abstract' || d.descriptionType == null)
        .toList();
    final otherDescriptions = record.descriptions
        .where((d) => d.descriptionType != 'Abstract' && d.descriptionType != null)
        .toList();

    return AppScaffold(
      appBar: AppBar(
        title: Text(record.doi, style: theme.textTheme.titleSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Скопировать DOI',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: record.doi));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('DOI скопирован: ${record.doi}')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // --- Шапка: иконка, заголовок, чипы, базовые метаданные.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'doi-icon-${record.doi}',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.resourceType(
                                record.resourceTypeGeneral,
                              ).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              AppColors.resourceTypeIcon(
                                record.resourceTypeGeneral,
                              ),
                              color: AppColors.resourceType(
                                record.resourceTypeGeneral,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (record.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                record.subtitle!,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: outline),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ResourceTypeChip(record: record),
                      if (record.resourceType != null)
                        LabelChip(
                          label: record.resourceType!,
                          color: theme.colorScheme.primary,
                        ),
                      if (record.state != null)
                        LabelChip(
                          label: 'state: ${record.state}',
                          color: AppColors.stateBadge(record.state),
                        ),
                      if (record.version != null)
                        LabelChip(
                          label: 'v${record.version}',
                          color: AppColors.amber,
                          icon: Icons.history,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetaTable(
                    rows: [
                      ('DOI', record.doi, true),
                      ('Издатель', record.publisher, false),
                      ('Год публикации', record.publicationYear?.toString(), false),
                      ('Авторы', record.creators.isEmpty ? null : record.authorsLine, false),
                      ('Язык', record.language, false),
                      if (record.container?.title != null)
                        (
                          'Публикация',
                          [
                            record.container?.title,
                            if (record.container?.volume != null)
                              'т. ${record.container?.volume}',
                            if (record.container?.issue != null)
                              '№ ${record.container?.issue}',
                          ].join(', '),
                          false,
                        ),
                      if (record.sizes.isNotEmpty)
                        ('Размер', record.sizes.join('; '), false),
                      if (record.formats.isNotEmpty)
                        ('Форматы', record.formats.join(', '), false),
                      ('URL', record.url, true),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Статистика DataCite.
          Row(
            children: [
              _StatTile(label: 'Цитирований', value: record.citationCount),
              const SizedBox(width: 10),
              _StatTile(label: 'Просмотров', value: record.viewCount),
              const SizedBox(width: 10),
              _StatTile(label: 'Скачиваний', value: record.downloadCount),
            ],
          ),

          // --- Аннотация.
          if (abstracts.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Аннотация',
              leading: Icons.subject_outlined,
              children: [
                for (final d in abstracts) ...[
                  Text(d.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ],

          // --- Авторы и контрибьюторы.
          if (record.creators.isNotEmpty || record.contributors.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Люди',
              leading: Icons.groups_outlined,
              children: [
                for (final person in [...record.creators, ...record.contributors])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          person.contributorType == null
                              ? Icons.person_outline
                              : Icons.handshake_outlined,
                          size: 18,
                          color: outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(person.name),
                              if (person.affiliation != null)
                                Text(
                                  person.affiliation!,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: outline),
                                ),
                              if (person.contributorType != null)
                                Text(
                                  person.contributorType!,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: outline),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

          // --- Тематика.
          if (record.subjects.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Тематика',
              leading: Icons.tag_outlined,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in record.subjects)
                      LabelChip(
                        label: s.scheme == null
                            ? s.subject
                            : '${s.subject} (${s.scheme})',
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ],
            ),
          ],

          // --- Прочие описания (например, методы).
          if (otherDescriptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Примечания',
              leading: Icons.notes_outlined,
              children: [
                for (final d in otherDescriptions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (d.descriptionType != null)
                            TextSpan(
                              text: '${d.descriptionType}: ',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          TextSpan(text: d.description),
                        ],
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ],

          // --- Лицензии.
          if (record.rightsList.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Лицензии',
              leading: Icons.gavel_outlined,
              children: [
                for (final r in record.rightsList)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.rights, style: theme.textTheme.bodyMedium),
                        if (r.rightsUri != null)
                          Text(
                            r.rightsUri!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

          // --- Даты жизненного цикла.
          if (record.dates.isNotEmpty || record.created != null) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Даты',
              leading: Icons.event_outlined,
              children: [
                _MetaTable(
                  rows: [
                    for (final d in record.dates)
                      (
                        d.dateType ?? 'Дата',
                        d.date,
                        false,
                      ),
                    if (record.created != null)
                      ('Зарегистрирован', _formatDate(record.created!), false),
                    if (record.updated != null)
                      ('Обновлён', _formatDate(record.updated!), false),
                  ],
                ),
              ],
            ),
          ],

          // --- Связанные записи: переход по relatedIdentifiers.
          const SizedBox(height: 12),
          RelatedIdentifiersSection(record: record),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

/// Таблица «ключ — значение» для метаданных.
class _MetaTable extends StatelessWidget {
  const _MetaTable({required this.rows});

  /// (подпись, значение, моноширинный шрифт)
  final List<(String, String?, bool)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final visible = rows.where((r) => r.$2 != null).toList();

    return Column(
      children: [
        for (final (label, value, mono) in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 118,
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(color: outline),
                  ),
                ),
                Expanded(
                  child: Text(
                    value!,
                    style: mono
                        ? theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.primary,
                          )
                        : theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Плитка статистики: просмотры / цитирования / скачивания.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              _formatCount(value),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return '$n';
  }
}

/// Секция relatedIdentifiers: тап по DOI ведёт на карточку этой записи.
class RelatedIdentifiersSection extends StatelessWidget {
  const RelatedIdentifiersSection({super.key, required this.record});

  final DoiRecord record;

  @override
  Widget build(BuildContext context) {
    if (record.relatedIdentifiers.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Связанные записи (${record.relatedIdentifiers.length})',
      leading: Icons.link_outlined,
      children: [
        for (final related in record.relatedIdentifiers)
          RelatedIdentifierTile(record: record, related: related),
      ],
    );
  }
}

/// Строка связанной записи: тип связи человекочитаемо + идентификатор.
class RelatedIdentifierTile extends StatelessWidget {
  const RelatedIdentifierTile({
    super.key,
    required this.record,
    required this.related,
  });

  final DoiRecord record;
  final RelatedIdentifier related;

  /// Русские подписи для самых частых типов связей DataCite.
  static const Map<String, String> _relationLabels = {
    'References': 'Ссылается на',
    'IsReferencedBy': 'На неё ссылаются',
    'Cites': 'Цитирует',
    'IsCitedBy': 'Цитируется в',
    'IsSupplementTo': 'Дополнение к',
    'IsSupplementedBy': 'Дополнено записью',
    'IsDerivedFrom': 'Получено из',
    'IsSourceOf': 'Источник для',
    'HasPart': 'Содержит часть',
    'IsPartOf': 'Часть записи',
    'IsVariantFormOf': 'Вариант формы',
    'IsIdenticalTo': 'Идентична',
    'Requires': 'Требует',
    'IsRequiredBy': 'Требуется для',
    'Compiles': 'Компилирует',
    'IsCompiledBy': 'Скомпилировано из',
  };

  Future<void> _open(BuildContext context) async {
    // Контекст и зависимости захватываем до await — после асинхронной
    // паузы виджет мог исчезнуть из дерева.
    final router = GoRouter.of(context);
    final repo = context.read<DoiRepository>();
    final messenger = ScaffoldMessenger.of(context);

    final exists = await repo.containsDoi(related.relatedIdentifier);
    if (exists) {
      await router.push(related.routePath);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${related.relatedIdentifier} есть в DataCite, '
            'но пока не в локальном каталоге (моки)',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final relation = related.relationType;
    final label =
        relation != null ? _relationLabels[relation] ?? relation : 'Связана';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: related.isDoi ? () => _open(context) : null,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: related.isDoi
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : outline.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                related.isDoi
                    ? Icons.drive_file_move_outline
                    : Icons.open_in_new,
                size: 18,
                color: related.isDoi
                    ? theme.colorScheme.primary
                    : outline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: related.isDoi
                          ? theme.colorScheme.primary
                          : outline,
                    ),
                  ),
                  Text(
                    related.relatedIdentifier,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: related.isDoi ? null : outline,
                    ),
                  ),
                  if (related.relatedIdentifierType != null &&
                      !related.isDoi)
                    Text(
                      'тип: ${related.relatedIdentifierType} — внешний ресурс',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: outline,
                      ),
                    ),
                ],
              ),
            ),
            if (related.isDoi)
              Icon(Icons.chevron_right, size: 20, color: outline),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.doi, required this.onBack});

  final String doi;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off, size: 48),
            const SizedBox(height: 12),
            Text(
              'Записи нет в каталоге',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              doi,
              style: const TextStyle(fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onBack, child: const Text('К каталогу')),
          ],
        ),
      ),
    );
  }
}
