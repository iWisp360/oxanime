import 'package:animebox/domain/sources.dart';

class FileNames {
  static const sourcesJson = "sources.json";
  static const seriesJson = "series.json";
  static const logsFile = "animebox.log";
}

class HtmlValues {
  static const href = "href";
  static const scriptTag = "script";
  static const src = "src";
}

class HttpValues {
  static const userAgent = "Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0";
}

class Placeholders {
  static const uuid = "completely-invalid-uuid";
  static const url = "https://mock.example.com";
  static const emptyString = "";
  static final source = Source(
    configurationFields: SourceConfigurationFields(
      enabled: false,
      mainUrl: Placeholders.emptyString,
      searchUrl: Placeholders.emptyString,
      name: "Placeholder Source",
    ),
    searchFields: SourceSearchFields(serieUrlCSSClass: Placeholders.emptyString),

    serieFields: SourceSerieFields(),
    chaptersFields: SourceChaptersFields(),
    videosFields: SourceVideosFields(),
  );
}
