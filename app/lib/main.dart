import 'package:flutter/material.dart';
import "package:oxanime/utilities/logs.dart";
import "package:oxanime/utilities/sources.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() async {
  await OxAnimeLoggerSingleton().createLogger();
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

  // ignore: unused_local_variable
  var sources = await SourceParser().getSources();
}

final preferences = SharedPreferencesAsync();

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
