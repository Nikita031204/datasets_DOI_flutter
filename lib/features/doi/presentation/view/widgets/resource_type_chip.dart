import 'package:flutter/material.dart';

import '../../../../../common/theme/app_colors.dart';
import '../../../../../common/widgets/label_chip.dart';
import '../../../domain/doi_record.dart';

/// Чип крупной категории ресурса: Dataset / JournalArticle / Software…
class ResourceTypeChip extends StatelessWidget {
  const ResourceTypeChip({super.key, required this.record, this.icon = true});

  final DoiRecord record;
  final bool icon;

  @override
  Widget build(BuildContext context) {
    final type = record.resourceTypeGeneral ?? 'Other';
    return LabelChip(
      label: type,
      color: AppColors.resourceType(type),
      icon: icon ? AppColors.resourceTypeIcon(type) : null,
    );
  }
}
