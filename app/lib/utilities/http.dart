import "package:html/dom.dart";
import "package:oxanime/utilities/logs.dart";
import "package:oxanime/utilities/network.dart";

class SourceHtmlParser {
  final String html;
  late final Document serializedHtml;

  SourceHtmlParser._({required this.html});

  /// fields such as name and description can be obtained from the value of a tag matching a css class
  Future<String?> getSerieCSSClassText(
    final String serieCSSClass,
    final List<String> serieExcludes,
  ) async {
    final serializedElements = serializedHtml.querySelectorAll(serieCSSClass);
    String? parsedText;
    for (var element in serializedElements) {
      parsedText ??= "";
      parsedText += (" ") + element.text;
    }
    if (parsedText == null) {
      logger.e("Error while getting serie css class text: querySelector() returned null");
      return null;
    }
    String parsedResult = "";
    for (var word in parsedText.split(' ')) {
      if (serieExcludes.any((element) => word.contains(element))) continue;
      parsedResult += word;
      parsedResult += " ";
    }
    return parsedResult.trim();
  }

  // serialize the response body from a URL into a global variable
  Future<void> _initializeSerializedHtml() async {
    serializedHtml = await SourceConnection.parseHtml(html);
  }

  /// This creates a parser from the deserialized html that can get values from the serialized html
  static Future<SourceHtmlParser> create({required String html}) async {
    final parser = SourceHtmlParser._(html: html);
    await parser._initializeSerializedHtml();
    return parser;
  }
}
