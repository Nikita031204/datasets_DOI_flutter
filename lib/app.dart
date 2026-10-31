import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'common/theme/app_theme.dart';
import 'features/doi/data/doi_repository.dart';
import 'features/doi/presentation/bloc/list/doi_list_cubit.dart';
import 'features/doi/presentation/view/doi_detail_screen.dart';
import 'features/doi/presentation/view/doi_list_screen.dart';

// Роутер один на жизнь приложения: пересоздавать его при каждом build
// нельзя — слетит стек навигации.
final GoRouter _appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => DoiListCubit(context.read<DoiRepository>())..load(),
        child: const DoiListScreen(),
      ),
    ),
    // DOI содержит '/', поэтому в путь он попадает percent-кодом:
    // /doi/10.82152%2Fsst-global-1980-2023
    GoRoute(
      path: '/doi/:doi',
      builder: (context, state) => DoiDetailScreen(
        doi: Uri.decodeComponent(state.pathParameters['doi'] ?? ''),
      ),
    ),
  ],
);

/// Корень приложения: репозиторий, навигация и тема.
class DoiCatalogApp extends StatelessWidget {
  const DoiCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<DoiRepository>(
      create: (_) => DoiRepository(),
      child: MaterialApp.router(
        title: 'Каталог DOI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _appRouter,
      ),
    );
  }
}
