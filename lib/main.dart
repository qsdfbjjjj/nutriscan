import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injector.dart';

// Точка входа: сначала готовим зависимости (SharedPreferences, Hive, DI),
// потом запускаем приложение.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const NutriScanApp());
}
