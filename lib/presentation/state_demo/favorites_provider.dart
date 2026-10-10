import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state_demo_screen.dart';

/// Подход 3: Provider (обёртка над InheritedWidget).
/// Логика вынесена в ChangeNotifier, виджеты подписываются через
/// context.watch / context.select, а действия вызывают через context.read.
class DemoFavoritesNotifier extends ChangeNotifier {
  final Set<String> _favorites = {};

  int get count => _favorites.length;
  bool contains(String item) => _favorites.contains(item);

  void toggle(String item) {
    if (!_favorites.remove(item)) _favorites.add(item);
    notifyListeners();
  }
}

class ProviderFavoritesDemo extends StatelessWidget {
  const ProviderFavoritesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DemoFavoritesNotifier(),
      child: Column(
        children: [
          // select: перестраивается только при изменении count.
          Builder(
            builder: (context) => DemoCounter(
              count: context.select((DemoFavoritesNotifier n) => n.count),
              approach: 'Provider',
            ),
          ),
          Expanded(
            child: Consumer<DemoFavoritesNotifier>(
              builder: (context, notifier, _) => ListView(
                children: [
                  for (final item in demoProducts)
                    DemoTile(
                      title: item,
                      isFavorite: notifier.contains(item),
                      onToggle: () => context.read<DemoFavoritesNotifier>().toggle(item),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
