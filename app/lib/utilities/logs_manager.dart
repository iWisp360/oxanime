import "dart:io";

import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:path_provider/path_provider.dart";

final logFile = File(
  (getApplicationCacheDirectory().toString()) + ("oxanime.log"),
);
final logger = _OxAnimeLogger();

class _OxAnimeLogger {
  // ignore: unused_field
  static Logger _logger = _makeLogger(Level.all);

  static Logger _makeLogger(Level? level) {
    final filter = kDebugMode ? DevelopmentFilter() : ProductionFilter();
    if (logFile.existsSync() == true) {
      logFile.deleteSync();
    }
    return _logger = Logger(
      level: level,
      filter: filter,
      printer: PrettyPrinter(
        colors: kDebugMode ? true : false,
        printEmojis: true,
        methodCount: 48,
        errorMethodCount: 48,
      ),
      output: FileOutput(file: logFile),
    );
  }
}
