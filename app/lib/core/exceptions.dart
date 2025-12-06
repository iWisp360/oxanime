String _throwError(final Object? errorMsg, final StackTrace? stackTrace) {
  return "${(errorMsg == null) ? "" : ": $errorMsg"}\n"
      "${(stackTrace == null) ? "" : "$stackTrace"}";
}

class SourceException implements Exception {
  final SourceExceptionKind kind;
  final Object? errorMsg;
  final StackTrace? stackTrace;
  SourceException({this.errorMsg, this.stackTrace, this.kind = SourceExceptionKind.otherException});

  @override
  String toString() => switch (kind) {
    SourceExceptionKind.gotPlaceHolderException =>
      "Error while processing source: Source is a placeholder, "
          "probably a source couldn't be assigned or getting sources failed"
          "${_throwError(errorMsg, stackTrace)}",

    SourceExceptionKind.otherException =>
      "Error while processing source${_throwError(errorMsg, stackTrace)}",
  };
}

enum SourceExceptionKind { gotPlaceHolderException, otherException }

class VideoUrlParserException implements Exception {
  final VideoUrlParserExceptionKind kind;
  final Object? errorMsg;
  final StackTrace? stackTrace;
  VideoUrlParserException({
    this.kind = VideoUrlParserExceptionKind.otherException,
    this.errorMsg,
    this.stackTrace,
  });

  @override
  String toString() => switch (kind) {
    VideoUrlParserExceptionKind.requestMakeException =>
      "Error while creating request for Video Url${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.responseReceiveException =>
      "Error while getting response from Video Url${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.responseParseException =>
      "Error while parsing response from Video Url${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.videoNotFoundException =>
      "Error while parsing response from Video Url"
          "(Probably the video couldn't be found in this source)"
          "${_throwError(errorMsg, stackTrace)}",
    VideoUrlParserExceptionKind.otherException =>
      "Error from a video url parser${_throwError(errorMsg, stackTrace)}",
  };
}

enum VideoUrlParserExceptionKind {
  requestMakeException,
  responseReceiveException,
  responseParseException,
  videoNotFoundException,
  otherException,
}
