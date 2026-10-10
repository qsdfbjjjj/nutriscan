import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/auth_local_data_source.dart';
import '../../data/datasources/local/product_local_data_source.dart';
import '../../data/datasources/local/settings_local_data_source.dart';
import '../../data/datasources/remote/open_food_facts_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../presentation/auth/auth_cubit.dart';
import '../../presentation/favorites/favorites_cubit.dart';
import '../../presentation/history/history_cubit.dart';
import '../../presentation/product/product_cubit.dart';
import '../../presentation/search/search_bloc.dart';
import '../../presentation/settings/settings_provider.dart';

/// Service locator (get_it) — контейнер зависимостей.
/// Классы получают зависимости через конструктор, а собираются они здесь, в одном месте.
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------- Внешние зависимости ----------
  final prefs = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  final boxes = {
    for (final name in HiveBoxes.all) name: await Hive.openBox<String>(name),
  };

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<Dio>(OpenFoodFactsApi.createDio)

    // ---------- Data: источники данных ----------
    ..registerLazySingleton(() => OpenFoodFactsApi(sl()))
    ..registerLazySingleton(
      () => ProductLocalDataSource(
        products: boxes[HiveBoxes.products]!,
        searches: boxes[HiveBoxes.searches]!,
        favorites: boxes[HiveBoxes.favorites]!,
        history: boxes[HiveBoxes.history]!,
      ),
    )
    ..registerLazySingleton(() => SettingsLocalDataSource(sl()))
    ..registerLazySingleton(() => AuthLocalDataSource(sl()))

    // ---------- Data: репозитории (регистрируем по интерфейсу домена) ----------
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(remote: sl(), local: sl()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))

    // ---------- Presentation ----------
    ..registerLazySingleton(() => SettingsProvider(sl()))
    ..registerLazySingleton(() => AuthCubit(sl()))
    ..registerFactory(() => SearchBloc(sl()))
    ..registerFactory(() => ProductCubit(sl()))
    ..registerFactory(() => FavoritesCubit(sl()))
    ..registerFactory(() => HistoryCubit(sl()));
}
