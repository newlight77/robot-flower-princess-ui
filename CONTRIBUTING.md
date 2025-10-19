# Contributing to Robot Flower Princess

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
