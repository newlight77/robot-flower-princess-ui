# Testing Strategy

> **🚀 Quick Reference for Daily Testing**
>
> This document provides practical guidance for running tests, writing new tests, and troubleshooting. If you need comprehensive test analysis, E2E overlap recommendations, or strategic insights, see **[Testing Guide (TESTING_GUIDE.md)](TESTING_GUIDE.md)**.

---

**Purpose**: Operational guide for developers
**Focus**: Commands, examples, troubleshooting
**Audience**: Developers working with tests day-to-day
**Related**: [Testing Guide](TESTING_GUIDE.md) - Comprehensive analysis of all 554 tests

---

## Overview

We implement **4 distinct test suites** to ensure comprehensive coverage from unit level to end-to-end scenarios:

1. **Unit Tests** - Individual functions and classes
2. **Use Case Tests** - Business logic and domain rules
3. **Widget Tests** - UI components in isolation
4. **Feature Tests** - End-to-end scenarios with fake backend

## Test Structure

```
test/
├── unit/              # SUITE 1: Pure unit tests
│   ├── core/          # Core utilities (logger, theme, etc.)
│   ├── data/          # Data layer (models, repositories)
│   └── domain/        # Domain entities and value objects
│       ├── entities/
│       └── value_objects/
│
├── use_case/          # SUITE 2: Business logic tests
│   └── domain/
│       └── use_cases/ # Domain use cases
│
├── widget/            # SUITE 3: UI component tests
│   ├── widgets/       # Individual widget tests
│   └── pages/         # Page widget tests
│
└── feature/           # SUITE 4: End-to-end feature tests
    ├── fakes/         # Fake backend implementations
    └── *_feature_test.dart
```

## Test Suites

### 1️⃣ Unit Tests (`test/unit/`)

Tests individual functions and classes in isolation (339 tests).

**What's tested**: Domain entities, value objects, data models, core utilities

**Example**:
```dart
test('should create cell with required fields', () {
  const cell = Cell(position: Position(x: 1, y: 2), type: CellType.flower);
  expect(cell.position.x, 1);
  expect(cell.type, CellType.flower);
});
```

**Commands**:
```bash
make test-unit              # Run unit tests with coverage
flutter test test/unit/     # Run unit tests only
```

