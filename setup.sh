#!/bin/bash
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
