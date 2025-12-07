import 'package:animebox/core/constants.dart';
import 'package:animebox/core/enums.dart';
import 'package:animebox/core/logs.dart';
import 'package:animebox/domain/sources.dart';

class ValidationResult {
  final bool result;
  final String errorsReport;
  final String warningsReport;

  ValidationResult({
    required this.result,
    required this.errorsReport,
    required this.warningsReport,
  });
}

class ValidateSource {
  final Map<String, List<String>> validationErrors = {};
  final Map<String, List<String>> validationWarnings = {};

  static ValidationResult validate(Source source) {
    final sourceValidator = ValidateSource();

    sourceValidator._sourceConfigurationFields(source);
    sourceValidator._sourceSearchFields(source);
    sourceValidator._sourceSeriesFields(source);
    sourceValidator._sourceChaptersFields(source);
    sourceValidator._sourceVideosFields(source);

    final warningsReport = sourceValidator._reportSourceWarnings();
    final errorsReport = sourceValidator._reportSourceErrors();
    logger.i(errorsReport.isEmpty ? errorsReport : "No Errors");
    logger.i(warningsReport.isEmpty ? warningsReport : "No Warnings");

    bool isValid = sourceValidator.validationErrors.isEmpty;

    return ValidationResult(
      result: isValid,
      errorsReport: errorsReport,
      warningsReport: warningsReport,
    );
  }

  void _addError(String fieldName, String message) {
    validationErrors.putIfAbsent(fieldName, () => []).add(message);
  }

  void _addWarning(String fieldName, String message) {
    validationWarnings.putIfAbsent(fieldName, () => []).add(message);
  }

  String _reportSourceErrors() {
    StringBuffer report = StringBuffer("Validation errors:\n");
    validationErrors.forEach((fieldName, messages) {
      report.write("- At $fieldName\n");
      if (messages.isEmpty) report.write("  - None");
      for (var msg in messages) {
        report.write("$msg\n");
      }
    });
    return report.toString();
  }

  String _reportSourceWarnings() {
    StringBuffer report = StringBuffer("Validation warnings:\n");
    validationWarnings.forEach((fieldName, messages) {
      report.write("- At $fieldName\n");
      if (messages.isEmpty) report.write("  - None");
      for (var msg in messages) {
        report.write("$msg\n");
      }
    });
    return report.toString();
  }

  void _sourceConfigurationFields(Source source) {
    const fieldName = "Configuration Field";
    final config = source.configurationFields;

    if (config.name.isEmpty) {
      _addError(fieldName, "'name' is missing or empty.");
    }

    try {
      final uri = Uri.parse(config.mainUrl);
      if (!uri.isAbsolute) {
        _addError(
          fieldName,
          "'mainUrl' is not a valid absolute URL (e.g., must start with http:// or https://).",
        );
      }
    } catch (_) {
      _addError(fieldName, "'mainUrl' is malformed.");
    }

    if (config.searchUrl.isEmpty || config.searchUrl == Placeholders.emptyString) {
      _addError(fieldName, "'searchUrl' is missing or empty.");
    }
  }

  void _sourceSearchFields(Source source) {
    const fieldName = "Search Field";
    final search = source.searchFields;

    if (search.serieUrlCSSClass.isEmpty || search.serieUrlCSSClass == Placeholders.emptyString) {
      _addError(fieldName, "'serieUrlCSSClass' is missing. Cannot link search results.");
    }

    if (search.serieImageCSSClass.isEmpty ||
        search.serieImageCSSClass == Placeholders.emptyString) {
      _addWarning(
        fieldName,
        "'serieImageCSSClass' is missing. Search results will not display images.",
      );
    }
  }

  void _sourceSeriesFields(Source source) {
    const fieldName = "Series Field";
    final serie = source.serieFields;

    if (serie.nameCSSClass.isEmpty || serie.nameCSSClass == Placeholders.emptyString) {
      _addError(fieldName, "'nameCSSClass' is missing. Cannot extract series names during search.");
    }

    if (serie.descriptionCSSClass.isEmpty ||
        serie.descriptionCSSClass == Placeholders.emptyString) {
      _addWarning(
        fieldName,
        "'descriptionCSSClass' is missing. Series descriptions cannot be fetched.",
      );
    }
  }

  void _sourceChaptersFields(Source source) {
    const fieldName = "Chapters Field";
    final chapters = source.chaptersFields;

    if (chapters.identifiersCSSClass.isEmpty ||
        chapters.identifiersCSSClass == Placeholders.emptyString) {
      _addError(fieldName, "'identifiersCSSClass' is missing. Cannot list chapter names.");
    }

    if (chapters.urlsCSSClass.isEmpty || chapters.urlsCSSClass == Placeholders.emptyString) {
      _addError(fieldName, "'urlsCSSClass' is missing. Cannot list chapter URLs.");
    }
  }

  void _sourceVideosFields(Source source) {
    const fieldName = "Videos Field";
    final videos = source.videosFields;

    if (videos.videosUrlLocation == ChaptersVideosUrlLocation.empty) {
      _addError(fieldName, "'videosUrlLocation' is not defined. Cannot locate video data.");
    }

    if (videos.videosUrlParseMode != ChaptersVideosUrlParseModes.empty) {
      if (videos.jsonListStartPattern.isEmpty || videos.jsonListEndPattern.isEmpty) {
        _addError(
          fieldName,
          "JSON parse mode is selected, but 'jsonListStartPattern' or 'jsonListEndPattern' is missing.",
        );
      }
      if (videos.jsonListKeyForVideosUrl.isEmpty ||
          videos.jsonListKeyForVideosUrl == Placeholders.emptyString) {
        _addError(
          fieldName,
          "JSON parse mode is selected, but 'jsonListKeyForVideosUrl' is missing.",
        );
      }
    } else {
      _addError(fieldName, "'videosUrlParseMode'for videos is not defined.");
    }
  }
}
