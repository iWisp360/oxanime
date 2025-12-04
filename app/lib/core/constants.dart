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
  static const forSources =
      "mainUrl\n"
      "searchUrl\n"
      "videosUrlParseMode\n"
      "uuid (this one is generated if there is none specified)\n";
}
