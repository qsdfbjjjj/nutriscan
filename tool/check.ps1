# Проверка проекта: обновление кода (если есть update.zip), pub get, analyze, test.
# Лог пишется в tool\check_log.txt.
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$Project = Split-Path $PSScriptRoot -Parent
$Log     = Join-Path $PSScriptRoot 'check_log.txt'
Set-Location $Project

# Переменные окружения из реестра + Flutter в PATH
foreach ($name in 'PUB_CACHE', 'GRADLE_USER_HOME', 'ANDROID_HOME') {
    $value = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($value) { Set-Item "Env:$name" $value }
}
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User') + ';C:\src\flutter\bin'

function Log($text) {
    Write-Host $text -ForegroundColor Cyan
    Add-Content -Path $Log -Value $text -Encoding UTF8
}

function Run($title, [scriptblock]$command) {
    Log "`n=== $title ==="
    $output = & $command 2>&1 | ForEach-Object { "$_" }
    $code = $LASTEXITCODE
    $output | ForEach-Object { Write-Host $_ }
    Add-Content -Path $Log -Value $output -Encoding UTF8
    Log "exit code: $code"
    return $code
}

Set-Content -Path $Log -Value "Проверка $(Get-Date)" -Encoding UTF8

$zip = Join-Path $PSScriptRoot 'update.zip'
if (Test-Path $zip) {
    Log 'Распаковываю обновление кода...'
    Expand-Archive -Path $zip -DestinationPath $Project -Force
    Remove-Item $zip
}

$pub     = Run 'flutter pub get' { flutter pub get }
$analyze = Run 'flutter analyze' { flutter analyze --no-fatal-infos }
$test    = Run 'flutter test' { flutter test }

if ($pub -eq 0 -and $analyze -eq 0 -and $test -eq 0) {
    Write-Host "`nВСЁ ХОРОШО: анализ и тесты прошли." -ForegroundColor Green
    Add-Content -Path $Log -Value 'RESULT: OK' -Encoding UTF8
} else {
    Write-Host "`nЕсть ошибки. Напиши Claude «проверил» — он сам прочитает лог." -ForegroundColor Yellow
    Add-Content -Path $Log -Value 'RESULT: FAIL' -Encoding UTF8
}
