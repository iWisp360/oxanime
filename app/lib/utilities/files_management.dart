import "dart:convert";
import "dart:io";

import "package:oxanime/utilities/logs.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

/// Data Directory means Application Support Directory
/// This post explains the path where getApplicationSupportDirectory points to in Android:
/// https://stackoverflow.com/questions/73685676/difference-between-application-documents-directory-and-support-directory-in-path
///
/// See https://pub.dev/packages/path_provider
///
/// On linux, it should be located at ~/.local/share/page.codeberg.oxanime/
///
Future<String> getDataDirectoryWithJoined(String pattern) async {
  try {
    return path.join((await getApplicationSupportDirectory()).path, pattern);
  } catch (e, s) {
    logger.e("Error while getting Application Support Directory: $e\n$s");
    rethrow;
  }
}

// Buffered I/O improves performance. See
// https://www.geeksforgeeks.org/operating-systems/i-o-buffering-and-its-various-techniques/

extension BufferedFileIO on File {
  Future<String> bufferedRead() async {
    try {
      final StringBuffer fileContents = StringBuffer();
      await for (var chunk in utf8.decoder.bind(openRead())) {
        fileContents.write(chunk);
      }
      return fileContents.toString();
    } catch (e) {
      logger.e("Error while reading from file: $e");
      rethrow;
    }
  }

  Future<void> bufferedWrite(String contents) async {
    try {
      final sink = openWrite();
      sink.write(contents);

      await sink.flush();
      await sink.close();
    } catch (e) {
      logger.e("Error while writing to file: $e");
      rethrow;
    }
  }
}
