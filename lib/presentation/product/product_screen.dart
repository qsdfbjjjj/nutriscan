import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/failures.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/product_widgets.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/entities/product.dart';
import '../favorites/favorites_cubit.dart';
import '../history/history_cubit.dart';
import 'product_cubit.dart';

/// Карточка продукта. Маршрут: /product/:barcode
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return BlocListener<ProductCubit, ProductState>(
      // Каждый успешно открытый продукт попадает в историю.
      listenWhen: (prev, curr) => curr is ProductLoaded,
      listener: (context, state) {
        if (state is ProductLoaded) context.read<HistoryCubit>().add(state.product);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.product),
          actions: [
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) => state is ProductLoaded
                  ? _FavoriteButton(product: state.product)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) => switch (state) {
            ProductLoading() => const LoadingView(),
            ProductError(:final error) => MessageView(
                icon: error is NotFoundFailure ? Icons.search_off : Icons.wifi_off,
                message: error is NotFoundFailure
                    ? '${s.notFound}\n$barcode'
                    : s.failure(error),
                actionLabel: error is NotFoundFailure ? null : s.retry,
                onAction: () => context.read<ProductCubit>().retry(),
              ),
            ProductLoaded(:final product, :final fromCache) => Column(
                children: [
                  if (fromCache) OfflineBanner(text: s.offlineData),
                  Expanded(child: _ProductDetails(product: product)),
                ],
              ),
          },
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final isFavorite = context.select(
      (FavoritesCubit c) => c.state.any((p) => p.barcode == product.barcode),
    );
    return IconButton(
      tooltip: s.favorites,
      icon: Icon(isFavorite ? Icons.star : Icons.star_outline),
      color: isFavorite ? Colors.amber : null,
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final added = await context.read<FavoritesCubit>().toggle(product);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(added ? s.addedToFavorites : s.removedFromFavorites),
            duration: const Duration(seconds: 2),
          ));
      },
    );
  }
}

/// Содержимое карточки. На широком экране — фото слева, информация справа.
class _ProductDetails extends StatelessWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final info = _ProductInfo(product: product);
        if (wide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(url: product.imageUrl, size: 280),
                const SizedBox(width: 24),
                Expanded(child: info),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: ProductImage(url: product.imageUrl, size: 220)),
            const SizedBox(height: 16),
            info,
          ],
        );
      },
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final n = product.nutriments;
    final subtitle = [product.brand, product.quantity].whereType<String>().join(' · ');
    final ru = s.languageCode == 'ru';
    final g = ru ? 'г' : 'g';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.isEmpty ? s.noName : product.name,
          style: theme.textTheme.headlineSmall,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ],
        const SizedBox(height: 4),
        Text(product.barcode, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),

        // Nutri-Score
        Row(
          children: [
            NutriScoreBadge(grade: product.nutriScore, size: 44),
            const SizedBox(width: 12),
            Text(
              '${s.nutriScore}: ${product.nutriScore?.toUpperCase() ?? s.noScore}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Пищевая ценность
        _Section(
          title: s.nutritionPer100,
          child: n.isEmpty
              ? Text(s.noNutrition)
              : Column(
                  children: [
                    _NutrientRow(s.kcal, n.kcal, ru ? 'ккал' : 'kcal'),
                    _NutrientRow(s.proteins, n.proteins, g),
                    _NutrientRow(s.fat, n.fat, g),
                    _NutrientRow(s.carbs, n.carbs, g),
                    _NutrientRow(s.sugars, n.sugars, g),
                    _NutrientRow(s.salt, n.salt, g),
                  ],
                ),
        ),

        // Аллергены
        _Section(
          title: s.allergens,
          child: product.hasAllergens
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in product.allergens)
                      Chip(
                        avatar: Icon(Icons.warning_amber, color: theme.colorScheme.error),
                        label: Text(a),
                      ),
                  ],
                )
              : Text(s.noAllergens),
        ),

        // Состав
        _Section(
          title: s.ingredients,
          child: Text(product.ingredients ?? s.noIngredients),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow(this.label, this.value, this.unit);

  final String label;
  final double? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            v == null ? '—' : '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
