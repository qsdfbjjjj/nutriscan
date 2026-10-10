import '../../domain/entities/product.dart';

/// Сериализация продукта в JSON и обратно.
///
/// Используется ручная сериализация, а не json_serializable: API Open Food Facts
/// неоднородный — числа иногда приходят строками ("12,5"), оценка бывает
/// "unknown", название лежит в разных полях. Удобнее разобрать это явно.
abstract final class ProductModel {
  /// Поля, которые запрашиваем у API (чтобы не тянуть лишнее).
  static const apiFields = 'code,product_name,product_name_ru,product_name_en,'
      'generic_name,brands,quantity,image_front_url,image_url,'
      'nutriscore_grade,nutriments,allergens_tags,ingredients_text,'
      'ingredients_text_ru';

  /// Ответ Open Food Facts → [Product].
  static Product fromApi(Map<String, dynamic> json) {
    final nutriments = json['nutriments'];
    final n = nutriments is Map<String, dynamic> ? nutriments : const <String, dynamic>{};

    return Product(
      barcode: _string(json['code']) ?? '',
      name: _firstNonEmpty([
            json['product_name_ru'],
            json['product_name'],
            json['product_name_en'],
            json['generic_name'],
          ]) ??
          '',
      brand: _firstNonEmpty([json['brands']]),
      quantity: _firstNonEmpty([json['quantity']]),
      imageUrl: _firstNonEmpty([json['image_front_url'], json['image_url']]),
      nutriScore: _grade(json['nutriscore_grade']),
      nutriments: Nutriments(
        kcal: toDouble(n['energy-kcal_100g']),
        proteins: toDouble(n['proteins_100g']),
        fat: toDouble(n['fat_100g']),
        carbs: toDouble(n['carbohydrates_100g']),
        sugars: toDouble(n['sugars_100g']),
        salt: toDouble(n['salt_100g']),
      ),
      allergens: _allergens(json['allergens_tags']),
      ingredients: _firstNonEmpty([
        json['ingredients_text_ru'],
        json['ingredients_text'],
      ]),
    );
  }

  /// [Product] → JSON для локального хранения (Hive).
  static Map<String, dynamic> toJson(Product p) => {
        'barcode': p.barcode,
        'name': p.name,
        'brand': p.brand,
        'quantity': p.quantity,
        'imageUrl': p.imageUrl,
        'nutriScore': p.nutriScore,
        'nutriments': {
          'kcal': p.nutriments.kcal,
          'proteins': p.nutriments.proteins,
          'fat': p.nutriments.fat,
          'carbs': p.nutriments.carbs,
          'sugars': p.nutriments.sugars,
          'salt': p.nutriments.salt,
        },
        'allergens': p.allergens,
        'ingredients': p.ingredients,
      };

  /// JSON из локального хранилища → [Product].
  static Product fromJson(Map<String, dynamic> json) {
    final n = (json['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Product(
      barcode: json['barcode'] as String,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      quantity: json['quantity'] as String?,
      imageUrl: json['imageUrl'] as String?,
      nutriScore: json['nutriScore'] as String?,
      nutriments: Nutriments(
        kcal: toDouble(n['kcal']),
        proteins: toDouble(n['proteins']),
        fat: toDouble(n['fat']),
        carbs: toDouble(n['carbs']),
        sugars: toDouble(n['sugars']),
        salt: toDouble(n['salt']),
      ),
      allergens: (json['allergens'] as List?)?.cast<String>() ?? const [],
      ingredients: json['ingredients'] as String?,
    );
  }

  /// Число может прийти как int, double или строка (в том числе с запятой).
  static double? toDouble(Object? value) => switch (value) {
        num v => v.toDouble(),
        String v => double.tryParse(v.replaceAll(',', '.').trim()),
        _ => null,
      };

  static String? _string(Object? value) => switch (value) {
        String v => v,
        num v => v.toString(),
        _ => null,
      };

  static String? _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final s = _string(value)?.trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  static String? _grade(Object? value) {
    final g = _string(value)?.toLowerCase();
    return const {'a', 'b', 'c', 'd', 'e'}.contains(g) ? g : null;
  }

  /// "en:milk" → "milk", "en:tree-nuts" → "tree nuts".
  static List<String> _allergens(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((tag) => tag.contains(':') ? tag.split(':').last : tag)
        .map((tag) => tag.replaceAll('-', ' '))
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
