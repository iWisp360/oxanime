// Never gonna give you up
// WIP: Backup utility & download management

import "dart:io";

import "package:animebox/core/constants.dart";
import "package:animebox/core/logs.dart";
import "package:animebox/core/preferences.dart";
import "package:animebox/domain/sources.dart";
import "package:animebox/presentation/app.dart";
import "package:animebox/widgets/themes.dart";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();

  await themeController.load();

  try {
    sources = await Source.getSources();
    sourcesInitSuccess = true;
  } catch (e) {
    if (e != PathNotFoundException) {
      try {
        logger.e(
          "First attempt of getting sources failed, trying to create the file and trying again",
        );
        await File(
          join((await getApplicationSupportDirectory()).path, FileNames.sourcesJson),
        ).create(recursive: true);
        sources = await Source.getSources();
        sourcesInitSuccess = true;
      } catch (e) {
        logger.e("Sources couldn't be retrieved from local storage: $e");
        sourcesInitSuccess = false;
        // WIP: Notify this through UI
        sources = [Placeholders.source];
      }
    }
  }

  try {
    logger.i("Logging to file");
    await initLogger();
  } catch (e) {
    logger.e(e);
  }

  if (await preferences.getBool("logging") == false) {
    logger.i("Disabling Logs");
    logger.close();
  }

  runApp(ChangeNotifierProvider.value(value: themeController, child: AnimeBoxApp()));
}

Future<void> initLogger() async {
  logger.i(
    "Initializing Logger... What? but this is a logger :/\nxD But a logger that logs to a file",
  );
  logger = await AnimeBoxLogger.makeLogger();
}
