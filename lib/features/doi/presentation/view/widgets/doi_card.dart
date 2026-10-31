import 'package:flutter/material.dart';

import '../../../../../common/theme/app_colors.dart';
import '../../../../../common/widgets/label_chip.dart';
import '../../../domain/doi_record.dart';
import 'resource_type_chip.dart';

/// Карточка записи в каталоге: иконка типа, заголовок, авторы,
/// издатель и год, чипы типа и состояния.
class DoiCard extends StatelessWidget {
  const DoiCard({super.key, required this.record, this.onTap});

  final DoiRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'doi-icon-${record.doi}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.resourceType(record.resourceTypeGeneral)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      AppColors.resourceTypeIcon(record.resourceTypeGeneral),
                      color: AppColors.resourceType(record.resourceTypeGeneral),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.authorsLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: outline),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (record.publisher != null) record.publisher!,
                        if (record.publicationYear != null)
                          '${record.publicationYear}',
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: outline),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ResourceTypeChip(record: record),
                        if (record.state != null)
                          LabelChip(
                            label: record.state!,
                            color: AppColors.stateBadge(record.state),
                          ),
                        if (record.citationCount > 0)
                          LabelChip(
                            label: 'цитирований: ${record.citationCount}',
                            color: theme.colorScheme.primary,
                            icon: Icons.format_quote_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: outline),
            ],
          ),
        ),
      ),
    );
  }
}
