import "package:html/dom.dart";
import "package:oxanime/utilities/logs.dart";
import "package:oxanime/utilities/network.dart";

class SourceHtmlParser {
  final String html;
  late final Document serializedHtml;

  SourceHtmlParser._({required this.html});

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
    String parsedDescription = "";
    for (var word in parsedText.split(' ')) {
      if (serieExcludes.any((element) => word.contains(element))) continue;
      parsedDescription += word;
      parsedDescription += " ";
    }
    return parsedDescription.trim();
  }

  Future<void> _initializeSerializedHtml() async {
    serializedHtml = await SourceConnection().parseHtml(html);
  }

  static Future<SourceHtmlParser> create({required String html}) async {
    final parser = SourceHtmlParser._(html: html);
    await parser._initializeSerializedHtml();
    return parser;
  }
}
