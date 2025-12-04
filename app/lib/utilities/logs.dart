import "dart:io";

import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:path_provider/path_provider.dart";

Logger logger = Logger();

Future<File> _getLogFile() async {
  final logFile = File(
    await (getApplicationCacheDirectory().then((value) => value.path)) + ("/oxanime.log"),
  );
  return logFile;
}

Future<FileOutput> _getLogOutput() async {
  final logFile = await _getLogFile();
  return FileOutput(file: logFile);
}

class OxAnimeLogger {
  static Future<Logger> makeLogger() async {
    final logFile = await _getLogFile();
    final filter = kDebugMode ? DevelopmentFilter() : ProductionFilter();
    if (await logFile.exists() == true) {
      await logFile.delete();
    }
    return Logger(
      level: Level.all,
      filter: filter,
      printer: PrettyPrinter(
        colors: kDebugMode ? true : false,
        printEmojis: true,
        methodCount: 48,
        errorMethodCount: 48,
      ),
      output: kDebugMode ? ConsoleOutput() : await _getLogOutput(),
    );
  }
}
