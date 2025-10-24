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

test: ## Run tests
	flutter test

test-coverage: ## Run tests with coverage
	@echo "🧪 Running tests with coverage..."
	@flutter test --coverage
	@echo ""
	@echo "📊 COVERAGE REPORT"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@lcov --summary coverage/lcov.info 2>/dev/null || echo "⚠️  lcov not installed. Install with: brew install lcov"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "📄 Coverage file: coverage/lcov.info"
	@echo ""

coverage-html: test-coverage ## Generate HTML coverage report
	@echo "🌐 Generating HTML coverage report..."
	@genhtml coverage/lcov.info -o coverage/html 2>/dev/null || echo "⚠️  genhtml not installed. Install with: brew install lcov"
	@echo "✅ HTML report generated at coverage/html/index.html"

coverage-detail: ## Show detailed coverage by file
	@echo "📊 DETAILED COVERAGE BY FILE"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@lcov --list coverage/lcov.info 2>/dev/null || echo "⚠️  lcov not installed. Install with: brew install lcov"

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
