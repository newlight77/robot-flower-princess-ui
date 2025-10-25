# Testing Guide

**Version:** 1.0
**Last Updated:** October 2025
**Test Coverage:** 84.4% (769/911 lines)
**Total Tests:** 554

---

## Table of Contents

1. [Overview](#overview)
2. [Test Pyramid Structure](#test-pyramid-structure)
3. [Test Levels](#test-levels)
   - [Unit Tests](#unit-tests)
   - [Use Case Tests](#use-case-tests)
   - [UI Component Tests](#ui-component-tests)
   - [Feature Tests](#feature-tests)
4. [Test Categories by Layer](#test-categories-by-layer)
5. [E2E Testing Considerations](#e2e-testing-considerations)
6. [Running Tests](#running-tests)
7. [Related Documentation](#related-documentation)

---

## Overview

This project follows a comprehensive testing strategy based on **Hexagonal Architecture** principles, with tests organized in four distinct levels that mirror the testing pyramid. Each level serves specific purposes and provides unique benefits to development velocity, system design, and quality assurance.

### Testing Philosophy

- **Inside-Out Testing**: Start with domain logic, move outward to infrastructure
- **Test Isolation**: Each test level is independent and fast
- **Comprehensive Coverage**: 84.4% code coverage across all layers
- **Living Documentation**: Tests serve as executable specifications

---

## Test Pyramid Structure

```
                    ╱╲
                   ╱  ╲
                  ╱ E2E╲           [Not in this suite]
                 ╱──────╲          Outside-in, full system
                ╱        ╲
               ╱ Feature  ╲        101 tests - 18%
              ╱────────────╲       User workflows, fakes
             ╱              ╲
            ╱  UI Component ╲      65 tests - 12%
           ╱────────────────╲     Widget integration
          ╱                  ╲
         ╱    Use Case       ╲    49 tests - 9%
        ╱──────────────────── ╲   Business rules
       ╱                      ╲
      ╱        Unit           ╲   339 tests - 61%
     ╱──────────────────────── ╲  Entities, logic, utils
    ────────────────────────────
```

**Total: 554 tests** across 4 levels, following the pyramid principle where:
- **61%** are fast, focused unit tests
- **9%** are use case/business logic tests
- **12%** are UI component integration tests
- **18%** are feature/integration tests

---

## Test Levels

### Unit Tests

**Location:** `test/unit/`
**Count:** 339 tests
**Coverage:** ~95% of domain and core layers

#### Intention
**Technical** - Validates individual components in isolation

#### Purpose
Test the smallest units of code (functions, classes, methods) to ensure they work correctly in isolation. Focus on:
- **Domain Entities**: `Robot`, `Princess`, `Cell`, `GameBoard`, `Game`, `GameAction`
- **Value Objects**: `Position`, `Direction`, `ActionType`, `GameStatus`, `CellType`
- **Core Utilities**: Constants, errors, theme, network client
- **Data Models**: JSON serialization/deserialization
- **Repository**: Data transformation and error handling

#### How It's Tested

**1. Domain Entities (71 tests)**
```dart
// Example: Robot entity tests
test('should calculate flowers held correctly', () {
  const robot = Robot(
    collectedFlowers: [Position(x: 1, y: 1), Position(x: 2, y: 2)],
    deliveredFlowers: [Position(x: 1, y: 1)],
  );
  expect(robot.flowersHeld, 1); // 2 collected - 1 delivered
});
```

**Approach:**
- Pure function testing with no dependencies
- Const constructors for immutability validation
- Edge cases (empty, null, boundaries)
- Equality and hash code testing (Equatable)
- JSON serialization round-trips

**2. Value Objects (41 tests)**
```dart
// Example: Direction value object
test('should rotate direction correctly', () {
  expect(Direction.north.rotateClockwise(), Direction.east);
  expect(Direction.east.rotateClockwise(), Direction.south);
});
```

**Approach:**
- Enum behavior testing
- Transformation methods (rotate, opposite, etc.)
- String conversion (toJson/fromJson)
- Exhaustive enum case coverage

**3. Core Layer (77 tests)**
```dart
// Example: Exception handling
test('should create ServerException with message', () {
  const exception = ServerException('Server error');
  expect(exception.message, 'Server error');
  expect(exception, isA<Exception>());
});
```

**Approach:**
- Configuration validation (constants)
- Error type testing (exceptions/failures)
- Theme color validation
- API endpoint construction

**4. Data Layer (150 tests)**
```dart
// Example: GameModel serialization
test('should parse GameModel from JSON', () {
  final json = {
    'id': 'game-123',
    'board': {...},
    'status': 'in_progress',
  };
  final model = GameModel.fromJson(json);
  expect(model.id, 'game-123');
});
```

**Approach:**
- Mocked dependencies (Mockito)
- JSON parsing edge cases
- Error mapping (Exception → Failure)
- Repository delegation testing

#### Benefits

✅ **Design Aid**
- Enforces SOLID principles
- Reveals coupling issues early
- Encourages immutability and pure functions
- Validates entity invariants

✅ **Development Velocity**
- **Fastest execution**: ~1-2 seconds for 339 tests
- Immediate feedback during development
- TDD-friendly for domain logic
- No infrastructure setup needed

✅ **Regression Prevention**
- Catches breaking changes in entities immediately
- Validates JSON contract changes
- Ensures value object behavior consistency
- Protects domain invariants

✅ **Documentation**
- Demonstrates entity usage patterns
- Shows valid state combinations
- Illustrates value object transformations
- Documents JSON structure expectations

#### E2E Overlap Consideration

**LOW OVERLAP** - These tests should **NOT** be duplicated in E2E:

- Domain entity logic is internal implementation
- Value object behavior is not exposed to users
- JSON parsing is an implementation detail
- Most unit tests verify internal contracts

**Exception:** Core business rules (e.g., "robot can only hold X flowers") should be validated in E2E to ensure the rule is enforced through the entire system.

---

### Use Case Tests

**Location:** `test/use_case/domain/use_cases/`
**Count:** 49 tests
**Coverage:** 100% of use cases

#### Intention
**Functional** - Validates business logic and application rules

#### Purpose
Test the application's use cases (business operations) to ensure they correctly orchestrate domain entities and enforce business rules. Tests cover:
- **Create Game**: Board generation, initial state
- **Execute Action**: Move, rotate, pick/drop flowers, clean obstacles
- **Auto Play**: Automated game completion
- **Get Games**: List retrieval with filtering
- **Get Game**: Single game retrieval
- **Replay Game**: Game history reconstruction

#### How It's Tested

**Approach:**
```dart
// Example: ExecuteActionImpl use case test
test('should move robot north successfully', () async {
  // Given: A game with robot at (5, 5)
  final game = Game(
    board: GameBoard(robot: Robot(position: Position(x: 5, y: 5))),
  );
  when(mockRepository.getGame(any)).thenAnswer((_) async => Right(game));
  when(mockRepository.executeAction(any, any, any))
      .thenAnswer((_) async => Right(updatedGame));

  // When: User moves north
  final result = await executeActionUseCase(
    'game-123',
    ActionType.move,
    Direction.north,
  );

  // Then: Robot moves to (5, 4)
  expect(result.isRight(), true);
  final updated = result.getOrElse(() => throw Exception());
  expect(updated.board.robot.position, Position(x: 5, y: 4));
});
```

**Key Testing Patterns:**
- **Mocked Repository**: Uses `mockito` to isolate use case logic
- **Either Monad**: Tests both success (`Right`) and failure (`Left`) paths
- **Business Rules**: Validates game rules are enforced
- **State Transitions**: Verifies correct state changes
- **Error Handling**: Tests all failure scenarios

**Test Structure:**
1. **Setup**: Mock dependencies, prepare test data
2. **Given**: Initial game state
3. **When**: Execute use case
4. **Then**: Verify state changes and side effects

#### Benefits

✅ **Design Aid**
- Defines clear use case boundaries
- Validates business rule placement
- Ensures proper error handling patterns
- Guides repository interface design

✅ **Development Velocity**
- **Fast execution**: ~2-3 seconds for 49 tests
- Tests business logic without UI
- Mocks eliminate database/network delays
- Easy to add new use case variations

✅ **Regression Prevention**
- Protects core business rules
- Catches logic errors in orchestration
- Validates error handling paths
- Ensures consistent state transitions

✅ **Documentation**
- **Living specification** of business operations
- Shows valid operation sequences
- Documents error scenarios
- Illustrates expected state changes

#### E2E Overlap Consideration

**MEDIUM OVERLAP** - Some tests overlap with E2E, but serve different purposes:

**Should be in E2E:**
- High-level workflows (create game → play → win)
- User-visible business rules
- Critical happy paths

**Should stay in Use Case tests:**
- Edge cases (boundary conditions)
- Error handling scenarios
- State transition details
- Internal business logic

**Verdict:** Keep both. Use case tests are faster and more focused, while E2E validates the rules work end-to-end through real infrastructure.

---

### UI Component Tests

**Location:** `test/ui-component/`
**Count:** 65 tests
**Coverage:** ~87% of presentation widgets

#### Intention
**Technical with Functional aspects** - Validates UI components and user interactions

#### Purpose
Test Flutter widgets in isolation to ensure they:
- Render correctly with various props/state
- Handle user interactions (taps, gestures)
- Display data properly
- Show/hide elements based on state
- Handle edge cases (empty, loading, error states)

**Tested Components:**
- **GameBoardWidget**: Grid rendering, cell visualization
- **ActionControls**: Direction selector, action buttons
- **GameInfoPanel**: Score, status, robot state display
- **GameListItem**: Game preview in list
- **DirectionSelector**: Direction button group
- **ActionButton**: Individual action buttons
- **CellWidget**: Single board cell rendering

#### How It's Tested

**Approach:**
```dart
// Example: GameBoardWidget test
testWidgets('should display robot emoji at correct position',
  (WidgetTester tester) async {
    // Given: A board with robot at (0, 0)
    const board = GameBoard(
      width: 5,
      height: 5,
      robot: Robot(position: Position(x: 0, y: 0)),
    );

    // When: Widget is rendered
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameBoardWidget(board: board),
        ),
      ),
    );

    // Then: Robot emoji is displayed
    expect(find.text('🤖'), findsOneWidget);
  },
);
```

**Testing Techniques:**
- **`testWidgets`**: Flutter's widget testing framework
- **`WidgetTester`**: Simulates user interactions
- **`pumpWidget`**: Renders widgets
- **Finders**: Locate widgets by type, text, key
- **Matchers**: Verify widget properties
- **Gesture Simulation**: `tester.tap()`, `tester.drag()`

**Test Categories:**
1. **Rendering Tests**: Verify correct UI output
2. **Interaction Tests**: Simulate taps, validate callbacks
3. **State Tests**: Check visibility based on state
4. **Edge Case Tests**: Empty, loading, error states

#### Benefits

✅ **Design Aid**
- Validates component API design
- Ensures proper state management
- Reveals tight coupling in widgets
- Guides widget composition

✅ **Development Velocity**
- **Medium-fast execution**: ~3-5 seconds for 65 tests
- Tests UI without launching app
- Faster than manual UI testing
- Quick feedback on UI changes

✅ **Regression Prevention**
- Catches UI breaking changes
- Validates interaction handlers
- Ensures accessibility
- Protects against layout regressions

✅ **Documentation**
- Shows component usage examples
- Documents expected props
- Illustrates interaction patterns
- Demonstrates state handling

#### E2E Overlap Consideration

**MEDIUM-HIGH OVERLAP** - Significant overlap with E2E UI testing:

**Should be in E2E:**
- Critical user workflows (create game flow)
- Cross-component interactions
- Navigation flows
- Real data integration

**Should stay in Widget tests:**
- Component edge cases (empty states, errors)
- Interaction details (button disabled states)
- Layout variations
- Isolated component behavior

**Verdict:** Keep both, but focus E2E on workflows. Widget tests provide fast feedback on component behavior, while E2E validates the full user experience.

---

### Feature Tests

**Location:** `test/feature/`
**Count:** 101 tests
**Coverage:** Integration of all layers

#### Intention
**Functional** - Validates complete user workflows and scenarios

#### Purpose
Test complete features from a user's perspective using a fake backend. These tests validate:
- **User Workflows**: Complete sequences of actions
- **Integration**: All layers working together
- **Business Scenarios**: Complex game situations
- **State Management**: Application state across operations
- **Error Scenarios**: How the system handles failures

**Test Suites:**
1. **`game_flow_feature_test.dart`** (8 tests): Core game workflows
2. **`auto_play_feature_test.dart`** (10 tests): Auto-play scenarios
3. **`replay_feature_test.dart`** (8 tests): Game replay workflows
4. **`game_scenarios_feature_test.dart`** (31 tests): Complex game scenarios
5. **`game_state_feature_test.dart`** (18 tests): State management
6. **`error_handling_feature_test.dart`** (8 tests): Error scenarios
7. **`workflow_integration_feature_test.dart`** (18 tests): Complex workflows

#### How It's Tested

**Approach:**
```dart
// Example: Complete game workflow
test('Feature: User creates game, plays, and wins', () async {
  // Given: User creates a game
  final createResult = await createGameUseCase('Victory Game', 10);
  var game = createResult.getOrElse(() => throw Exception('Failed'));

  expect(game.status, GameStatus.playing);
  expect(game.board.flowersRemaining, greaterThan(0));

  // When: User plays until completion
  final autoPlayResult = await autoPlayUseCase(game.id);
  game = autoPlayResult.getOrElse(() => throw Exception('Failed'));

  // Then: Game is won
  expect(game.status, GameStatus.won);
  expect(game.board.robot.position, game.board.princess.position);
  expect(game.board.flowersRemaining, 0);

  // And: User can view the completed game
  final getResult = await getGameUseCase(game.id);
  expect(getResult.isRight(), true);
});
```

**Testing Architecture:**
- **Fake Backend**: `FakeGameDataSource` simulates API without network
- **Real Use Cases**: Actual use case implementations
- **Real Repository**: Actual repository with fake datasource
- **State Management**: Real state providers (Riverpod)
- **No Mocks**: Tests use real implementations

**Key Characteristics:**
1. **User-Centric**: Tests written from user perspective
2. **Workflow-Based**: Complete sequences, not isolated operations
3. **State Verification**: Checks system state at each step
4. **Integration**: All layers working together
5. **Fast**: No network, fast fake backend

#### Benefits

✅ **Design Aid**
- Validates end-to-end architecture
- Reveals integration issues
- Tests system boundaries
- Validates API contracts
- Guides feature design from user perspective

✅ **Development Velocity**
- **Medium execution**: ~25-30 seconds for 101 tests
- Faster than E2E (no app launch, no real API)
- Validates full stack without infrastructure
- Quick feedback on feature completeness
- Enables rapid iteration on workflows

✅ **Regression Prevention**
- Catches integration bugs
- Validates feature completeness
- Ensures workflow consistency
- Protects critical user journeys
- Validates error handling paths

✅ **Documentation**
- **Best living documentation** for features
- Shows complete user workflows
- Documents expected behavior
- Illustrates error scenarios
- Serves as acceptance criteria

#### E2E Overlap Consideration

**HIGH OVERLAP** - Significant overlap with E2E, but different trade-offs:

**Feature Tests vs E2E:**

| Aspect | Feature Tests (Fake) | E2E Tests (Real) |
|--------|---------------------|------------------|
| **Speed** | Fast (~30s for 101) | Slow (minutes) |
| **Reliability** | Very stable | Flaky (network, timing) |
| **Setup** | None | Complex (API, DB, deploy) |
| **Scope** | Logic + Integration | Full system + UI + API |
| **Debugging** | Easy | Difficult |
| **CI/CD** | Every commit | Pre-release only |

**Should be in E2E:**
- Critical happy paths (smoke tests)
- User-visible workflows through real UI
- Real API integration
- Cross-system integration (auth, payment, etc.)
- Production-like environment validation

**Should stay in Feature tests:**
- Edge cases and error scenarios
- Complex state transitions
- Boundary conditions
- Rapid development feedback
- Most regression coverage

**Verdict:** **Both are valuable but serve different purposes**:
- **Feature tests**: Fast feedback, development confidence, most coverage
- **E2E tests**: Production confidence, critical paths only, pre-release validation

**Recommendation:** Keep ~10-20 E2E tests covering critical happy paths. Let Feature tests handle the bulk of scenario coverage.

---

## Test Categories by Layer

### 1. Core Layer (77 tests)

**Files:**
- `test/unit/core/constants/app_constants_test.dart` (30 tests)
- `test/unit/core/constants/api_endpoints_test.dart` (14 tests)
- `test/unit/core/error/exceptions_test.dart` (19 tests)
- `test/unit/core/error/failures_test.dart` (6 tests)
- `test/unit/core/theme/app_colors_test.dart` (8 tests)

**Coverage:** ~100%

**Purpose:** Validate core utilities, constants, errors, and configuration

**Benefits:**
- Ensures configuration correctness
- Validates error handling foundation
- Documents system constants
- **Low E2E overlap** (internal implementation)

---

### 2. Domain Layer (112 tests)

#### Entities (71 tests)
- `test/unit/domain/entities/cell_test.dart` (11 tests)
- `test/unit/domain/entities/game_test.dart` (11 tests)
- `test/unit/domain/entities/game_action_test.dart` (9 tests)
- `test/unit/domain/entities/game_board_test.dart` (24 tests)
- `test/unit/domain/entities/princess_test.dart` (7 tests)
- `test/unit/domain/entities/robot_test.dart` (9 tests)

#### Value Objects (41 tests)
- `test/unit/domain/value_objects/action_type_test.dart` (6 tests)
- `test/unit/domain/value_objects/cell_type_test.dart` (9 tests)
- `test/unit/domain/value_objects/direction_test.dart` (12 tests)
- `test/unit/domain/value_objects/game_status_test.dart` (8 tests)
- `test/unit/domain/value_objects/position_test.dart` (6 tests)

**Coverage:** ~92%

**Purpose:** Validate business entities and value objects

**Benefits:**
- Enforces domain invariants
- Documents entity behavior
- Ensures immutability
- **Very low E2E overlap** (internal domain logic)

---

### 3. Data Layer (150 tests)

**Files:**
- `test/unit/data/models/game_model_test.dart` (37 tests)
- `test/unit/data/repositories/game_repository_impl_test.dart` (60 tests)
- `test/unit/data/datasources/game_remote_datasource_test.dart` (23 tests)
- `test/unit/core/network/api_client_test.dart` (16 tests)

**Coverage:** ~85%

**Purpose:** Validate data transformation, API integration, error mapping

**Benefits:**
- Catches JSON contract changes
- Validates error handling
- Tests repository logic
- **Low E2E overlap** (except for critical data flows)

---

### 4. Use Case Layer (49 tests)

**Files:**
- `test/use_case/domain/use_cases/create_game_impl_test.dart` (13 tests)
- `test/use_case/domain/use_cases/execute_action_impl_test.dart` (13 tests)
- `test/use_case/domain/use_cases/get_games_impl_test.dart` (8 tests)
- `test/use_case/domain/use_cases/get_game_impl_test.dart` (5 tests)
- `test/use_case/domain/use_cases/auto_play_impl_test.dart` (5 tests)
- `test/use_case/domain/use_cases/replay_game_impl_test.dart` (5 tests)

**Coverage:** 100%

**Purpose:** Validate business operations and rules

**Benefits:**
- Documents business operations
- Fast business logic testing
- **Medium E2E overlap** (business rules should be validated E2E too)

---

### 5. Presentation Layer (65 tests)

**UI Component Tests:**
- `test/ui-component/widgets/game_board_widget_test.dart` (13 tests)
- `test/ui-component/widgets/game_info_panel_test.dart` (8 tests)
- `test/ui-component/widgets/direction_selector_test.dart` (7 tests)
- `test/ui-component/widgets/action_button_test.dart` (8 tests)
- `test/ui-component/pages/home/widgets/game_list_item_test.dart` (17 tests)
- `test/ui-component/pages/game/widgets/action_controls_test.dart` (12 tests)

**Coverage:** ~87%

**Purpose:** Validate widget behavior and user interactions

**Benefits:**
- Fast UI testing
- Component documentation
- **High E2E overlap** (UI should be tested E2E for critical paths)

---

### 6. Integration Layer (101 tests)

**Feature Tests:**
- All feature test files listed in Feature Tests section

**Coverage:** Full stack integration

**Purpose:** Validate complete user workflows

**Benefits:**
- Best functional documentation
- Integration confidence
- **Very high E2E overlap** (but much faster)

---

## E2E Testing Considerations

### Current Test Suite vs E2E

**Current Suite (Inside-Out):**
- ✅ Fast feedback (30 seconds for all tests)
- ✅ Reliable (no network, no flakiness)
- ✅ Easy debugging (stack traces, breakpoints)
- ✅ Comprehensive coverage (84.4%)
- ❌ Doesn't test real API integration
- ❌ Doesn't test real UI rendering on devices
- ❌ Doesn't validate production environment

**E2E Suite (Outside-In) - Recommended:**
- ✅ Tests full production stack
- ✅ Validates real API + real UI
- ✅ Catches environment issues
- ✅ Production confidence
- ❌ Slow (minutes to hours)
- ❌ Flaky (network, timing, infrastructure)
- ❌ Expensive to maintain
- ❌ Hard to debug

### Overlap Analysis

```
Test Level          | E2E Overlap | Recommendation
--------------------|-------------|----------------------------------
Unit Tests          | 5%          | Keep separate - internal details
Use Case Tests      | 30%         | Keep separate - faster feedback
UI Component Tests  | 50%         | Keep separate - isolated testing
Feature Tests       | 80%         | High overlap - choose wisely
```

### Recommended E2E Test Suite

**Keep Feature tests for development velocity**
**Add ~10-20 E2E tests for production confidence**

#### Suggested E2E Test Coverage

**Critical Happy Paths (Smoke Tests):**
1. ✅ Create game → See game board
2. ✅ Move robot → See robot move on screen
3. ✅ Pick flower → Collect → Deliver → Win
4. ✅ Auto-play → Game completes → Status updates
5. ✅ View game list → Games displayed
6. ✅ Replay game → See history

**Critical Error Paths:**
7. ✅ Invalid move → Error displayed
8. ✅ Network failure → Error handled gracefully

**Why these few tests?**
- Cover critical user journeys
- Validate production environment
- Quick feedback (5-10 minutes)
- High value vs maintenance cost

### Testing Strategy Summary

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Development (Fast Feedback)                        │
│  ├── Unit Tests:       339 tests (~2s)              │
│  ├── Use Case Tests:    49 tests (~3s)              │
│  ├── Widget Tests:      65 tests (~5s)              │
│  └── Feature Tests:    101 tests (~30s)             │
│                                                     │
│  Total: 554 tests in ~40 seconds ✅                 │
│  Run on: Every commit, local development            │
│                                                     │
└─────────────────────────────────────────────────────┘
                         ⬇
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Pre-Release (Production Confidence)                │
│  └── E2E Tests:        10-20 tests (~10 min)        │
│                                                     │
│  Run on: Pre-release, nightly, critical changes     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Level
```bash
# Unit tests only
flutter test test/unit/

# Use case tests only
flutter test test/use_case/

# UI component tests only
flutter test test/ui-component/

# Feature tests only
flutter test test/feature/
```

### Run with Coverage
```bash
# All tests with coverage
flutter test --coverage

# Combine coverage from all levels
make test
```

### Run Specific Test File
```bash
flutter test test/unit/domain/entities/robot_test.dart
```

### Run Tests Matching Pattern
```bash
flutter test --plain-name "robot"
```

### Watch Mode (Development)
```bash
flutter test --watch
```

### Generate Coverage Report
```bash
make test
make coverage-html
open coverage/html/index.html
```

---

## Related Documentation

- [Testing Strategy](TESTING_STRATEGY.md) - Overall testing approach
- [Coverage Guide](COVERAGE.md) - Coverage metrics and goals
- [Architecture](ARCHITECTURE.md) - System architecture
- [CI/CD](CI_CD.md) - Continuous integration setup
- [Contributing](../CONTRIBUTING.md) - Contribution guidelines

---

## Appendix: Test File Organization

```
test/
├── unit/                          # 339 tests (Unit Tests)
│   ├── core/
│   │   ├── constants/             # Configuration tests
│   │   ├── error/                 # Exception/Failure tests
│   │   ├── network/               # API client tests
│   │   └── theme/                 # Theme tests
│   ├── data/
│   │   ├── models/                # Model serialization tests
│   │   ├── repositories/          # Repository tests
│   │   └── datasources/           # Datasource tests
│   └── domain/
│       ├── entities/              # Entity logic tests
│       └── value_objects/         # Value object tests
│
├── use_case/                      # 49 tests (Use Case Tests)
│   └── domain/use_cases/          # Business operation tests
│
├── ui-component/                  # 65 tests (UI Component Tests)
│   ├── widgets/                   # Reusable widget tests
│   └── pages/                     # Page widget tests
│
└── feature/                       # 101 tests (Feature Tests)
    ├── fakes/                     # Fake implementations
    ├── game_flow_feature_test.dart
    ├── auto_play_feature_test.dart
    ├── replay_feature_test.dart
    ├── game_scenarios_feature_test.dart
    ├── game_state_feature_test.dart
    ├── error_handling_feature_test.dart
    └── workflow_integration_feature_test.dart
```

---

**Last Updated:** October 2025
**Maintainers:** Development Team
**Related:** [TESTING_STRATEGY.md](TESTING_STRATEGY.md), [COVERAGE.md](COVERAGE.md)
