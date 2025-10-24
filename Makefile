#!make

# Robot Flower Princess - Makefile

SHELL := /bin/sh

.PHONY: help install clean test build run docker-build docker-run

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $1, $2}'

install: ## Install dependencies
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs

clean: ## Clean build artifacts
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/

test: ## Run all tests
	flutter test

test-unit: ## Run unit tests only (individual functions and classes)
	@echo "🧪 Running UNIT tests..."
	@flutter test test/unit/ --coverage --coverage-path coverage/unit-coverage/lcov.info
	@echo "✅ Unit tests complete!"
	@echo "📊 Total Coverage: $$(lcov --summary coverage/unit-coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')%"

test-use-case: ## Run use case tests only (business logic and rules)
	@echo "🧪 Running USE CASE tests..."
	@flutter test test/use_case/ --coverage --coverage-path coverage/use-case-coverage/lcov.info
	@echo "✅ Use case tests complete!"
	@echo "📊 Total Coverage: $$(lcov --summary coverage/use-case-coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')%"

test-widget: ## Run widget tests only (UI component tests)
	@echo "🧪 Running WIDGET tests..."
	@flutter test test/widget/ --coverage --coverage-path coverage/widget-coverage/lcov.info
	@echo "✅ Widget tests complete!"
	@echo "📊 Total Coverage: $$(lcov --summary coverage/widget-coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')%"

test-feature: ## Run feature tests only (end-to-end with fake backend)
	@echo "🧪 Running FEATURE tests..."
	@flutter test test/feature/ --coverage --coverage-path coverage/feature-coverage/lcov.info
	@echo "✅ Feature tests complete!"
	@echo "📊 Total Coverage: $$(lcov --summary coverage/feature-coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')%"

test-all: ## Run all tests
	@echo "🧪 Running ALL TEST SUITES..."
	@echo ""
	@echo "═══════════════════════════════════════════════════"
	@echo "1️⃣  UNIT TESTS (Functions & Classes)"
	@echo "═══════════════════════════════════════════════════"
	@make test-unit
	@echo ""
	@echo "═══════════════════════════════════════════════════"
	@echo "2️⃣  USE CASE TESTS (Business Logic)"
	@echo "═══════════════════════════════════════════════════"
	@make test-use-case
	@echo ""
	@echo "═══════════════════════════════════════════════════"
	@echo "3️⃣  WIDGET TESTS (UI Components)"
	@echo "═══════════════════════════════════════════════════"
	@make test-widget
	@echo ""
	@echo "═══════════════════════════════════════════════════"
	@echo "4️⃣  FEATURE TESTS (End-to-End)"
	@echo "═══════════════════════════════════════════════════"
	@make test-feature
	@echo ""
	@echo "✅ ALL TESTS COMPLETE!"

coverage:
	@make coverage-combine
	@make coverage-threshold
	@make coverage-detail
	@echo "✅ Coverage Workflow Complete!"
	@echo ""

test-coverage: ## Run tests with coverage
	@make test-unit
	@make test-use-case
	@make test-widget
	@make test-feature
	@make coverage-combine
	@make coverage-threshold
	@make coverage-detail
	@echo "✅ Coverage Workflow Complete!"
	@echo ""

coverage-combine:
	@echo "🎯 Merging coverage reports..."
	@lcov --add-tracefile coverage/unit-coverage/lcov.info \
	      --add-tracefile coverage/use-case-coverage/lcov.info \
	      --add-tracefile coverage/widget-coverage/lcov.info \
	      --add-tracefile coverage/feature-coverage/lcov.info \
	      --output-file coverage/lcov.info
	@echo "🔧 Removing test helpers from coverage..."
	@lcov --remove coverage/lcov.info \
	      '*/game_mock_datasource.dart' \
	      '*/game_mock_repository.dart' \
	      --output-file coverage/lcov.info
	@echo "✅ Coverage reports merged (excluding mock files)"
	@echo ""

coverage-html: test-all coverage-combine coverage-threshold ## Generate HTML coverage report
	@echo "🌐 Generating HTML coverage report..."
	@genhtml coverage/lcov.info -o coverage/html 2>/dev/null || echo "⚠️  genhtml not installed. Install with: brew install lcov"
	@echo "✅ HTML report generated at coverage/html/index.html"

coverage-threshold:
	@echo "🎯 Checking coverage threshold (80%)..."
	@COVERAGE=$$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $$2}' | sed 's/%//'); \
	THRESHOLD=80; \
	if [ $$(echo "$$COVERAGE < $$THRESHOLD" | bc) -eq 1 ]; then \
		echo "❌ Coverage $$COVERAGE% is below threshold $$THRESHOLD%"; \
		exit 1; \
	else \
		echo "✅ Coverage $$COVERAGE% meets threshold $$THRESHOLD%"; \
	fi

coverage-detail: ## Show detailed coverage by file
	@echo "📊 DETAILED COVERAGE BY FILE"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@lcov --list coverage/lcov.info 2>/dev/null || echo "⚠️  lcov not installed. Install with: brew install lcov"


coverage-clean: ## Clean coverage artifacts
	@echo "🧹 Cleaning CI artifacts..."
	@rm -rf coverage-artifacts
	@rm -rf coverage
	@echo "✅ Clean complete"

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
	docker build -t robot-flower-princess-ui:latest .

docker-run: ## Run Docker container
	docker run -p 8080:80 robot-flower-princess-ui:latest

docker-stop: ## Stop Docker container
	docker stop $(docker ps -q --filter ancestor=robot-flower-princess:latest)

setup: ## Complete setup (install + generate code)
	@echo "🚀 Setting up Robot Flower Princess..."
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Setup complete!"

dev: ## Run in development mode
	flutter run -d chrome --hot

run: ## Run in production mode
	flutter run -d chrome

ci: ## Run CI checks
	flutter pub get
	flutter analyze
	flutter test --coverage
	flutter build web --release
