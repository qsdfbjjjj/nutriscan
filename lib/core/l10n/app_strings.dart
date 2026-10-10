import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../presentation/settings/settings_provider.dart';
import '../error/failures.dart';

/// Строки интерфейса на двух языках. Язык выбирается в настройках
/// и хранится в SharedPreferences.
class AppStrings {
  const AppStrings(this.languageCode);

  final String languageCode;

  bool get _ru => languageCode == 'ru';
  String _t(String ru, String en) => _ru ? ru : en;

  // Навигация
  String get home => _t('Главная', 'Home');
  String get search => _t('Поиск', 'Search');
  String get favorites => _t('Избранное', 'Favorites');
  String get history => _t('История', 'History');
  String get settings => _t('Настройки', 'Settings');

  // Вход
  String get loginTitle => _t('Добро пожаловать в NutriScan', 'Welcome to NutriScan');
  String get loginSubtitle =>
      _t('Узнайте состав и пищевую ценность продуктов по штрихкоду',
          'Check ingredients and nutrition facts by barcode');
  String get name => _t('Имя', 'Name');
  String get email => 'Email';
  String get signIn => _t('Войти', 'Sign in');
  String get signOut => _t('Выйти', 'Sign out');
  String get nameRequired => _t('Введите имя', 'Enter your name');
  String get emailInvalid => _t('Введите корректный email', 'Enter a valid email');

  // Главная
  String hello(String name) => _t('Привет, $name!', 'Hi, $name!');
  String get barcodeHint => _t('Штрихкод (8–14 цифр)', 'Barcode (8–14 digits)');
  String get barcodeInvalid =>
      _t('Штрихкод — это от 8 до 14 цифр', 'Barcode must be 8–14 digits');
  String get open => _t('Открыть', 'Open');
  String get tryExamples => _t('Попробуйте примеры:', 'Try examples:');
  String get recent => _t('Недавно просмотренные', 'Recently viewed');
  String get noRecent =>
      _t('Вы ещё ничего не смотрели', 'You have not viewed anything yet');
  String get scannedCount => _t('Просмотрено', 'Viewed');
  String get favoritesCount => _t('В избранном', 'Favorites');
  String get scannerSoon =>
      _t('Сканер камерой появится на неделе 11, пока введите штрихкод вручную',
          'Camera scanner is coming in week 11, enter the barcode manually for now');

  // Поиск
  String get searchHint => _t('Название продукта, например «молоко»', 'Product name, e.g. "milk"');
  String get searchStart => _t('Начните вводить название продукта', 'Start typing a product name');
  String get nothingFound => _t('Ничего не найдено', 'Nothing found');
  String get offlineData =>
      _t('Нет сети — показаны сохранённые данные', 'Offline — showing saved data');

  // Продукт
  String get product => _t('Продукт', 'Product');
  String get noName => _t('Без названия', 'Unnamed product');
  String get nutritionPer100 => _t('Пищевая ценность на 100 г', 'Nutrition per 100 g');
  String get kcal => _t('Калорийность', 'Energy');
  String get proteins => _t('Белки', 'Protein');
  String get fat => _t('Жиры', 'Fat');
  String get carbs => _t('Углеводы', 'Carbohydrates');
  String get sugars => _t('Сахара', 'Sugars');
  String get salt => _t('Соль', 'Salt');
  String get noNutrition => _t('Нет данных о пищевой ценности', 'No nutrition data');
  String get allergens => _t('Аллергены', 'Allergens');
  String get noAllergens => _t('Аллергены не указаны', 'No allergens listed');
  String get ingredients => _t('Состав', 'Ingredients');
  String get noIngredients => _t('Состав не указан', 'No ingredients listed');
  String get nutriScore => 'Nutri-Score';
  String get noScore => _t('нет оценки', 'not rated');
  String get addedToFavorites => _t('Добавлено в избранное', 'Added to favorites');
  String get removedFromFavorites => _t('Удалено из избранного', 'Removed from favorites');

  // Избранное и история
  String get noFavorites =>
      _t('Здесь появятся продукты, отмеченные звёздочкой', 'Starred products will appear here');
  String get noHistory => _t('История пуста', 'History is empty');
  String get clearHistory => _t('Очистить историю', 'Clear history');

  // Настройки
  String get theme => _t('Тема', 'Theme');
  String get themeSystem => _t('Системная', 'System');
  String get themeLight => _t('Светлая', 'Light');
  String get themeDark => _t('Тёмная', 'Dark');
  String get language => _t('Язык', 'Language');
  String get account => _t('Аккаунт', 'Account');
  String get stateDemo => _t('Демо: управление состоянием', 'Demo: state management');
  String get stateDemoSubtitle =>
      _t('setState → InheritedWidget → Provider (неделя 3)',
          'setState → InheritedWidget → Provider (week 3)');
  String get about => _t('О приложении', 'About');
  String get aboutText =>
      _t('Данные: Open Food Facts (открытая база продуктов)',
          'Data: Open Food Facts (open food database)');

  // Общие состояния
  String get retry => _t('Повторить', 'Retry');
  String get notFound => _t('Продукт не найден', 'Product not found');
  String get networkError =>
      _t('Нет подключения к интернету', 'No internet connection');
  String get serverError =>
      _t('Сервер не отвечает, попробуйте позже', 'Server error, try again later');

  String failure(Object error) => switch (error) {
        NotFoundFailure() => notFound,
        NetworkFailure() => networkError,
        _ => serverError,
      };
}

/// Короткий доступ к строкам: `context.s.home`.
extension AppStringsX on BuildContext {
  AppStrings get s => watch<SettingsProvider>().strings;
}
