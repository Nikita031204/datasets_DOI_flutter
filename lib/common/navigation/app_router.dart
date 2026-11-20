import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/doi/presentation/view/doi_detail_screen.dart';
import '../../features/doi/presentation/view/doi_list_screen.dart';
import '../../l10n/app_localizations.dart';

abstract final class AppRoutes {
  static const catalog = '/';
  // DOI содержит слеш, поэтому параметр включает весь остаток пути.
  static const _doiPath = '/doi/:id(.+)';

  static String detail(String doi) =>
      Uri(pathSegments: ['', 'doi', ...doi.split('/')]).toString();

  static GoRouter createRouter() {
    GoRouter.optionURLReflectsImperativeAPIs = true;
    return GoRouter(
      errorBuilder: (context, _) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.pageNotFound)),
          body: Center(
            child: FilledButton.tonal(
              onPressed: () => context.go(catalog),
              child: Text(l10n.backToCatalog),
            ),
          ),
        );
      },
      routes: [
        GoRoute(path: catalog, builder: (_, _) => const DoiListScreen()),
        GoRoute(
          path: _doiPath,
          builder: (_, state) =>
              DoiDetailScreen(doi: state.pathParameters['id']!),
        ),
      ],
    );
  }
}
