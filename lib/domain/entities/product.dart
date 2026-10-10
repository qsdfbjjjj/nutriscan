import 'package:equatable/equatable.dart';

/// Продукт — сущность доменного слоя. Не знает ни про JSON, ни про Hive.
class Product extends Equatable {
  const Product({
    required this.barcode,
    required this.name,
    this.brand,
    this.quantity,
    this.imageUrl,
    this.nutriScore,
    this.nutriments = const Nutriments(),
    this.allergens = const [],
    this.ingredients,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? imageUrl;

  /// Оценка Nutri-Score: 'a'…'e' или null, если оценки нет.
  final String? nutriScore;
  final Nutriments nutriments;
  final List<String> allergens;
  final String? ingredients;

  bool get hasAllergens => allergens.isNotEmpty;

  @override
  List<Object?> get props => [
        barcode,
        name,
        brand,
        quantity,
        imageUrl,
        nutriScore,
        nutriments,
        allergens,
        ingredients,
      ];
}

/// Пищевая ценность на 100 г. Любое поле может отсутствовать в базе.
class Nutriments extends Equatable {
  const Nutriments({
    this.kcal,
    this.proteins,
    this.fat,
    this.carbs,
    this.sugars,
    this.salt,
  });

  final double? kcal;
  final double? proteins;
  final double? fat;
  final double? carbs;
  final double? sugars;
  final double? salt;

  bool get isEmpty =>
      [kcal, proteins, fat, carbs, sugars, salt].every((v) => v == null);

  @override
  List<Object?> get props => [kcal, proteins, fat, carbs, sugars, salt];
}
