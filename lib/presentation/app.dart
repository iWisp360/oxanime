import 'package:animebox/core/enums.dart';
import 'package:animebox/l10n/animebox_translations.dart';
import 'package:animebox/presentation/home.dart';
import 'package:animebox/widgets/themes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimeBoxApp extends StatelessWidget {
  const AnimeBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ThemePair theme;

        if (themeController.themeId == SupportedThemes.dynamic &&
            lightDynamic != null &&
            darkDynamic != null) {
          theme = ThemePair(
            light: ThemeData.from(colorScheme: lightDynamic, useMaterial3: true).copyWith(
              applyElevationOverlayColor: true,
              navigationBarTheme: NavigationBarThemeData(backgroundColor: lightDynamic.surface),
            ),
            dark: ThemeData.from(colorScheme: darkDynamic, useMaterial3: true).copyWith(
              applyElevationOverlayColor: true,

              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Color.lerp(darkDynamic.surface, Colors.white, 0.05),
              ),
            ),
          );
        } else {
          theme =
              AnimeBoxThemes.getThemeById(themeController.themeId) ??
              AnimeBoxThemes.themes[SupportedThemes.fallback]!;
        }

        return MaterialApp(
          title: "Anime Box",
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: AnimeBoxHome(),

          themeMode: themeController.mode,
          theme: theme.light,
          darkTheme: theme.dark,
        );
      },
    );
  }
}
