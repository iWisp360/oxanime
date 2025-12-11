import "package:animebox/core/constants.dart";
import "package:animebox/core/enums.dart";

import "package:animebox/data/video_url_parsers/yourupload.dart";
import "package:animebox/data/video_url_parsers/streamwish.dart";
import "package:animebox/data/video_url_parsers/streamtape.dart";

mixin VideoSourceParameters {
  bool get needsAWebView => false;
}

// In this context, a parser is the utility that brings you the content you need to watch a serie chapter,
// either by natively streaming it or embedding a webview player if getting a URL is not possible.
// A parser gets the following contents if available:
// - URL or a List of URLs of the static content of the video
// - Video Quality Options -> not implemented
// - Video Duration -> MediaKit does this, so these things actually don't
class VideoUrlParser {
  static List<String> allVideoSourcesDomainNames() {
    List<String> results = [];

    for (final parser in VideoUrlParsers.values) {
      results.add(videoSourcesDomainNames(parser));
    }
    return results;
  }

  static VideoUrlParsers assignVideoSourceById(final String id) {
    switch (id) {
      case "yourupload":
        return VideoUrlParsers.yourUpload;
      case "stape":
        return VideoUrlParsers.streamTape;
      default:
        return VideoUrlParsers.none;
    }
  }

  static VideoUrlParsers assignVideoSourceByUrl(final String url) {
    for (final source in VideoUrlParsers.values) {
      final domainName = videoSourcesDomainNames(source);
      if (url.contains(domainName)) {
        return source;
      }
    }
    return VideoUrlParsers.none;
  }

  // if this returns null, a webview is required
  static Future<String?> parseVideoUrl(final String url, VideoUrlParsers parser) async {
    switch (parser) {
      case VideoUrlParsers.yourUpload:
        return await YourUpload.getVideoFromUrl(url);
      case VideoUrlParsers.streamTape:
        return await StreamTape.getVideoFromUrl(url);
      case VideoUrlParsers.streamWish:
        return await StreamWish.getVideoFromUrl(url);
      case VideoUrlParsers.none:
        return null;
    }
  }

  static Future<List<String>> sortVideoUrls(
    List<String> initialUrls,
    final List<String>? videoSourcePriority,
  ) async {
    if (videoSourcePriority == null || videoSourcePriority.isEmpty) {
      return initialUrls;
    }

    List<String> sortedUrls = [];

    for (final priority in videoSourcePriority) {
      if (initialUrls.isEmpty) break;
      final videoSource = assignVideoSourceById(priority);
      final domainName = videoSourcesDomainNames(videoSource);

      for (var url in initialUrls) {
        if (url.contains(domainName)) {
          sortedUrls.add(url);
          initialUrls.removeWhere((element) => element == url);
        }
      }
    }

    if (initialUrls.isNotEmpty) {
      for (var url in initialUrls) {
        sortedUrls.add(url);
      }
    }

    return sortedUrls;
  }

  static String videoSourcesDomainNames(VideoUrlParsers videoSource) {
    return switch (videoSource) {
      VideoUrlParsers.yourUpload => "yourupload.com",
      VideoUrlParsers.streamTape => "streamtape.com",
      VideoUrlParsers.streamWish => "streamwish.to",
      VideoUrlParsers.none => Placeholders.emptyString,
    };
  }
}
