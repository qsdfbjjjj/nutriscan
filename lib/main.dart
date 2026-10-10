import 'package:flutter/material.dart';

// Точка входа: Flutter начинает выполнение с main().
void main() {
  runApp(const NutriScanApp());
}

// Корневой виджет приложения. StatelessWidget — у него нет изменяемого состояния.
class NutriScanApp extends StatelessWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp подключает Material Design: тему, навигацию, локализацию.
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold — базовый каркас экрана: AppBar сверху, body в центре.
    return Scaffold(
      appBar: AppBar(title: const Text('NutriScan')),
      body: const Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
