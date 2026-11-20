import '../../../../l10n/app_localizations.dart';
import '../../domain/doi_record.dart';

extension DoiDisplay on DoiRecord {
  String get authorsLine {
    final names = creators.take(3).map((person) => person.shortName).join(', ');
    return creators.length > 3 ? '$names et al.' : names;
  }
}

extension on DoiPerson {
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

extension DoiDateDisplay on DateTime {
  String get displayDate =>
      '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
}

extension DoiCountDisplay on int {
  String get displayCount {
    if (this < 1000) return toString();
    final thousands = this / 1000;
    final decimals = thousands.truncateToDouble() == thousands ? 0 : 1;
    return '${thousands.toStringAsFixed(decimals)}k';
  }
}

extension RelatedIdentifierDisplay on RelatedIdentifier {
  String relationLabel(AppLocalizations l10n) => switch (relationType) {
    'References' => l10n.relationReferences,
    'IsReferencedBy' => l10n.relationIsReferencedBy,
    'Cites' => l10n.relationCites,
    'IsCitedBy' => l10n.relationIsCitedBy,
    'IsSupplementTo' => l10n.relationIsSupplementTo,
    'IsSupplementedBy' => l10n.relationIsSupplementedBy,
    'IsDerivedFrom' => l10n.relationIsDerivedFrom,
    'IsSourceOf' => l10n.relationIsSourceOf,
    'HasPart' => l10n.relationHasPart,
    'IsPartOf' => l10n.relationIsPartOf,
    'IsVariantFormOf' => l10n.relationIsVariantFormOf,
    'IsIdenticalTo' => l10n.relationIsIdenticalTo,
    'Requires' => l10n.relationRequires,
    'IsRequiredBy' => l10n.relationIsRequiredBy,
    'Compiles' => l10n.relationCompiles,
    'IsCompiledBy' => l10n.relationIsCompiledBy,
    final relation? => relation,
    null => l10n.relationDefault,
  };
}
