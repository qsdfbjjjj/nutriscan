import 'package:flutter/material.dart';

import 'state_demo_screen.dart';

/// Подход 2: InheritedWidget.
/// Данные кладутся «наверх» дерева, а любой потомок достаёт их через
/// FavoritesScope.of(context) — без передачи через конструкторы.
/// Минус: много шаблонного кода и всё равно нужен StatefulWidget для изменения.
class InheritedFavoritesDemo extends StatefulWidget {
  const InheritedFavoritesDemo({super.key});

  @override
  State<InheritedFavoritesDemo> createState() => _InheritedFavoritesDemoState();
}

class _InheritedFavoritesDemoState extends State<InheritedFavoritesDemo> {
  Set<String> _favorites = {};

  void _toggle(String item) {
    setState(() {
      // Создаём новое множество, чтобы updateShouldNotify увидел изменение.
      _favorites = {..._favorites};
      if (!_favorites.remove(item)) _favorites.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesScope(
      favorites: _favorites,
      toggle: _toggle,
      child: const Column(
        children: [
          _Counter(),
          Expanded(child: _List()),
        ],
      ),
    );
  }
}

class FavoritesScope extends InheritedWidget {
  const FavoritesScope({
    super.key,
    required this.favorites,
    required this.toggle,
    required super.child,
  });

  final Set<String> favorites;
  final void Function(String item) toggle;

  static FavoritesScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope не найден в дереве');
    return scope!;
  }

  /// Потомки перестраиваются, только если данные действительно изменились.
  @override
  bool updateShouldNotify(FavoritesScope oldWidget) => oldWidget.favorites != favorites;
}

class _Counter extends StatelessWidget {
  const _Counter();

  @override
  Widget build(BuildContext context) => DemoCounter(
        count: FavoritesScope.of(context).favorites.length,
        approach: 'InheritedWidget',
      );
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) {
    final scope = FavoritesScope.of(context);
    return ListView(
      children: [
        for (final item in demoProducts)
          DemoTile(
            title: item,
            isFavorite: scope.favorites.contains(item),
            onToggle: () => scope.toggle(item),
          ),
      ],
    );
  }
}
