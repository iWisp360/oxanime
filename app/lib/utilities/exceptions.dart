String _throwError(final Object errorMsg, final StackTrace stackTrace) {
  return "$errorMsg\n$stackTrace";
}

class VideoUrlParserException implements Exception {
  final VideoUrlParserExceptionKind kind;
  final Object errorMsg;
  StackTrace stackTrace;
  VideoUrlParserException({
    this.kind = VideoUrlParserExceptionKind.otherException,
    required this.errorMsg,
    required this.stackTrace,
  });

  @override
  String toString() => switch (kind) {
    VideoUrlParserExceptionKind.requestMakeException =>
      "Error while creating request for Video Url: ${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.responseReceiveException =>
      "Error while getting response from Video Url: ${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.responseParseException =>
      "Error while parsing response from Video Url: ${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.otherException =>
      "Error from a video url parser: ${_throwError(errorMsg, stackTrace)}",
  };
}

enum VideoUrlParserExceptionKind {
  requestMakeException,
  responseReceiveException,
  responseParseException,
  otherException,
}
