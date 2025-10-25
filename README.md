# Robot Flower Princess

> A strategic puzzle game built with Flutter following hexagonal architecture principles

[![CI/CD](https://github.com/your-org/robot-flower-princess/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/your-org/robot-flower-princess/actions)
[![codecov](https://codecov.io/gh/your-org/robot-flower-princess/branch/main/graph/badge.svg)](https://codecov.io/gh/your-org/robot-flower-princess)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🎮 About

Robot Flower Princess is a strategic puzzle game where you guide a robot to pick flowers and deliver them to the princess while navigating obstacles. Built with **Flutter** using clean architecture principles, comprehensive testing, and modern development practices.

### Key Features
- 🤖 Strategic robot navigation and pathfinding
- 🌸 Flower collection and delivery mechanics
- 👸 Princess interaction system
- 🎯 Auto-play and replay capabilities
- 🎨 Beautiful UI inspired by "The Wild Robot"
- 🧪 80%+ test coverage with comprehensive test suites
- 📱 Cross-platform support (Web, iOS, Android)

## 📖 Documentation

Comprehensive documentation is available in the `docs/` directory:

| Document | Description |
|----------|-------------|
| [**Architecture**](docs/ARCHITECTURE.md) | Hexagonal architecture, layers, and design patterns |
| [**API Integration**](docs/API.md) | REST API endpoints, data models, and integration guide |
| [**Testing Guide**](docs/TESTING_GUIDE.md) 🆕 | **Complete guide to all 554 tests with E2E analysis** |
| [**Testing Strategy**](docs/TESTING_STRATEGY.md) | Test suites, coverage goals, and testing best practices |
| [**CI/CD Pipeline**](docs/CI_CD.md) | GitHub Actions workflow, coverage enforcement, deployment |
| [**Deployment**](docs/DEPLOYMENT.md) | Docker, web, and mobile deployment instructions |
| [**Coverage Report**](docs/COVERAGE.md) | Detailed coverage metrics and workflow implementation |

## 🏗️ Architecture Overview

This project follows **Hexagonal Architecture** (Ports & Adapters pattern):

```
┌─────────────────────────────────────┐
│       Presentation Layer            │
│   (UI, Widgets, State Management)   │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│         Domain Layer                │
│  (Entities, Use Cases, Ports)       │ ← Core Business Logic
│      Framework Independent           │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│          Data Layer                 │
│ (Repositories, DataSources, Models) │
└─────────────────────────────────────┘
```

**Benefits**:
- ✅ Testable and maintainable
- ✅ Framework-independent core
- ✅ Easy to swap implementations
- ✅ Clear separation of concerns

[→ Read full architecture documentation](docs/ARCHITECTURE.md)

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK**: >= 3.35.6
- **Dart SDK**: >= 3.0.0
- **Docker**: (optional, for containerized deployment)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-org/robot-flower-princess.git
cd robot-flower-princess
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
# Web
flutter run -d chrome

# Mobile
flutter run

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

### Running with Docker

```bash
# Build Docker image
docker build -t robot-flower-princess .

# Run container
docker run -p 8080:80 robot-flower-princess

# Or use docker-compose
docker-compose up -d
```

Access the app at: http://localhost:8080

## 🧪 Testing

This project maintains **80%+ test coverage** with 4 comprehensive test suites:

### Run All Tests
```bash
make test                # Run all test suites
make test-coverage       # Run all tests with coverage report
```

### Run Individual Test Suites
```bash
make test-unit          # Unit tests (entities, value objects)
make test-use-case      # Use case tests (business logic)
make test-widget        # Widget tests (UI components)
make test-feature       # Feature tests (end-to-end scenarios)
```

### Coverage Reports
```bash
make coverage-detail    # Detailed coverage by file
make coverage-html      # Generate HTML coverage report
open coverage/html/index.html
```

**Current Coverage**: 52.6% (Target: 80%)

[→ Read full testing strategy](docs/TESTING_STRATEGY.md)

## 🔧 Development

### Project Structure
```
lib/
├── core/              # Cross-cutting concerns
│   ├── constants/     # App constants
│   ├── error/         # Error handling
│   ├── network/       # API client
│   ├── theme/         # UI theme
│   └── utils/         # Utilities
├── domain/            # Business logic (framework-independent)
│   ├── entities/      # Domain entities
│   ├── ports/         # Use case interfaces
│   ├── use_cases/     # Business logic implementations
│   └── value_objects/ # Immutable value objects
├── data/              # External data handling
│   ├── datasources/   # API clients
│   ├── models/        # Data models
│   └── repositories/  # Repository implementations
└── presentation/      # UI layer
    ├── pages/         # Full screen views
    ├── providers/     # State management (Riverpod)
    └── widgets/       # Reusable UI components
```

### Code Style
```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

### Available Make Commands
```bash
make help              # Show all available commands
make run-web           # Run on web
make run-mobile        # Run on mobile
make build-web         # Build for web production
make docker-build      # Build Docker image
make clean             # Clean build artifacts
```

## 🚢 Deployment

### Web Deployment
```bash
flutter build web --release
# Deploy build/web/ to your hosting service
```

**Supported Platforms**:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages
- Custom Docker container

### Mobile Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
flutter build ipa --release
```

[→ Read full deployment guide](docs/DEPLOYMENT.md)

## 🔄 CI/CD Pipeline

Automated CI/CD pipeline using **GitHub Actions**:

✅ **Continuous Integration**:
- Parallel test execution (4 test suites)
- Code coverage reporting (80% threshold)
- Automated linting and analysis
- Pull request status checks

✅ **Continuous Deployment**:
- Automatic web builds
- Docker image builds
- Codecov integration
- Artifact generation

[→ Read full CI/CD documentation](docs/CI_CD.md)

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Web | ✅ Supported | Chrome, Firefox, Safari, Edge |
| iOS | ✅ Supported | iOS 11.0+ |
| Android | ✅ Supported | Android 5.0+ (API 21+) |
| macOS | ✅ Supported | macOS 10.14+ |
| Windows | ✅ Supported | Windows 10+ |
| Linux | 🚧 Experimental | Desktop Linux |

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Quality Standards
- ✅ All tests must pass
- ✅ Code coverage must meet 80% threshold
- ✅ No linter warnings
- ✅ Follow Flutter style guide
- ✅ Add tests for new features

## 📊 Project Status

**Version**: 1.0.0
**Status**: Active Development
**Test Suites**: 4 (Unit, Use Case, Widget, Feature)
**Total Tests**: 157
**Current Coverage**: 52.6%
**Target Coverage**: 80%

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎨 Design Credits

UI color palette and theme inspired by "The Wild Robot" - featuring earthy greens, warm oranges, and natural tones.

## 🔗 Links

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/your-org/robot-flower-princess/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/robot-flower-princess/discussions)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

## 📧 Support

For questions and support:
- 📖 Check the [documentation](docs/)
- 🐛 Report bugs via [GitHub Issues](https://github.com/your-org/robot-flower-princess/issues)
- 💬 Join discussions on [GitHub Discussions](https://github.com/your-org/robot-flower-princess/discussions)

---

**Made with ❤️ using Flutter**