> 📖 For detailed analysis, see [Testing Guide - Unit Tests](TESTING_GUIDE.md#unit-tests)

### 2️⃣  Use Case Tests (`test/use_case/`)

Tests business logic and application rules (49 tests).

**What's tested**: Use case implementations, business rules, error handling

**Example**:
```dart
test('should return ValidationFailure when name is empty', () async {
  final result = await createGameUseCase(name: '', rows: 10, cols: 10);
  expect(result.isLeft(), true);
});
```

**Commands**:
```bash
make test-use-case              # Run use case tests with coverage
flutter test test/use_case/     # Run use case tests only
```

> 📖 For detailed analysis, see [Testing Guide - Use Case Tests](TESTING_GUIDE.md#use-case-tests)

### 3️⃣ Widget Tests (`test/ui-component/`)

Tests UI components in isolation (65 tests).

**What's tested**: Individual widgets, user interactions, UI rendering, state changes

**Example**:
```dart
testWidgets('should call onPressed when button is tapped', (tester) async {
  var pressCount = 0;
  await tester.pumpWidget(MaterialApp(
    home: ActionButton(actionType: ActionType.move, onPressed: () => pressCount++),
  ));
  await tester.tap(find.byType(ElevatedButton));
  expect(pressCount, 1);
});
```

**Commands**:
```bash
make test-widget                    # Run widget tests with coverage
flutter test test/ui-component/     # Run widget tests only
```

> 📖 For detailed analysis, see [Testing Guide - UI Component Tests](TESTING_GUIDE.md#ui-component-tests)

### 4️⃣ Feature Tests (`test/feature/`)

Tests complete features from user's perspective (101 tests).

**What's tested**: End-to-end workflows, user scenarios, feature integration

**Uses fake backend**: No real API calls, runs in isolation with `FakeGameDataSource`

**Example**:
```dart
test('Feature: User creates a game and moves robot', () async {
  // Given: User creates a game
  final createResult = await createGameUseCase(name: 'My Game', rows: 10, cols: 10);
  final game = createResult.getOrElse(() => throw Exception());

  // When: User moves robot east
  final moveResult = await executeActionUseCase(
    gameId: game.id, action: ActionType.move, direction: Direction.east);

  // Then: Robot position is updated
  final updatedGame = moveResult.getOrElse(() => throw Exception());
  expect(updatedGame.board.robot.position.x, game.board.robot.position.x + 1);
});
```

**Commands**:
```bash
make test-feature              # Run feature tests with coverage
flutter test test/feature/     # Run feature tests only
```

> 📖 For detailed analysis and E2E overlap, see [Testing Guide - Feature Tests](TESTING_GUIDE.md#feature-tests)

## Running Tests

### Run All Tests
```bash
make test
```

### Run Individual Suites
```bash
make test-unit        # Unit tests only
make test-use-case    # Use case tests only
make test-widget      # Widget tests only
make test-feature     # Feature tests only
```

### Run All Suites with Summary
```bash
make test-all-suites
```

### Generate Coverage Report
```bash
make test-coverage      # Run tests with coverage
make coverage-detail    # Show detailed coverage by file
make coverage-html      # Generate HTML coverage report
```

## Test Coverage Goals

| Layer | Target Coverage | Current Status |
|-------|----------------|----------------|
| Domain Entities | 80%+ | ✅ 89.5% |
| Value Objects | 90%+ | ✅ 100% |
| Use Cases | 100% | ✅ 100% |
| Widgets | 70%+ | ✅ 88.9% |
| Overall | 60%+ | ✅ 52.6% |

## Fake Backend

The feature tests use a `FakeGameDataSource` that simulates backend behavior without making real HTTP calls:

**Features**:
- Simulates network delays
- Maintains in-memory game state
- Supports all game operations
- Provides realistic responses
- No external dependencies

**Location**: `test/feature/fakes/fake_game_datasource.dart`

## Best Practices

### Writing Unit Tests
1. Test one thing at a time
2. Use descriptive test names
3. Follow Arrange-Act-Assert pattern
4. Keep tests independent
5. Avoid test interdependencies

### Writing Use Case Tests
1. Test both success and failure paths
2. Validate business rules
3. Use mocks for dependencies
4. Test edge cases
5. Verify error handling

### Writing Widget Tests
1. Test user interactions
2. Verify widget rendering
3. Test state changes
4. Use `pumpAndSettle()` for animations
5. Test accessibility

### Writing Feature Tests
1. Test realistic user scenarios
2. Use descriptive scenario names
3. Follow Given-When-Then pattern
4. Test complete workflows
5. Verify end-to-end behavior

## CI/CD Integration

The test suites are integrated into the CI/CD pipeline with:
- **Parallel Execution**: All 4 test suites run simultaneously
- **Coverage Merging**: Individual coverage reports merged into single report
- **Quality Gates**: 80% coverage threshold enforced
- **Automated Reporting**: Coverage reports uploaded to Codecov

### GitHub Actions Implementation

The actual CI/CD pipeline runs all test suites in parallel:

```yaml
# Simplified view - see .github/workflows/ci.yml for full implementation
jobs:
  test-unit:
    run: flutter test test/unit/ --coverage

  test-use-case:
    run: flutter test test/use_case/ --coverage

  test-widget:
    run: flutter test test/widget/ --coverage

  test-feature:
    run: flutter test test/feature/ --coverage

  code-coverage:
    needs: [test-unit, test-use-case, test-widget, test-feature]
    run: |
      - Merge coverage reports
      - Generate HTML report
      - Check 80% threshold
      - Upload to Codecov
```

**For detailed CI/CD documentation**, see [CI_CD.md](CI_CD.md)

## Maintenance

### Adding New Tests

1. **For new domain entities**: Add to `test/unit/domain/entities/`
2. **For new use cases**: Add to `test/use_case/domain/use_cases/`
3. **For new widgets**: Add to `test/widget/widgets/`
4. **For new features**: Add to `test/feature/`

### Test Organization

- Group related tests using `group()`
- Use clear, descriptive test names
- Keep tests close to the code they test (by structure)
- Update this document when adding new test categories

## Troubleshooting

### Tests Fail to Load
- Run `flutter pub get`
- Run `flutter pub run build_runner build`
- Clear build cache: `flutter clean`

### Coverage Not Generating
- Install lcov: `brew install lcov` (macOS)
- Ensure tests pass first
- Check coverage/lcov.info file exists

### Widget Tests Fail
- Use `await tester.pumpAndSettle()` for animations
- Wrap widgets in `MaterialApp` for theme support
- Check widget dependencies are provided

## Future Enhancements

- [ ] Add integration tests with real backend (optional)
- [ ] Add performance tests
- [ ] Add accessibility tests
- [ ] Add golden tests for UI consistency
- [ ] Increase overall coverage to 70%+

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)

## Related Documentation

### Comprehensive Testing Analysis
- **[Testing Guide (TESTING_GUIDE.md)](TESTING_GUIDE.md)** - Complete analysis of all 554 tests with E2E overlap recommendations

### Other Testing Resources
- [CI/CD Pipeline](CI_CD.md) - Automated testing in CI/CD
- [Coverage Report](COVERAGE.md) - Detailed coverage workflow and metrics
- [Architecture](ARCHITECTURE.md) - System design and testing strategy

---

**Last Updated**: October 2025
**Test Suite Version**: 1.0
**Total Tests**: 554
**Overall Coverage**: 84.4%
**Target Coverage**: 80%
