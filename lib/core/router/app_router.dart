import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/auth_cubit.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/favorites/favorites_screen.dart';
import '../../presentation/home/dashboard_screen.dart';
import '../../presentation/home/home_shell.dart';
import '../../presentation/product/product_cubit.dart';
import '../../presentation/product/product_screen.dart';
import '../../presentation/search/search_bloc.dart';
import '../../presentation/search/search_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/state_demo/state_demo_screen.dart';
import '../di/injector.dart';

/// Пути маршрутов в одном месте, чтобы не писать строки по всему коду.
abstract final class Routes {
  static const login = '/login';
  static const home = '/home';
  static const search = '/search';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const stateDemo = '/settings/state-demo';

  static String product(String barcode) => '/product/$barcode';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter:
/// * именованные маршруты и параметр `:barcode`;
/// * вложенная навигация — StatefulShellRoute с нижней панелью (у каждой вкладки свой стек);
/// * redirect — без входа пускаем только на экран логина.
GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: _StreamListenable(authCubit.stream),
    redirect: (context, state) {
      final loggedIn = authCubit.state.isAuthenticated;
      final atLogin = state.matchedLocation == Routes.login;
      if (!loggedIn) return atLogin ? null : Routes.login;
      if (atLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/product/:barcode',
        name: 'product',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final barcode = state.pathParameters['barcode']!;
          return BlocProvider(
            create: (_) => sl<ProductCubit>()..load(barcode),
            child: ProductScreen(barcode: barcode),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                name: 'home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                name: 'search',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<SearchBloc>(),
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.favorites,
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'state-demo',
                    name: 'stateDemo',
                    builder: (context, state) => const StateDemoScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Превращает поток состояний Cubit в Listenable,
/// чтобы GoRouter пересчитывал redirect при входе и выходе.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
