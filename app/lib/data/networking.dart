import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart" as http;
import "package:oxanime/core/logs.dart";

class SourceConnection {
  static Future<String> getBodyFrom(String url) async {
    final pageUrl = Uri.parse(url);
    try {
      logger.d("Executing HTTP GET request to URL $url");
      var response = await http.get(pageUrl);
      return response.body;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  /// if you give "example.com" you get "https://example.com/"
  static String makeUrlFromDomainName(final String domainName) {
    return "https://$domainName/";
  }

  static String makeUrlFromRelative(String part1, String part2) {
    return part1 + part2;
  }

  static Future<Document> parseHtml(String response) async {
    return parse(response);
  }
}
