import 'package:sudokuContest/core/theme/themeDark.dart';
import 'package:sudokuContest/core/theme/themeNormal.dart';

enum AppTheme {
 White, Dark
}

/// Returns enum value name without enum class name.
String enumName(AppTheme anyEnum) {
 return anyEnum.toString().split('.')[1];
}

final appThemeData = {
 AppTheme.White : myTheme,
 AppTheme.Dark : myThemeDark,
};