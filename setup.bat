@echo off
REM Robot Flower Princess - Setup Script for Windows

echo 🤖 Robot Flower Princess - Setup Script
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo ✅ Flutter is installed
flutter --version
echo.

REM Get dependencies
echo 📦 Installing dependencies...
flutter pub get

REM Generate code
echo 🔨 Generating code...
flutter pub run build_runner build --delete-conflicting-outputs

REM Run tests
echo 🧪 Running tests...
flutter test

echo.
echo ✅ Setup complete!
echo.
echo Available commands:
echo   flutter run -d chrome      # Run on web
echo   flutter run                # Run on mobile
