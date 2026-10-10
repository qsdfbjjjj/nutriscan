import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../l10n/app_strings.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Квадратный значок оценки Nutri-Score.
class NutriScoreBadge extends StatelessWidget {
  const NutriScoreBadge({super.key, required this.grade, this.size = 36});

  final String? grade;
  final double size;

  @override
  Widget build(BuildContext context) {
    final g = grade;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: g == null
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : NutriScoreColors.of(g),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Text(
        g?.toUpperCase() ?? '?',
        style: TextStyle(
          color: g == null ? Theme.of(context).colorScheme.outline : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}

/// Фото продукта с кэшированием и заглушкой.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.size = 56});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.fastfood_outlined, color: scheme.outline, size: size * 0.45),
    );
    final imageUrl = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}

/// Строка продукта в списках: фото, название, бренд и калории, Nutri-Score.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.trailing});

  final Product product;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final kcal = product.nutriments.kcal;
    final subtitle = [
      if (product.isMadeInKazakhstan) 'KZ',
      if (product.brand != null) product.brand!,
      if (kcal != null) '${kcal.round()} ${s.languageCode == 'ru' ? 'ккал' : 'kcal'}',
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ProductImage(url: product.imageUrl),
      title: Text(
        product.name.isEmpty ? s.noName : product.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing ?? NutriScoreBadge(grade: product.nutriScore, size: 32),
      onTap: () => context.push(Routes.product(product.barcode)),
    );
  }
}

/// Список продуктов, который подстраивается под ширину экрана:
/// на телефоне — обычный список, на планшете — сетка в несколько колонок.
class AdaptiveProductList extends StatelessWidget {
  const AdaptiveProductList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding = const EdgeInsets.only(bottom: 16),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return ListView.builder(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }
        return GridView.builder(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding.add(const EdgeInsets.all(8)),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            mainAxisExtent: 88,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: itemCount,
          itemBuilder: (context, i) => Card(child: itemBuilder(context, i)),
        );
      },
    );
  }
}
