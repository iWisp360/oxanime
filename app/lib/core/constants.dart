import 'package:oxanime/core/enums.dart';
import 'package:oxanime/domain/sources.dart';

class HtmlValues {
  static const href = "href";
  static const scriptTag = "script";
  static const src = "src";
}

class PlaceHolders {
  static const uuid = "completely-invalid-uuid";
  static const url = "https://mock.example.com";
  static const emptyString = "";
  static final source = Source(
    uuid: PlaceHolders.uuid,
    name: "Placeholder Source",
    mainUrl: PlaceHolders.url,
    searchUrl: PlaceHolders.url,

    chaptersVideosJsonListStartPattern: PlaceHolders.emptyString,
    chaptersVideosJsonListEndPattern: PlaceHolders.emptyString,
    chaptersVideosJsonListKey: PlaceHolders.emptyString,
    chaptersVideosUrlParseMode: ChaptersVideosUrlParseModes.empty,
    chaptersVideosUrlLocation: ChaptersVideosUrlLocation.empty,
    videoSourcesPriority: const [],

    searchSerieNameCSSClass: PlaceHolders.emptyString,
    searchSerieUrlCSSClass: PlaceHolders.emptyString,
    searchSerieImageCSSClass: PlaceHolders.emptyString,
    searchSerieChaptersIdentifiersCSSClass: PlaceHolders.emptyString,
    searchSerieChaptersUrlsCSSClass: PlaceHolders.emptyString,
    searchSerieDescriptionCSSClass: PlaceHolders.emptyString,
  );
}

class FileNames {
  static const sourcesJson = "sources.json";
  static const seriesJson = "series.json";
}

class RequiredValues {
  static const forSources = """
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

  Note: If you pass an UUID manually, this UUID should be valid.
  """;
}
