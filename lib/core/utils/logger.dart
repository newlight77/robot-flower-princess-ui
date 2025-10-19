import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void error(String message, {String tag = 'ERROR', Object? error}) {
    if (kDebugMode) {
      print('[$tag] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    log(message, tag: tag);
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    log(message, tag: tag);
  }

  static void debug(String message, {String tag = 'DEBUG'}) {
    log(message, tag: tag);
  }
}
