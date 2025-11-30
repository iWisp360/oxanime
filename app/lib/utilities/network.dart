import "package:http/http.dart" as http;
import "package:oxanime/utilities/logs.dart";

class OxAnimeSourceConnection {
  Future get(String url) async {
    final pageUrl = Uri.parse(url);
    try {
      var response = await http.get(pageUrl);
      return response;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
