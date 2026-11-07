import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../settings/app_settings_cubit.dart';

class ThemeAction extends StatelessWidget {
  const ThemeAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? l10n.useLightTheme : l10n.useDarkTheme,
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => context.read<AppSettingsCubit>().toggleTheme(brightness),
    );
  }
}

class LanguageAction extends StatelessWidget {
  const LanguageAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<Locale>(
      tooltip: l10n.chooseLanguage,
      icon: const Icon(Icons.language),
      initialValue: Localizations.localeOf(context),
      onSelected: context.read<AppSettingsCubit>().setLocale,
      itemBuilder: (_) => [
        PopupMenuItem(value: const Locale('ru'), child: Text(l10n.russian)),
        PopupMenuItem(value: const Locale('en'), child: Text(l10n.english)),
      ],
    );
  }
}
