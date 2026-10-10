import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/widgets/product_widgets.dart';
import '../../core/widgets/state_views.dart';
import 'search_bloc.dart';

/// Поиск продуктов по названию: debounce, состояния loading/success/empty/error,
/// pull-to-refresh и бесконечная прокрутка.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<SearchBloc>().add(const SearchNextPageRequested());
    }
  }

  Future<void> _refresh() {
    final completer = Completer<void>();
    context.read<SearchBloc>().add(SearchRefreshed(completer));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.search),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            ValueListenableBuilder(
              valueListenable: _queryController,
              builder: (context, value, _) => TextField(
                key: const Key('search_field'),
                controller: _queryController,
                textInputAction: TextInputAction.search,
                onChanged: (q) => context.read<SearchBloc>().add(SearchQueryChanged(q)),
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _queryController.clear();
                            context.read<SearchBloc>().add(const SearchQueryChanged(''));
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (a, b) => a.kazakhstanOnly != b.kazakhstanOnly,
              builder: (context, state) => FilterChip(
                key: const Key('kz_filter'),
                avatar: const Icon(Icons.flag_outlined, size: 18),
                label: Text(s.kzOnly),
                selected: state.kazakhstanOnly,
                showCheckmark: false,
                onSelected: (value) =>
                    context.read<SearchBloc>().add(SearchCountryToggled(value)),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          switch (state.status) {
            case SearchStatus.initial:
              return MessageView(icon: Icons.manage_search, message: s.searchStart);
            case SearchStatus.loading:
              return const LoadingView();
            case SearchStatus.failure:
              return MessageView(
                icon: Icons.wifi_off,
                message: s.failure(state.error ?? ''),
                actionLabel: s.retry,
                onAction: () => context.read<SearchBloc>().add(const SearchRefreshed()),
              );
            case SearchStatus.empty:
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    MessageView(
                      icon: Icons.search_off,
                      message: state.kazakhstanOnly ? s.nothingFoundKz : s.nothingFound,
                    ),
                  ],
                ),
              );
            case SearchStatus.success:
              return Column(
                children: [
                  if (state.fromCache) OfflineBanner(text: s.offlineData),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: AdaptiveProductList(
                        controller: _scrollController,
                        // +1 элемент — индикатор догрузки внизу списка.
                        itemCount: state.products.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= state.products.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return ProductTile(product: state.products[i]);
                        },
                      ),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
