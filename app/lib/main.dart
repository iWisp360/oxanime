// Never gonna give you up
// WIP: Backup utility & download management

import "dart:io";

import "package:flutter/material.dart";
import "package:media_kit/media_kit.dart";
import "package:oxanime/core/constants.dart";
import "package:oxanime/core/logs.dart";
import "package:oxanime/core/preferences.dart";
import "package:oxanime/domain/sources.dart";
import "package:oxanime/widgets/testing.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  try {
    sources = await Source.getSources();
    sourcesInitSuccess = true;
  } catch (e) {
    if (e != PathNotFoundException) {
      try {
        await File(
          join((await getApplicationSupportDirectory()).path, FileNames.sourcesJson),
        ).create(recursive: true);
        sources = await Source.getSources();
        sourcesInitSuccess = true;
      } catch (e) {
        logger.e("Sources couldn't be retrieved from local storage: $e");
        sourcesInitSuccess = false;
        // WIP: Notify this through UI
        sources = [PlaceHolders.source];
      }
    }
    // WIP: Here too
    rethrow;
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
  runApp(OxAnimeMainApp());
}

Future<void> initLogger() async {
  logger.i(
    "Initializing Logger... What? but this is a logger :/\nxD But a logger that logs to a file",
  );
  logger = await OxAnimeLogger.makeLogger();
}

class OxAnimeMainApp extends StatelessWidget {
  const OxAnimeMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "OxAnime", home: TestScaffold(), debugShowCheckedModeBanner: false);
  }
}
