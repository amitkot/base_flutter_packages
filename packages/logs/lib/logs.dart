library logs;

import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

typedef CrashlyticsLog = Function(String);

class Logs {
  factory Logs() => _singleton;
  Logs._internal() : _logs = Queue<LogRecord>();

  static const Level defaultLogLevel = Level.FINE;
  static const int maxLogRecords = 10000;

  static final _singleton = Logs._internal();

  final Queue<LogRecord> _logs;

  void setupLogging(
      {Level level = defaultLogLevel, CrashlyticsLog? crashlyticsLog}) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        debugPrint(_formatRecordIso8601(record));
      }

      _add(record);
      _removeOldRecords();

      // Add logs to Crashlytics so that if the app crashes we will get debug
      // logs
      if (crashlyticsLog != null) {
        crashlyticsLog(_formatRecordIso8601(record));
      }
    });
  }

  BuiltList<String> getRecords() =>
      _logs.map(_formatRecordIso8601).toBuiltList();

  Level get level => Logger.root.level;
  set level(Level level) {
    Logger.root.level = level;
  }

  void _add(LogRecord record) {
    _logs.addLast(record);
  }

  void _removeOldRecords() {
    while (_logs.length > maxLogRecords) {
      _logs.removeFirst();
    }
  }

  String _formatRecordIso8601(LogRecord record) =>
      '''${record.time.toIso8601String()} [${record.level.name}] ${record.loggerName} -- ${record.message}${_maybeAdd(record.error)}${_maybeAdd(record.stackTrace)}''';

  String _maybeAdd(Object? part) {
    if (part == null) {
      return '';
    }
    return '\n${part.toString()}';
  }
}
