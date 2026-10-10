import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan/main.dart';

void main() {
  testWidgets('Главный экран показывает заголовок и Hello, World!',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NutriScanApp());

    expect(find.text('NutriScan'), findsOneWidget);
    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
