import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/theme/app_colors.dart';
import '../../../../common/widgets/app_scaffold.dart';
import '../../../../common/widgets/label_chip.dart';
import '../../../../common/widgets/section_card.dart';
import '../../../../common/navigation/app_router.dart';
import '../../../../common/theme/image_sources.dart';
import '../../../../common/widgets/app_settings_actions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/i_doi_repository.dart';
import '../../domain/doi_record.dart';
import '../bloc/detail/doi_detail_cubit.dart';
import '../bloc/detail/doi_detail_state.dart';
import '../utils/doi_display.dart';
import 'widgets/resource_type_chip.dart';

/// Экран деталей записи: метаданные, статистика и связанные записи
/// (relatedIdentifiers) с переходом внутрь каталога.
class DoiDetailScreen extends StatelessWidget {
  const DoiDetailScreen({super.key, required this.doi});

  final String doi;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(doi),
      create: (context) =>
          DoiDetailCubit(context.read<IDoiRepository>(), doi)..load(),
      child: const _DoiDetailView(),
    );
  }
}

class _DoiDetailView extends StatelessWidget {
  const _DoiDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DoiDetailCubit>();
    final canPop = context.canPop();
    void goBack() => canPop ? context.pop() : context.go(AppRoutes.catalog);

    return BlocBuilder<DoiDetailCubit, DoiDetailState>(
      builder: (context, state) => AppScaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: goBack),
          title: Text(cubit.doi, style: Theme.of(context).textTheme.titleSmall),
          actions: [
            if (state case DoiDetailLoaded(:final record))
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: l10n.copyDoi,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: record.doi));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).doiCopied(record.doi),
                      ),
                    ),
                  );
                },
              ),
            const ThemeAction(),
            const LanguageAction(),
          ],
        ),
        body: switch (state) {
          DoiDetailLoading() => const _LoadingView(),
          DoiDetailNotFound() => _NotFoundView(
            doi: cubit.doi,
            onBack: goBack,
            canPop: canPop,
          ),
          DoiDetailError() => _ErrorView(
            message: l10n.detailLoadError,
            onRetry: cubit.load,
          ),
          DoiDetailLoaded(:final record) => _LoadedView(record: record),
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.record});

  final DoiRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final outline = theme.colorScheme.onSurfaceVariant;

    final abstracts = record.descriptions
        .where(
          (d) => d.descriptionType == 'Abstract' || d.descriptionType == null,
        )
        .toList();
    final otherDescriptions = record.descriptions
        .where(
          (d) => d.descriptionType != 'Abstract' && d.descriptionType != null,
        )
        .toList();

    return ListView(
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
                        color: AppColors.transparent,
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
                            ImageSources.doiPlaceholder(
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (record.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              record.subtitle!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: outline,
                              ),
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
                        label: l10n.metadataState(record.state!),
                        color: AppColors.stateBadge(record.state),
                      ),
                    if (record.version != null)
                      LabelChip(
                        label: l10n.versionLabel(record.version!),
                        color: AppColors.amber,
                        icon: Icons.history,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetaTable(
                  rows: [
                    (l10n.doiLabel, record.doi, true),
                    (l10n.publisher, record.publisher, false),
                    (
                      l10n.publicationYear,
                      record.publicationYear?.toString(),
                      false,
                    ),
                    (
                      l10n.authors,
                      record.creators.isEmpty ? null : record.authorsLine,
                      false,
                    ),
                    (l10n.recordLanguage, record.language, false),
                    if (record.container?.title != null)
                      (
                        l10n.publication,
                        [
                          record.container?.title,
                          if (record.container?.volume != null)
                            l10n.volumeLabel(record.container!.volume!),
                          if (record.container?.issue != null)
                            l10n.issueLabel(record.container!.issue!),
                        ].join(', '),
                        false,
                      ),
                    if (record.sizes.isNotEmpty)
                      (l10n.size, record.sizes.join('; '), false),
                    if (record.formats.isNotEmpty)
                      (l10n.formats, record.formats.join(', '), false),
                    (l10n.urlLabel, record.url, true),
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
            _StatTile(label: l10n.citations, value: record.citationCount),
            const SizedBox(width: 10),
            _StatTile(label: l10n.views, value: record.viewCount),
            const SizedBox(width: 10),
            _StatTile(label: l10n.downloads, value: record.downloadCount),
          ],
        ),

        // --- Аннотация.
        if (abstracts.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: l10n.abstractTitle,
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
            title: l10n.people,
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
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: outline,
                                ),
                              ),
                            if (person.contributorType != null)
                              Text(
                                person.contributorType!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: outline,
                                ),
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
            title: l10n.subjects,
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
            title: l10n.notes,
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
            title: l10n.licenses,
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
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
            title: l10n.dates,
            leading: Icons.event_outlined,
            children: [
              _MetaTable(
                rows: [
                  for (final d in record.dates)
                    (d.dateType ?? l10n.dateLabel, d.date, false),
                  if (record.created != null)
                    (l10n.registered, record.created!.displayDate, false),
                  if (record.updated != null)
                    (l10n.updated, record.updated!.displayDate, false),
                ],
              ),
            ],
          ),
        ],

        // --- Связанные записи: переход по relatedIdentifiers.
        const SizedBox(height: 12),
        RelatedIdentifiersSection(record: record),
      ],
    );
  }
}

/// Таблица «ключ — значение» для метаданных.
class _MetaTable extends StatelessWidget {
  const _MetaTable({required this.rows});

  /// (подпись, значение, моноширинный шрифт)
  final List<(String, String?, bool)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.onSurfaceVariant;
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
              value.displayCount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
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
      title: AppLocalizations.of(context)
          .relatedRecords(record.relatedIdentifiers.length),
      leading: Icons.link_outlined,
      children: [
        for (final related in record.relatedIdentifiers)
          RelatedIdentifierTile(related: related),
      ],
    );
  }
}

/// Строка связанной записи: тип связи человекочитаемо + идентификатор.
class RelatedIdentifierTile extends StatelessWidget {
  const RelatedIdentifierTile({super.key, required this.related});

  final RelatedIdentifier related;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.onSurfaceVariant;
    final l10n = AppLocalizations.of(context);
    final label = related.relationLabel(l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: related.isDoi
            ? () => context.push(AppRoutes.detail(related.relatedIdentifier))
            : null,
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
                color: related.isDoi ? theme.colorScheme.primary : outline,
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
                  if (related.relatedIdentifierType != null && !related.isDoi)
                    Text(
                      l10n.externalResource(related.relatedIdentifierType!),
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
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({
    required this.doi,
    required this.onBack,
    required this.canPop,
  });

  final String doi;
  final VoidCallback onBack;
  final bool canPop;

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
              AppLocalizations.of(context).missingRecord,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              doi,
              style: const TextStyle(fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onBack,
              child: Text(
                canPop
                    ? MaterialLocalizations.of(context).backButtonTooltip
                    : AppLocalizations.of(context).backToCatalog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
