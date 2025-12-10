import "dart:io";

import "package:animebox/core/constants.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:path_provider/path_provider.dart";

Logger logger = Logger();

Future<File> _getLogFile() async {
  final logFile = File(
    await (getApplicationCacheDirectory().then((value) => value.path)) + ("/${FileNames.logsFile}"),
  );
  return logFile;
}

Future<FileOutput> _getLogOutput() async {
  final logFile = await _getLogFile();
  return FileOutput(file: logFile);
}

class AnimeBoxLogger {
  static Future<Logger> makeLogger() async {
    final logFile = await _getLogFile();
    final filter = kDebugMode ? DevelopmentFilter() : ProductionFilter();
    if (await logFile.exists() == true) {
      await logFile.delete();
      await logFile.create();
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
