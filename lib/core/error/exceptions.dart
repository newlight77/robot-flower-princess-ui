class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network connection failed']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation error']);
}

class GameOverException implements Exception {
  final String message;
  GameOverException([this.message = 'Game Over']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Resource not found']);
}
