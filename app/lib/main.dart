// Never gonna give you up

import "package:flutter/material.dart";
import "package:oxanime/utilities/http.dart";
import "package:oxanime/utilities/logs.dart";
import "package:oxanime/utilities/network.dart";
import "package:oxanime/utilities/preferences.dart";
import "package:oxanime/utilities/sources.dart";

void main() async {
  await LoggerSingleton().createLogger();
  sources = await SourceManager().getSources();
  WidgetsFlutterBinding.ensureInitialized();
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

  // UI should be initialized
  // º
  // here

  print(sources[0]);
}

// class OxAnimeMainApp extends StatelessWidget {
//   const OxAnimeMainApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "OxAnime",
//       theme: ThemeData(colorScheme: )
//     );
//   }
// }

// Future<ColorScheme?> getDynamicColorScheme() async {
//   final color = await DynamicColorPlugin.getAccentColor();
//   if (color == null) return null;
//   final colorScheme = color.harmonizeWith()
// }

Future<void> initLogger() async {
  logger = await OxAnimeLogger.makeLogger();
}
