import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/auth_cubit.dart';
import 'presentation/favorites/favorites_cubit.dart';
import 'presentation/history/history_cubit.dart';
import 'presentation/settings/settings_provider.dart';

/// Корневой виджет.
///
/// Provider отвечает за простые настройки (тема, язык),
/// BLoC/Cubit — за основную логику приложения.
class NutriScanApp extends StatefulWidget {
  const NutriScanApp({super.key});

  @override
  State<NutriScanApp> createState() => _NutriScanAppState();
}

class _NutriScanAppState extends State<NutriScanApp> {
  // Роутер создаётся один раз, иначе при каждой перестройке сбрасывалась бы навигация.
  late final AuthCubit _authCubit = sl<AuthCubit>();
  late final GoRouter _router = createRouter(_authCubit);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(
          value: sl<SettingsProvider>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<FavoritesCubit>(
            create: (_) => sl<FavoritesCubit>()..load(),
          ),
          BlocProvider<HistoryCubit>(
            create: (_) => sl<HistoryCubit>()..load(),
          ),
        ],
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) => MaterialApp.router(
            title: 'NutriScan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
