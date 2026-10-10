@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "PATH=%PATH%;C:\src\flutter\bin"
set "PUB_CACHE=C:\src\pub_cache"
flutter run -d chrome
pause
