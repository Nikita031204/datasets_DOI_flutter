import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'common/navigation/app_router.dart';
import 'common/settings/app_settings_cubit.dart';
import 'common/theme/app_theme.dart';
import 'features/doi/data/doi_repository.dart';
import 'features/doi/domain/i_doi_repository.dart';
import 'features/doi/presentation/bloc/list/doi_list_cubit.dart';
import 'l10n/app_localizations.dart';

class DoiCatalogApp extends StatefulWidget {
  const DoiCatalogApp({super.key});

  @override
  State<DoiCatalogApp> createState() => _DoiCatalogAppState();
}

class _DoiCatalogAppState extends State<DoiCatalogApp> {
  final _router = AppRoutes.createRouter();
  final _lightTheme = AppTheme.light();
  final _darkTheme = AppTheme.dark();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IDoiRepository>(
      create: (_) => DoiRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AppSettingsCubit()),
          BlocProvider(
            create: (context) =>
                DoiListCubit(context.read<IDoiRepository>())..load(),
          ),
        ],
        child: BlocBuilder<AppSettingsCubit, AppSettings>(
          builder: (context, settings) => MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context).catalogTitle,
            debugShowCheckedModeBanner: false,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
