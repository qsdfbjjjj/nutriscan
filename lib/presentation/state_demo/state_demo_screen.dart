import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import 'favorites_inherited.dart';
import 'favorites_provider.dart';
import 'favorites_set_state.dart';

/// Неделя 3: одна и та же функция «избранное» тремя способами.
/// Сравнение подходов — в README, раздел «Управление состоянием».
class StateDemoScreen extends StatelessWidget {
  const StateDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.s.stateDemo),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '1. setState'),
              Tab(text: '2. InheritedWidget'),
              Tab(text: '3. Provider'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SetStateFavoritesDemo(),
            InheritedFavoritesDemo(),
            ProviderFavoritesDemo(),
          ],
        ),
      ),
    );
  }
}

/// Общие данные для всех трёх демо.
const demoProducts = ['Молоко', 'Гречка', 'Хлеб', 'Шоколад', 'Яблоки', 'Сыр'];

/// Заголовок со счётчиком — «другой виджет», которому тоже нужно состояние.
class DemoCounter extends StatelessWidget {
  const DemoCounter({super.key, required this.count, required this.approach});

  final int count;
  final String approach;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.secondaryContainer,
      child: Text(
        '$approach — в избранном: $count',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Одна строка списка с кнопкой-звездой.
class DemoTile extends StatelessWidget {
  const DemoTile({
    super.key,
    required this.title,
    required this.isFavorite,
    required this.onToggle,
  });

  final String title;
  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: IconButton(
        icon: Icon(isFavorite ? Icons.star : Icons.star_outline),
        color: isFavorite ? Colors.amber : null,
        onPressed: onToggle,
      ),
    );
  }
}
