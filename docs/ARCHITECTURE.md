# Architecture Documentation

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

## Related Documentation

- [Testing Strategy](TESTING_STRATEGY.md) - Comprehensive testing approach
- [API Integration](API.md) - Backend integration details
- [CI/CD Pipeline](CI_CD.md) - Automated testing and deployment
- [Deployment Guide](DEPLOYMENT.md) - Deployment instructions

---

**Last Updated**: October 24, 2025
**Version**: 1.1
