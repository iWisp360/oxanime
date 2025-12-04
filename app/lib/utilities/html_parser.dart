import "package:html/dom.dart";
import "package:oxanime/utilities/logs.dart";
import "package:oxanime/utilities/networking.dart";

const imgHtmlAttribute = "src";
const urlHtmlAttribute = "href";
const scriptHtmlCSSClass = "script";

class SourceHtmlParser {
  final String html;
  late final Document serializedHtml;

  SourceHtmlParser._({required this.html});

  /// gets multiple attribute values from elements that match cssClass
  Future<List<String>> getMultipleCSSClassAttrValue(
    final String cssClass,
    final List<String> excludes,
    final String attribute,
  ) async {
    final serializedElements = serializedHtml.querySelectorAll(cssClass);
    List<String> parsedAttributeValues = [];
    for (var element in serializedElements) {
      if (excludes.any((exclude) => exclude.contains(element.text))) {
        continue;
      } else {
        String elementAttributeValue = element.attributes[attribute] ?? "";
        if (elementAttributeValue.isEmpty) {
          logger.w(
            "Warning: The following element\n${element.innerHtml}\nHas no attribute $attribute",
          );
        }
        parsedAttributeValues.add(elementAttributeValue);
      }
    }
    return parsedAttributeValues;
  }

  /// Retrieves text from multiple elements that match the provided CSS class
  /// Which text? For example: <p>the text over here</p>

  Future<List<String>> getMultipleCSSClassText(
    final String cssClass,
    final List<String> excludes,
  ) async {
    final serializedElements = serializedHtml.querySelectorAll(cssClass);
    List<String> parsedElements = [];
    for (var element in serializedElements) {
      if (excludes.any((exclude) => element.text.contains(exclude))) {
        continue;
      } else {
        parsedElements.add(element.text);
      }
    }
    logger.d("getMultipleCSSClassText returned a list of ${parsedElements.length} elements");
    return parsedElements;
  }

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
      logger.w("Warning while getting serie css class text: querySelector() returned null");
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
