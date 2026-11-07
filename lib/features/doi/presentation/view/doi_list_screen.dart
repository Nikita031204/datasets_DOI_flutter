import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/navigation/app_router.dart';
import '../../../../common/widgets/app_scaffold.dart';
import '../../../../common/widgets/app_settings_actions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/doi_record.dart';
import '../bloc/list/doi_list_cubit.dart';
import '../bloc/list/doi_list_state.dart';
import 'widgets/doi_card.dart';

/// Экран каталога: поиск по названию + список записей на моках.
class DoiListScreen extends StatefulWidget {
  const DoiListScreen({super.key});

  @override
  State<DoiListScreen> createState() => _DoiListScreenState();
}

class _DoiListScreenState extends State<DoiListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<DoiListCubit>().state.query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.catalogTitle),
        actions: [
          const ThemeAction(),
          const LanguageAction(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DoiListCubit>().load(),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: context.read<DoiListCubit>().search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ListenableBuilder(
                  listenable: _searchController,
                  builder: (context, _) {
                    if (_searchController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: l10n.clearSearch,
                      onPressed: () {
                        _searchController.clear();
                        context.read<DoiListCubit>().search('');
                      },
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<DoiListCubit, DoiListState>(
              builder: (context, state) => switch (state) {
                DoiListLoading() => const _LoadingView(),
                DoiListError() => _ErrorView(
                  message: l10n.catalogLoadError,
                  onRetry: context.read<DoiListCubit>().load,
                ),
                DoiListLoaded(
                  :final records,
                  :final totalCount,
                  :final query,
                ) =>
                  _ListView(
                    records: records,
                    totalCount: totalCount,
                    query: query,
                  ),
                DoiListNotFound(:final query) => _EmptyView(query: query),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.records,
    required this.totalCount,
    required this.query,
  });

  final List<DoiRecord> records;
  final int totalCount;
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<DoiListCubit>().load(),
      child: CustomScrollView(
        key: const PageStorageKey<String>('doi-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                query.isEmpty
                    ? l10n.catalogCount(totalCount)
                    : l10n.searchCount(records.length, totalCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = records[index];
                return DoiCard(
                  record: record,
                  onTap: () => context.push(AppRoutes.detail(record.doi)),
                );
              },
            ),
          ),
        ],
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCatalogEmpty = query.trim().isEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 12),
            Text(
              isCatalogEmpty ? l10n.emptyCatalog : l10n.noSearchResults(query),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            if (!isCatalogEmpty)
              Text(
                l10n.tryAnotherQuery,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
