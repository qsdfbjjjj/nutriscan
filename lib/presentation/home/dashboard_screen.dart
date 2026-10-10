import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/product_widgets.dart';
import '../auth/auth_cubit.dart';
import '../favorites/favorites_cubit.dart';
import '../history/history_cubit.dart';
import 'popular_cubit.dart';

/// Главная: приветствие, ввод штрихкода, статистика и недавние продукты.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();

  /// Реальные штрихкоды казахстанских продуктов из базы Open Food Facts.
  static const _examples = {
    'Шоколад «Казахстан»': '4870036001205',
    'Молоко Lactel': '4870055002689',
    'Кефир FoodMaster': '4870055000852',
    'Вода Tassay': '4870071000195',
    'Масло «Шедевр»': '4870035001152',
    'Томатная паста Цин-Каз': '4870001081270',
  };

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _openBarcode(String barcode) => context.push(Routes.product(barcode));

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _openBarcode(_barcodeController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final userName = context.select((AuthCubit c) => c.state.user?.name ?? '');
    final history = context.watch<HistoryCubit>().state;
    final favoritesCount = context.select((FavoritesCubit c) => c.state.length);

    return Scaffold(
      appBar: AppBar(title: const Text('NutriScan')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.hello(userName), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),

              // Ввод штрихкода
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: const Key('barcode_field'),
                                controller: _barcodeController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: s.barcodeHint,
                                  prefixIcon: const Icon(Icons.qr_code),
                                ),
                                validator: (v) {
                                  final len = v?.trim().length ?? 0;
                                  return len >= 8 && len <= 14 ? null : s.barcodeInvalid;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: FilledButton(
                                onPressed: _submit,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                ),
                                child: Text(s.open),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(s.tryExamples, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in _examples.entries)
                              ActionChip(
                                avatar: const Icon(Icons.qr_code_2, size: 18),
                                label: Text(e.key),
                                onPressed: () => _openBarcode(e.value),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.scannerSoon,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Статистика
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history,
                      value: history.length,
                      label: s.scannedCount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star,
                      value: favoritesCount,
                      label: s.favoritesCount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Популярное в Казахстане
              Text(s.popularKz, style: theme.textTheme.titleMedium),
              Text(
                s.popularKzHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              const _PopularCarousel(),
              const SizedBox(height: 24),

              // Недавние продукты
              Text(s.recent, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    s.noRecent,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final product in history.take(5)) ProductTile(product: product),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Горизонтальная лента популярных казахстанских продуктов.
class _PopularCarousel extends StatelessWidget {
  const _PopularCarousel();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final state = context.watch<PopularCubit>().state;
    const height = 200.0;

    switch (state.status) {
      case PopularStatus.loading:
        return const SizedBox(
          height: height,
          child: Center(child: CircularProgressIndicator()),
        );
      case PopularStatus.failure:
        return SizedBox(
          height: 80,
          child: Center(
            child: TextButton.icon(
              onPressed: () => context.read<PopularCubit>().load(),
              icon: const Icon(Icons.refresh),
              label: Text('${s.popularError}. ${s.retry}'),
            ),
          ),
        );
      case PopularStatus.success:
        return SizedBox(
          height: height,
          // ListView.builder строит только видимые карточки.
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final product = state.products[i];
              return SizedBox(
                width: 140,
                child: Card(
                  child: InkWell(
                    onTap: () => context.push(Routes.product(product.barcode)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ProductImage(url: product.imageUrl, size: 124),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: NutriScoreBadge(grade: product.nutriScore, size: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}
