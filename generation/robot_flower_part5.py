#!/usr/bin/env python3
"""
Robot Flower Princess - Part 5: Project Package & Setup Scripts
Master script to run all parts and generate the complete project package
"""

import os
import subprocess
import zipfile
import shutil
from pathlib import Path

def run_part_script(script_name, part_number):
    """Run a part generation script"""
    print(f"\n{'='*60}")
    print(f"Running Part {part_number}...")
    print(f"{'='*60}\n")

    try:
        # Execute the script
        exec(open(script_name).read())
        print(f"✅ Part {part_number} completed successfully!")
        return True
    except Exception as e:
        print(f"❌ Error in Part {part_number}: {str(e)}")
        return False

def generate_additional_files(base_path):
    """Generate additional setup and documentation files"""

    files = {
        'Makefile': '''# Robot Flower Princess - Makefile

.PHONY: help install clean test build run docker-build docker-run

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \\033[36m%-20s\\033[0m %s\\n", $1, $2}'

install: ## Install dependencies
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs

clean: ## Clean build artifacts
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/

test: ## Run tests
	flutter test

test-coverage: ## Run tests with coverage
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report generated at coverage/html/index.html"

format: ## Format code
	dart format lib/ test/

analyze: ## Analyze code
	flutter analyze

build-web: ## Build for web
	flutter build web --release

build-android: ## Build for Android
	flutter build apk --release

build-ios: ## Build for iOS
	flutter build ios --release

run-web: ## Run on web
	flutter run -d chrome

run-mobile: ## Run on mobile device
	flutter run

docker-build: ## Build Docker image
	docker build -t robot-flower-princess:latest .

docker-run: ## Run Docker container
	docker run -p 8080:80 robot-flower-princess:latest

docker-stop: ## Stop Docker container
	docker stop $(docker ps -q --filter ancestor=robot-flower-princess:latest)

setup: ## Complete setup (install + generate code)
	@echo "🚀 Setting up Robot Flower Princess..."
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Setup complete!"

dev: ## Run in development mode
	flutter run -d chrome --hot

ci: ## Run CI checks
	flutter pub get
	flutter analyze
	flutter test --coverage
	flutter build web --release
''',

        'setup.sh': '''#!/bin/bash
# Robot Flower Princess - Setup Script

set -e

echo "🤖 Robot Flower Princess - Setup Script"
echo "========================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"
flutter --version
echo ""

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Generate code
echo "🔨 Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
echo "🧪 Running tests..."
flutter test

echo ""
echo "✅ Setup complete!"
echo ""
echo "Available commands:"
echo "  flutter run -d chrome      # Run on web"
echo "  flutter run                # Run on mobile"
echo "  make help                  # See all make commands"
echo "  docker-compose up          # Run with Docker"
''',

        'setup.bat': '''@echo off
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
''',

        'docker-compose.yml': '''version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped
    environment:
      - API_BASE_URL=${API_BASE_URL:-http://localhost:8000}
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
''',

        '.env.example': '''# API Configuration
API_BASE_URL=http://localhost:8080

# Application Settings
APP_ENV=development
''',

        'CONTRIBUTING.md': '''# Contributing to Robot Flower Princess

Thank you for your interest in contributing! 🎉

## Development Setup

1. Clone the repository
2. Run setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

## Code Style

- Follow Flutter/Dart style guidelines
- Run `dart format` before committing
- Ensure all tests pass

## Architecture

This project follows Hexagonal Architecture:

```
lib/
├── core/           # Cross-cutting concerns
├── domain/         # Business logic (entities, use cases, ports)
├── data/           # Data layer (repositories, datasources)
└── presentation/   # UI layer (pages, widgets, providers)
```

## Testing

- Write unit tests for domain logic
- Write widget tests for UI components
- Maintain test coverage above 80%

```bash
flutter test
flutter test --coverage
```

## Pull Request Process

1. Create a feature branch
2. Make your changes
3. Add tests
4. Ensure all tests pass
5. Submit a PR with a clear description

## Code Review

All submissions require review. We use GitHub pull requests for this purpose.
''',

        'CHANGELOG.md': '''# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-19

### Added
- Initial release
- Game creation with configurable board sizes (3x3 to 50x50)
- Game management with status tracking
- Interactive game controls (rotate, move, pick, drop, give, clean)
- Visual game board with icons and colors
- Auto-play functionality
- Game replay feature with step-by-step animation
- Responsive design for mobile and desktop
- Docker support
- CI/CD with GitHub Actions
- Hexagonal architecture implementation
- Comprehensive test coverage

### Features
- 🎲 Create games with configurable dimensions
- 📋 Manage all created games
- 🎮 Intuitive controls with direction selection
- 🎨 Visual game board with Wild Robot inspired colors
- 🏆 Game status tracking (Playing, Won, Game Over)
- 🤖 Auto-play with AI solver
- 📹 Replay functionality
- 📱 Mobile-first responsive design
- 🐳 Docker deployment ready
- ⚙️ CI/CD pipeline configured
''',

        'LICENSE': '''MIT License

Copyright (c) 2024 Robot Flower Princess

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''',

        'docs/ARCHITECTURE.md': '''# Architecture Documentation

## Overview

Robot Flower Princess follows the **Hexagonal Architecture** (also known as Ports and Adapters pattern) to maintain a clean separation of concerns and testability.

## Layers

### Domain Layer (`lib/domain/`)

The core business logic layer, independent of any frameworks or external dependencies.

**Components:**
- **Entities**: Core business objects (Game, Robot, GameBoard, Cell)
- **Value Objects**: Immutable objects (Position, Direction, CellType, GameStatus)
- **Ports (Inbound)**: Use case interfaces
- **Ports (Outbound)**: Repository interfaces
- **Use Cases**: Business logic implementations

**Dependencies**: None (pure Dart)

### Data Layer (`lib/data/`)

Implements the outbound ports and handles external data sources.

**Components:**
- **Models**: Data transfer objects
- **Repositories**: Implementation of domain repository interfaces
- **DataSources**: API clients and external data handlers

**Dependencies**: Domain layer, HTTP clients, serialization

### Presentation Layer (`lib/presentation/`)

UI components and state management.

**Components:**
- **Pages**: Full screen views
- **Widgets**: Reusable UI components
- **Providers**: State management with Riverpod

**Dependencies**: Domain layer, Data layer

### Core Layer (`lib/core/`)

Shared utilities and cross-cutting concerns.

**Components:**
- **Constants**: Application-wide constants
- **Theme**: UI theme and colors
- **Utils**: Helper functions
- **Error**: Error handling
- **Network**: API client configuration

## Data Flow

```
User Action
    ↓
Presentation (Widget)
    ↓
Provider (State Management)
    ↓
Use Case (Domain)
    ↓
Repository Interface (Domain Port)
    ↓
Repository Implementation (Data)
    ↓
DataSource (Data)
    ↓
External API
```

## Dependency Rule

Dependencies only point inward:
- Presentation → Domain
- Data → Domain
- Domain → Nothing (isolated)

## Benefits

1. **Testability**: Easy to test each layer independently
2. **Maintainability**: Clear separation of concerns
3. **Flexibility**: Easy to swap implementations
4. **Scalability**: Easy to add new features
5. **Independence**: Core logic independent of frameworks

## Testing Strategy

- **Unit Tests**: Domain layer (entities, use cases)
- **Integration Tests**: Repository implementations
- **Widget Tests**: UI components
- **E2E Tests**: Full user flows

## State Management

Using **Riverpod** for:
- Dependency injection
- State management
- Provider composition

## Best Practices

1. Keep domain layer pure (no framework dependencies)
2. Use dependency injection
3. Write tests first (TDD)
4. Follow SOLID principles
5. Use value objects for domain concepts
6. Keep use cases focused and single-purpose
''',

        'docs/API.md': '''# API Integration Documentation

## Backend Requirements

The frontend expects the following REST API endpoints:

### Create Game
```http
POST /api/games
Content-Type: application/json

{
  "name": "string",
  "boardSize": number
}

Response: Game object
```

### Get All Games
```http
GET /api/games

Response: Array of Game objects
```

### Get Game by ID
```http
GET /api/games/{gameId}

Response: Game object
```

### Execute Action
```http
POST /api/games/{gameId}/action
Content-Type: application/json

{
  "action": "rotate|move|pickFlower|dropFlower|giveFlower|clean",
  "direction": "NORTH|EAST|SOUTH|WEST"
}

Response: Updated Game object
```

### Auto Play
```http
POST /api/games/{gameId}/autoplay

Response: Updated Game object
```

### Get Replay
```http
GET /api/games/{gameId}/replay

Response: Array of GameBoard objects (step-by-step states)
```

## Data Models

### Game Object
```json
{
  "id": "string",
  "name": "string",
  "board": GameBoard,
  "status": "playing|won|gameOver",
  "actions": Array<GameAction>,
  "createdAt": "ISO8601 datetime",
  "updatedAt": "ISO8601 datetime"
}
```

### GameBoard Object
```json
{
  "width": number,
  "height": number,
  "cells": Array<Cell>,
  "robot": Robot,
  "princessPosition": Position,
  "totalFlowers": number,
  "flowersDelivered": number
}
```

### Robot Object
```json
{
  "position": Position,
  "orientation": "NORTH|EAST|SOUTH|WEST",
  "flowersHeld": number
}
```

### Position Object
```json
{
  "x": number,
  "y": number
}
```

### Cell Object
```json
{
  "position": Position,
  "type": "empty|robot|princess|flower|obstacle"
}
```

### GameAction Object
```json
{
  "type": "rotate|move|pickFlower|dropFlower|giveFlower|clean",
  "direction": "NORTH|EAST|SOUTH|WEST",
  "timestamp": "ISO8601 datetime",
  "success": boolean,
  "errorMessage": "string?"
}
```

## Error Handling

### Error Response Format
```json
{
  "message": "string",
  "statusCode": number,
  "error": "string"
}
```

### HTTP Status Codes
- `200 OK`: Successful request
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Configuration

Set the API base URL in `.env`:
```
API_BASE_URL=http://localhost:8080
```

Or via environment variable:
```bash
export API_BASE_URL=http://localhost:8080
flutter run
```
''',

        'docs/DEPLOYMENT.md': '''# Deployment Guide

## Docker Deployment

### Build Docker Image
```bash
docker build -t robot-flower-princess:latest .
```

### Run Container
```bash
docker run -p 8080:80 \
  -e API_BASE_URL=http://your-api-url \
  robot-flower-princess:latest
```

### Using Docker Compose
```bash
docker-compose up -d
```

## Web Deployment

### Build for Production
```bash
flutter build web --release
```

The build output will be in `build/web/`

### Deploy to Static Hosting

#### Netlify
1. Connect your repository
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`

#### Vercel
1. Import your repository
2. Framework: Other
3. Build command: `flutter build web --release`
4. Output directory: `build/web`

#### Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

#### GitHub Pages
```bash
flutter build web --release --base-href "/repository-name/"
# Push build/web to gh-pages branch
```

## Mobile Deployment

### Android

#### Build APK
```bash
flutter build apk --release
```

#### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS

#### Build IPA
```bash
flutter build ios --release
```

#### Archive for App Store
```bash
flutter build ipa --release
```

## Environment Variables

Create `.env` file:
```
API_BASE_URL=https://your-production-api.com
APP_ENV=production
```

## CI/CD

GitHub Actions workflow is included in `.github/workflows/ci.yml`

### Triggers
- Push to main/develop branches
- Pull requests

### Steps
1. Run tests
2. Analyze code
3. Build for web
4. Build Docker image (main branch only)

## Monitoring

Consider setting up:
- Error tracking (Sentry, Crashlytics)
- Analytics (Google Analytics, Firebase Analytics)
- Performance monitoring

## Security

1. Use HTTPS for API communication
2. Set appropriate CORS headers on backend
3. Validate all user inputs
4. Keep dependencies updated
''',
    }

    for file_path, content in files.items():
        full_path = os.path.join(base_path, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        # Make shell scripts executable
        if file_path.endswith('.sh'):
            os.chmod(full_path, 0o755)

def create_master_package():
    """Create a complete package with all parts"""
    print("\n" + "="*60)
    print("Creating Master Package")
    print("="*60 + "\n")

    base_path = 'robot-flower-princess-front'
    master_zip = 'robot-flower-princess-complete.zip'

    # Generate additional files
    print("📝 Generating additional setup files...")
    generate_additional_files(base_path)

    # Create comprehensive zip
    print(f"📦 Creating master package: {master_zip}")
    with zipfile.ZipFile(master_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(base_path):
            # Skip build and cache directories
            dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build', '.idea']]
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, os.path.dirname(base_path))
                zipf.write(file_path, arcname)

    print(f"✅ Master package created: {master_zip}")
    return master_zip

def print_project_summary():
    """Print a summary of the generated project"""
    print("\n" + "="*60)
    print("🎉 PROJECT GENERATION COMPLETE!")
    print("="*60)
    print("\n📦 Generated Files:")
    print("   ├── robot-flower-princess-part1.zip  (Project Structure & Core)")
    print("   ├── robot-flower-princess-part2.zip  (Domain Layer)")
    print("   ├── robot-flower-princess-part3.zip  (Data & Presentation)")
    print("   ├── robot-flower-princess-part4.zip  (Game Pages & Main App)")
    print("   └── robot-flower-princess-complete.zip (Full Project)")

    print("\n🚀 Quick Start:")
    print("   1. Extract robot-flower-princess-complete.zip")
    print("   2. cd robot-flower-princess-front")
    print("   3. chmod +x setup.sh && ./setup.sh  (Linux/Mac)")
    print("      OR setup.bat  (Windows)")
    print("   4. flutter run -d chrome")

    print("\n📚 Available Commands:")
    print("   make help          # Show all make commands")
    print("   make install       # Install dependencies")
    print("   make test          # Run tests")
    print("   make run-web       # Run on web")
    print("   make docker-build  # Build Docker image")

    print("\n📁 Project Structure:")
    print("""
   lib/
   ├── core/              # Constants, theme, utils, network
   ├── domain/            # Entities, value objects, ports, use cases
   ├── data/              # Models, repositories, datasources
   └── presentation/      # Pages, widgets, providers
       ├── pages/
       │   ├── home/      # Game list and creation
       │   └── game/      # Game board and controls
       └── widgets/       # Reusable components
    """)

    print("\n🎨 Features:")
    print("   ✅ Hexagonal Architecture")
    print("   ✅ Riverpod State Management")
    print("   ✅ Responsive Design (Mobile & Desktop)")
    print("   ✅ Wild Robot Inspired Theme")
    print("   ✅ Game Creation & Management")
    print("   ✅ Interactive Game Controls")
    print("   ✅ Auto-Play Functionality")
    print("   ✅ Replay Feature")
    print("   ✅ Docker Support")
    print("   ✅ CI/CD with GitHub Actions")
    print("   ✅ Comprehensive Tests")

    print("\n📖 Documentation:")
    print("   - README.md              # Project overview")
    print("   - CONTRIBUTING.md        # Contribution guidelines")
    print("   - docs/ARCHITECTURE.md   # Architecture details")
    print("   - docs/API.md           # API integration")
    print("   - docs/DEPLOYMENT.md    # Deployment guide")

    print("\n🔗 Next Steps:")
    print("   1. Configure API endpoint in .env")
    print("   2. Run the application")
    print("   3. Start developing!")

    print("\n" + "="*60)
    print("Happy Coding! 🤖🌸👑")
    print("="*60 + "\n")

def main():
    """Main execution function"""
    print("""
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║     🤖 ROBOT FLOWER PRINCESS - PROJECT GENERATOR 🌸     ║
║                                                          ║
║  Generating a complete Flutter project with             ║
║  Hexagonal Architecture                                 ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
    """)

    # Note: In actual usage, you would run the individual part scripts
    # For this demonstration, we'll just create the master package

    print("📋 All parts should be generated using their respective scripts:")
    print("   1. Run robot_flower_part1.py")
    print("   2. Run robot_flower_part2.py")
    print("   3. Run robot_flower_part3.py")
    print("   4. Run robot_flower_part4.py")
    print("   5. Run robot_flower_part5.py (this script)")

    print("\n🔨 Generating additional setup files and creating master package...")

    # Create master package
    master_zip = create_master_package()

    # Print summary
    print_project_summary()

    print(f"\n✨ All done! Your complete project is in: {master_zip}")

if __name__ == '__main__':
    main()