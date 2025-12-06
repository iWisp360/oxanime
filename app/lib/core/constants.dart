import 'package:oxanime/domain/sources.dart';

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

class FileNames {
  static const sourcesJson = "sources.json";
  static const seriesJson = "series.json";
}

class AdviceMessages {
  static const forSourcesIfNotValid = """
  enabled (if not set, it is assumed to be false)
  mainUrl
  searchUrl
  chaptersVideosUrlLocation
  chaptersVideosJsonListStartPattern
  chaptersVideosJsonListEndPattern
  chaptersVideosUrlParseMode
  if chaptersVideosUrlParseMode is cssClass:
    searchSerieNameCSSClass
    searchSerieUrlCSSClass
    searchSerieChaptersIdentifiersCSSClass
    searchSerieChaptersUrlsCSSClass

  uuid (this one is generated if there is none specified)

  Note: This is the bare minimum for a source to work with OxAnime,
    however, you may also want to specify other fields for the source
    to fully integrate. Check the wiki at <wikiUrlHere>.

  Note: If you pass an UUID manually, this UUID should be valid, otherwise, the entire source won't be valid.
  """;
}
