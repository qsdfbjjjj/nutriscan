import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../auth/auth_cubit.dart';
import 'settings_provider.dart';

/// Настройки: тема и язык (Provider + SharedPreferences), аккаунт, демо недели 3.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final settings = context.watch<SettingsProvider>();
    final user = context.select((AuthCubit c) => c.state.user);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(s.theme),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(s.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(s.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(s.themeDark),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) =>
                    context.read<SettingsProvider>().setThemeMode(selection.first),
              ),
              const SizedBox(height: 24),
              _Header(s.language),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'ru', label: Text('Русский')),
                  ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {settings.languageCode},
                onSelectionChanged: (selection) =>
                    context.read<SettingsProvider>().setLanguage(selection.first),
              ),
              const SizedBox(height: 24),
              _Header(s.account),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (user?.name.isNotEmpty ?? false)
                              ? user!.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(user?.name ?? ''),
                      subtitle: Text(user?.email ?? ''),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.logout, color: theme.colorScheme.error),
                      title: Text(s.signOut, style: TextStyle(color: theme.colorScheme.error)),
                      onTap: () => context.read<AuthCubit>().signOut(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: Text(s.stateDemo),
                  subtitle: Text(s.stateDemoSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(Routes.stateDemo),
                ),
              ),
              const SizedBox(height: 24),
              _Header(s.about),
              Text('NutriScan 1.0.0\n${s.aboutText}', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
