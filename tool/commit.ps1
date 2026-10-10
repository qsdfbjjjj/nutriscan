# Коммиты по неделям и push на GitHub.
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Set-Location (Split-Path $PSScriptRoot -Parent)

$steps = @(
    @{ m = 'Week 2: screens, Material 3 light/dark theme, shared widgets';
       p = @('lib/core/theme', 'lib/core/widgets', 'lib/presentation/home',
             'lib/presentation/*/*_screen.dart') },
    @{ m = 'Week 3: Provider for settings; setState -> InheritedWidget -> Provider demo';
       p = @('lib/presentation/settings/settings_provider.dart', 'lib/presentation/state_demo',
             'lib/core/l10n') },
    @{ m = 'Week 4: BLoC/Cubit, presentation/domain/data layers, Repository, DI with get_it';
       p = @('lib/domain', 'lib/presentation/*/*_cubit.dart', 'lib/presentation/search/search_bloc.dart',
             'lib/core/di', 'lib/app.dart', 'lib/main.dart', 'pubspec.yaml', 'pubspec.lock') },
    @{ m = 'Week 5: Open Food Facts REST API with dio, JSON parsing, loading/error/empty states';
       p = @('lib/data/models', 'lib/data/datasources/remote', 'lib/core/error') },
    @{ m = 'Week 6: SharedPreferences settings, Hive cache/favorites/history, offline-first';
       p = @('lib/data/datasources/local', 'lib/data/repositories') },
    @{ m = 'Week 7: GoRouter, nested navigation, auth redirect, adaptive layout';
       p = @('lib/core/router') },
    @{ m = 'Tests, README, dev scripts';
       p = @('.') }
)

# Если есть tool\commit_message.txt — один коммит с этим сообщением.
$msgFile = Join-Path $PSScriptRoot 'commit_message.txt'
if (Test-Path $msgFile) {
    $steps = @(@{ m = (Get-Content $msgFile -Raw -Encoding UTF8).Trim(); p = @('.') })
    Remove-Item $msgFile
}

foreach ($step in $steps) {
    git add -- $step.p 2>$null
    git diff --cached --quiet
    if ($LASTEXITCODE -ne 0) {
        git commit -q -m $step.m
        Write-Host "OK: $($step.m)" -ForegroundColor Green
    }
}

git push
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nГотово: всё отправлено на GitHub." -ForegroundColor Green
} else {
    Write-Host "`nPush не прошёл — скинь скрин Claude." -ForegroundColor Yellow
}
git log --oneline -n 10
