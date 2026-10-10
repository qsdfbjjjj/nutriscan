import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/widgets/product_widgets.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/entities/product.dart';
import '../history/history_cubit.dart';
import 'favorites_cubit.dart';

/// Две вкладки: избранное и история. Обе работают без интернета (Hive).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.favorites),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.star), text: s.favorites),
              Tab(icon: const Icon(Icons.history), text: s.history),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocBuilder<FavoritesCubit, List<Product>>(
              builder: (context, favorites) {
                if (favorites.isEmpty) {
                  return MessageView(icon: Icons.star_outline, message: s.noFavorites);
                }
                return AdaptiveProductList(
                  itemCount: favorites.length,
                  itemBuilder: (context, i) => ProductTile(
                    product: favorites[i],
                    trailing: IconButton(
                      icon: const Icon(Icons.star),
                      color: Colors.amber,
                      onPressed: () =>
                          context.read<FavoritesCubit>().toggle(favorites[i]),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<HistoryCubit, List<Product>>(
              builder: (context, history) {
                if (history.isEmpty) {
                  return MessageView(icon: Icons.history, message: s.noHistory);
                }
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context.read<HistoryCubit>().clear(),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(s.clearHistory),
                      ),
                    ),
                    Expanded(
                      child: AdaptiveProductList(
                        itemCount: history.length,
                        itemBuilder: (context, i) => ProductTile(product: history[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
