import 'package:flutter/material.dart';
import "package:global_configuration/global_configuration.dart";
import "package:logger/logger.dart";
import "package:oxanime/utilities/configuration.dart";
import "package:dynamic_color/dynamic_color.dart";

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await loadConfiguration();
  } catch (e) {
    throw ("Configuration Load failed!!!");
  }
  if (GlobalConfiguration().getValue("logging") == false) {
    logger.i("Disabling Logs");
    logger.close();
  }
  GlobalConfiguration().updateValue("logging", false);
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
