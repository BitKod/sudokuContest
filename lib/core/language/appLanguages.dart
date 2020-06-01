
import 'package:sudokuContest/core/constants/app_constants.dart';

enum AppLanguage {
 English, Turkish
}

/// Returns enum value name without enum class name.
String enumName(AppLanguage anyEnum) {
 return anyEnum.toString().split('.')[1];
}

final appLanguageData = {
 AppLanguage.English : AppConstants.EN_LOCALE,
 AppLanguage.Turkish : AppConstants.TR_LOCALE,
};