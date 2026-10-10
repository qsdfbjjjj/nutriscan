import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriscan/core/widgets/product_widgets.dart';
import 'package:nutriscan/data/datasources/local/settings_local_data_source.dart';
import 'package:nutriscan/domain/entities/app_user.dart';
import 'package:nutriscan/domain/repositories/auth_repository.dart';
import 'package:nutriscan/presentation/auth/auth_cubit.dart';
import 'package:nutriscan/presentation/auth/login_screen.dart';
import 'package:nutriscan/presentation/settings/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late SettingsProvider settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settings = SettingsProvider(SettingsLocalDataSource(prefs));
    authRepository = MockAuthRepository();
    when(() => authRepository.currentUser).thenReturn(null);
  });

  Widget wrap(Widget child) => ChangeNotifierProvider.value(
        value: settings,
        child: BlocProvider(
          create: (_) => AuthCubit(authRepository),
          child: MaterialApp(home: child),
        ),
      );

  testWidgets('Логин: пустая форма показывает ошибки валидации', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.text('Введите имя'), findsOneWidget);
    expect(find.text('Введите корректный email'), findsOneWidget);
    verifyNever(
      () => authRepository.signIn(name: any(named: 'name'), email: any(named: 'email')),
    );
  });

  testWidgets('Логин: корректные данные вызывают signIn', (tester) async {
    when(() => authRepository.signIn(name: 'Даниял', email: 'd@mail.com'))
        .thenAnswer((_) async => const AppUser(name: 'Даниял', email: 'd@mail.com'));

    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.enterText(find.byKey(const Key('login_name')), 'Даниял');
    await tester.enterText(find.byKey(const Key('login_email')), 'd@mail.com');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    verify(() => authRepository.signIn(name: 'Даниял', email: 'd@mail.com')).called(1);
  });

  testWidgets('NutriScoreBadge показывает букву оценки', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NutriScoreBadge(grade: 'b'))),
    );
    expect(find.text('B'), findsOneWidget);
  });
}
