import "dart:io";

import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:path_provider/path_provider.dart";

class OxAnimeLogger {
  // ignore: unused_field
  static Future<Logger> makeLogger() async {
    final logFile = await _getLogsFile();
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
      output: await _getLogOutput(),
    );
  }
}

Future<File> _getLogsFile() async {
  final logFile = File(
    await (getApplicationCacheDirectory().then((value) => value.path)) +
        ("/oxanime.log"),
  );
  return logFile;
}

Future<FileOutput> _getLogOutput() async {
  final logFile = await _getLogsFile();
  return FileOutput(file: logFile);
}
