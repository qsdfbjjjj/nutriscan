// ignore_for_file: avoid_print
// Неделя 1: задачи на Dart.
// Запуск: dart run dart_tasks/tasks.dart

// ---------- 1. Null safety ----------
// String? — переменная может быть null. String — не может.
String greet(String? name) {
  // ?? — «если слева null, взять значение справа»
  return 'Привет, ${name ?? 'гость'}!';
}

// Штрихкод EAN-13 — ровно 13 цифр. Если строка неправильная, вернём null.
String? validateBarcode(String input) {
  final trimmed = input.trim();
  final isValid = trimmed.length == 13 && int.tryParse(trimmed) != null;
  return isValid ? trimmed : null;
}

// ---------- 2. Классы ----------
enum NutriScore { a, b, c, d, e }

class Product {
  final String barcode;
  final String name;
  final double kcalPer100g;
  final double protein;
  final double fat;
  final double carbs;
  final List<String> allergens;
  final NutriScore? score; // оценки может не быть

  // Именованные параметры: required — обязательные
  Product({
    required this.barcode,
    required this.name,
    required this.kcalPer100g,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.allergens = const [],
    this.score,
  });

  // Калорийность для конкретной порции
  double kcalFor(double grams) => kcalPer100g * grams / 100;

  @override
  String toString() =>
      '$name — $kcalPer100g ккал/100г, Nutri-Score: ${score?.name.toUpperCase() ?? 'нет'}';
}

// ---------- 3. Коллекции ----------
// Продукты, в которых есть аллергены пользователя
List<Product> unsafeFor(List<Product> products, Set<String> myAllergens) {
  return products
      .where((p) => p.allergens.any(myAllergens.contains))
      .toList();
}

// Сколько продуктов с каждой оценкой
Map<String, int> countByScore(List<Product> products) {
  final result = <String, int>{};
  for (final p in products) {
    final key = p.score?.name.toUpperCase() ?? 'нет';
    result[key] = (result[key] ?? 0) + 1;
  }
  return result;
}

// Дневник: продукт -> съеденные граммы
double totalKcal(Map<Product, double> diary) {
  return diary.entries.fold(0, (sum, e) => sum + e.key.kcalFor(e.value));
}

// ---------- 4. async / await ----------
// Имитация запроса к API по штрихкоду с задержкой
Future<Product> fetchProduct(String barcode, List<Product> db) async {
  await Future.delayed(const Duration(seconds: 1));
  return db.firstWhere(
    (p) => p.barcode == barcode,
    orElse: () => throw Exception('Продукт $barcode не найден'),
  );
}

Future<void> main() async {
  print('--- Null safety ---');
  print(greet('Даниял'));
  print(greet(null));
  print(validateBarcode('4870001234567')); // 4870001234567
  print(validateBarcode('12ab')); // null

  print('\n--- Классы и коллекции ---');
  final products = [
    Product(
      barcode: '4870001234567', name: 'Молоко 2.5%', kcalPer100g: 52,
      protein: 2.9, fat: 2.5, carbs: 4.7, allergens: ['лактоза'], score: NutriScore.b,
    ),
    Product(
      barcode: '4870007654321', name: 'Шоколад молочный', kcalPer100g: 540,
      protein: 7, fat: 31, carbs: 57, allergens: ['лактоза', 'орехи'], score: NutriScore.e,
    ),
    Product(
      barcode: '4870001112223', name: 'Гречка', kcalPer100g: 343,
      protein: 13, fat: 3.4, carbs: 72, score: NutriScore.a,
    ),
    Product(
      barcode: '4870009998887', name: 'Хлеб пшеничный', kcalPer100g: 265,
      protein: 9, fat: 3.2, carbs: 49, allergens: ['глютен'],
    ),
  ];
  products.forEach(print);
  print('Опасно при аллергии на орехи и глютен: '
      '${unsafeFor(products, {'орехи', 'глютен'}).map((p) => p.name).toList()}');
  print('По оценкам: ${countByScore(products)}');

  final diary = {products[0]: 200.0, products[2]: 80.0, products[1]: 25.0};
  print('Калорий за день: ${totalKcal(diary).toStringAsFixed(0)}');

  print('\n--- async/await ---');
  final found = await fetchProduct('4870001112223', products);
  print('Найден: $found');
  try {
    await fetchProduct('0000000000000', products);
  } catch (e) {
    print('Ошибка: $e');
  }
}
