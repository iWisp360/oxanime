import "package:flutter/services.dart";
import "package:global_configuration/global_configuration.dart";
import "package:oxanime/main.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";

final configPath = getApplicationSupportDirectory().then(
  (value) => value.path + ("/config.json"),
);

Future copyAssetToConfigPath(String asset) async {
  if (!asset.endsWith(".json")) {
    asset += ".json";
  }
  final configFile = File(await configPath);
  try {
    String assetContents = await rootBundle.loadString("assets/cfg/$asset");
    logger.i("Writing\n$assetContents\nto ${await configPath}");
    configFile.writeAsStringSync(assetContents);
  } catch (e) {
    rethrow;
  }
}

Future loadConfiguration() async {
  logger.i("Reading config");
  try {
    await GlobalConfiguration().loadFromPath(await configPath);
  } on PathAccessException catch (e) {
    logger.f(e);
    logger.f("Access Denied while accessing config.json");
  } catch (e) {
    logger.e(e);
    logger.i("Configuration not found or invalid. Loading defaults");
    try {
      await GlobalConfiguration().loadFromAsset("defaultConfig");
      logger.i("Loading defaults into persistent storage");
      await copyAssetToConfigPath("defaultConfig");
    } catch (e) {
      logger.f(e);
    }
  }
}
