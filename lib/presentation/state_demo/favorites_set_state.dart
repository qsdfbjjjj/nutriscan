import 'package:flutter/material.dart';

import 'state_demo_screen.dart';

/// Подход 1: setState.
/// Состояние живёт внутри одного StatefulWidget. Дочерним виджетам его
/// приходится передавать через параметры конструктора («prop drilling»).
class SetStateFavoritesDemo extends StatefulWidget {
  const SetStateFavoritesDemo({super.key});

  @override
  State<SetStateFavoritesDemo> createState() => _SetStateFavoritesDemoState();
}

class _SetStateFavoritesDemoState extends State<SetStateFavoritesDemo> {
  final Set<String> _favorites = {};

  void _toggle(String item) {
    // setState перерисовывает ВЕСЬ этот виджет вместе с детьми.
    setState(() {
      if (!_favorites.remove(item)) _favorites.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DemoCounter(count: _favorites.length, approach: 'setState'),
        Expanded(
          child: ListView(
            children: [
              for (final item in demoProducts)
                DemoTile(
                  title: item,
                  isFavorite: _favorites.contains(item),
                  onToggle: () => _toggle(item),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
