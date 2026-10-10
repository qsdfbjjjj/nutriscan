import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan/data/models/product_model.dart';

void main() {
  group('ProductModel.fromApi', () {
    test('разбирает ответ Open Food Facts', () {
      final product = ProductModel.fromApi({
        'code': '3017620422003',
        'product_name': 'Nutella',
        'brands': 'Ferrero',
        'quantity': '400 g',
        'image_front_url': 'https://example.com/n.jpg',
        'nutriscore_grade': 'E',
        'nutriments': {
          'energy-kcal_100g': 539,
          'proteins_100g': '6,3', // число строкой и с запятой
          'fat_100g': 30.9,
        },
        'allergens_tags': ['en:milk', 'en:tree-nuts'],
      });

      expect(product.barcode, '3017620422003');
      expect(product.name, 'Nutella');
      expect(product.brand, 'Ferrero');
      expect(product.nutriScore, 'e');
      expect(product.nutriments.kcal, 539);
      expect(product.nutriments.proteins, 6.3);
      expect(product.nutriments.carbs, isNull);
      expect(product.allergens, ['milk', 'tree nuts']);
    });

    test('неизвестная оценка и пустые поля превращаются в null', () {
      final product = ProductModel.fromApi({
        'code': '123',
        'product_name': '  ',
        'generic_name': 'Вода',
        'nutriscore_grade': 'unknown',
      });

      expect(product.name, 'Вода');
      expect(product.nutriScore, isNull);
      expect(product.nutriments.isEmpty, isTrue);
      expect(product.allergens, isEmpty);
    });
  });

  test('toJson → fromJson возвращает тот же продукт', () {
    final original = ProductModel.fromApi({
      'code': '5449000000996',
      'product_name': 'Coca-Cola',
      'nutriscore_grade': 'e',
      'nutriments': {'energy-kcal_100g': 42, 'sugars_100g': 10.6},
      'allergens_tags': <String>[],
    });

    final restored = ProductModel.fromJson(ProductModel.toJson(original));

    expect(restored, original);
  });
}
