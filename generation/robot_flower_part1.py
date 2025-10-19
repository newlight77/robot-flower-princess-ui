#!/usr/bin/env python3
"""
Robot Flower Princess - Part 1: Project Structure & Core
Generates the base project structure, configuration files, and core utilities
"""

import os
import zipfile
from pathlib import Path

def create_directory_structure(base_path):
    """Create the Flutter project directory structure"""
    directories = [
        'lib/core/constants',
        'lib/core/theme',
        'lib/core/utils',
        'lib/core/error',
        'lib/core/network',
        'lib/domain/entities',
        'lib/domain/value_objects',
        'lib/domain/ports/inbound',
        'lib/domain/ports/outbound',
        'lib/domain/use_cases',
        'lib/data/repositories',
        'lib/data/datasources',
        'lib/data/models',
        'lib/presentation/pages/home',
        'lib/presentation/pages/game',
        'lib/presentation/widgets',
        'lib/presentation/providers',
        'test/unit/domain',
        'test/unit/data',
        'test/widget',
        'test/integration',
        '.github/workflows',
    ]

    for directory in directories:
        Path(os.path.join(base_path, directory)).mkdir(parents=True, exist_ok=True)

def generate_files(base_path):
    """Generate all files for Part 1"""

    files = {
        'pubspec.yaml': '''name: robot_flower_princess_front
description: A strategic puzzle game where a robot delivers flowers to a princess
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9

  # HTTP & Network
  http: ^1.1.2
  dio: ^5.4.0

  # Functional Programming
  dartz: ^0.10.1

  # UI
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0

  # Utils
  equatable: ^2.0.5
  json_annotation: ^4.8.1
  uuid: ^4.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  test: ^1.24.9

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
''',

        'analysis_options.yaml': '''include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_print
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_single_quotes
    - use_key_in_widget_constructors
''',

        'README.md': '''# Robot Flower Princess Frontend

A strategic puzzle game built with Flutter following hexagonal architecture principles.

## 🎮 Game Description

Guide a robot to pick flowers and deliver them to the princess while navigating obstacles.

## 🏗️ Architecture

This project follows the Hexagonal Architecture (Ports & Adapters):
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: Repository implementations, data sources
- **Presentation Layer**: UI, state management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Docker (optional)

### Running Locally
```bash
flutter pub get
flutter run -d chrome  # For web
flutter run            # For mobile
```

### Running with Docker
```bash
docker build -t robot-flower-princess .
docker run -p 8080:80 robot-flower-princess
```

### Running Tests
```bash
flutter test
flutter test --coverage
```

## 📱 Supported Platforms
- Web
- iOS
- Android

## 🎨 Design

Color palette inspired by "The Wild Robot" - earthy greens, warm oranges, and natural tones.
''',

        'Dockerfile': '''# Stage 1: Build
FROM cirrusci/flutter:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Stage 2: Serve
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
''',

        'nginx.conf': '''server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
    gzip_comp_level 6;
}
''',

        '.dockerignore': '''**/.git
**/.github
**/.vscode
**/build
**/.dart_tool
**/.idea
**/.flutter-plugins
**/.flutter-plugins-dependencies
**/.packages
**/.pub-cache
**/.pub/
**/coverage
''',

        '.gitignore': '''# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Coverage
coverage/

# Environment
.env
''',

        '.github/workflows/ci.yml': '''name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: 3.35.6'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Analyze code
      run: flutter analyze

    - name: Run tests
      run: flutter test --coverage

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info

  build-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.36.6'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Build web
      run: flutter build web --release

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: web-build
        path: build/web

  docker:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - name: Build Docker image
      run: docker build -t robot-flower-princess:${{ github.sha }} .
''',

        'lib/core/constants/app_constants.dart': '''class AppConstants {
  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const Duration apiTimeout = Duration(seconds: 30);

  // Game Configuration
  static const int minBoardSize = 3;
  static const int maxBoardSize = 50;
  static const int defaultBoardSize = 10;
  static const int maxFlowers = 12;
  static const double maxFlowerPercentage = 0.10;
  static const double obstaclePercentage = 0.30;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration replayStepDuration = Duration(milliseconds: 800);

  // Storage Keys
  static const String gamesListKey = 'games_list';
  static const String currentGameKey = 'current_game';
}
''',

        'lib/core/constants/api_endpoints.dart': '''class ApiEndpoints {
  static const String games = '/api/games';
  static String game(String id) => '/api/games/$id';
  static String gameAction(String id) => '/api/games/$id/action';
  static String autoPlay(String id) => '/api/games/$id/autoplay';
  static String replay(String id) => '/api/games/$id/replay';
}
''',

        'lib/core/theme/app_theme.dart': '''import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.forestGreen,
        secondary: AppColors.warmOrange,
        tertiary: AppColors.skyBlue,
        surface: AppColors.softCream,
        background: AppColors.earthBrown.withOpacity(0.05),
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: AppColors.softCream,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mossGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mossGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.forestGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.mossGreen,
        secondary: AppColors.warmOrange,
        tertiary: AppColors.skyBlue,
        surface: AppColors.earthBrown,
        background: const Color(0xFF1A1A1A),
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    );
  }
}
''',

        'lib/core/theme/app_colors.dart': '''import 'package:flutter/material.dart';

/// Color palette inspired by "The Wild Robot"
/// Earthy, natural tones with warm accents
class AppColors {
  // Primary Colors - Forest & Nature
  static const Color forestGreen = Color(0xFF2D5016);
  static const Color mossGreen = Color(0xFF5A7C47);
  static const Color leafGreen = Color(0xFF7FA950);

  // Secondary Colors - Warmth & Energy
  static const Color warmOrange = Color(0xFFE87D3E);
  static const Color sunsetOrange = Color(0xFFFF9F5A);
  static const Color goldenYellow = Color(0xFFFFB84D);

  // Tertiary Colors - Sky & Water
  static const Color skyBlue = Color(0xFF87BCDE);
  static const Color deepBlue = Color(0xFF4A7BA7);

  // Neutral Colors - Earth & Stone
  static const Color earthBrown = Color(0xFF6B5344);
  static const Color stoneBrown = Color(0xFF8C7A6B);
  static const Color softCream = Color(0xFFF5F1E8);

  // Game Elements
  static const Color robotBlue = Color(0xFF5B9BD5);
  static const Color princessPink = Color(0xFFFF69B4);
  static const Color flowerPink = Color(0xFFFFB6D9);
  static const Color obstacleGray = Color(0xFF707070);
  static const Color emptyCell = Color(0xFFFAF8F3);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
}
''',

        'lib/core/error/failures.dart': '''import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error']) : super(message);
}

class GameOverFailure extends Failure {
  const GameOverFailure([String message = 'Game Over']) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}
''',

        'lib/core/error/exceptions.dart': '''class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network connection failed']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation error']);
}

class GameOverException implements Exception {
  final String message;
  GameOverException([this.message = 'Game Over']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Resource not found']);
}
''',

        'lib/core/utils/logger.dart': '''import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void error(String message, {String tag = 'ERROR', Object? error}) {
    if (kDebugMode) {
      print('[$tag] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    log(message, tag: tag);
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    log(message, tag: tag);
  }

  static void debug(String message, {String tag = 'DEBUG'}) {
    log(message, tag: tag);
  }
}
''',

        'lib/core/network/api_client.dart': '''import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger.info('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.info('Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          Logger.error(
            'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            error: error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
''',

        'test/unit/core/utils/logger_test.dart': '''import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('should log messages without throwing', () {
      expect(() => Logger.log('Test message'), returnsNormally);
      expect(() => Logger.info('Info message'), returnsNormally);
      expect(() => Logger.error('Error message'), returnsNormally);
      expect(() => Logger.warning('Warning message'), returnsNormally);
      expect(() => Logger.debug('Debug message'), returnsNormally);
    });
  });
}
''',
    }

    for file_path, content in files.items():
        full_path = os.path.join(base_path, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)

def main():
    """Main function to generate Part 1"""
    base_path = 'robot-flower-princess-front'

    print("🚀 Generating Part 1: Project Structure & Core...")

    # Create directory structure
    create_directory_structure(base_path)
    print("✅ Directory structure created")

    # Generate files
    generate_files(base_path)
    print("✅ Core files generated")

    # Create zip file
    zip_filename = 'robot-flower-princess-part1.zip'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(base_path):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, os.path.dirname(base_path))
                zipf.write(file_path, arcname)

    print(f"✅ Part 1 packaged as {zip_filename}")
    print("\n📦 Part 1 Complete!")
    print("   - Project structure created")
    print("   - Configuration files added")
    print("   - Core utilities implemented")
    print("   - Theme and colors defined")
    print("   - Docker setup ready")
    print("   - CI/CD workflow configured")

if __name__ == '__main__':
    main()