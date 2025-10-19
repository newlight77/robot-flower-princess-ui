# Robot Flower Princess Frontend

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
