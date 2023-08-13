import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static Color _iconColor = Colors.blueAccent.shade200;

  static const Color _lightPrimaryColor = Colors.lightGreen;
  static const Color _lightScaffoldBackgroundColor = Color(0XFFc8e6c9);
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _lightPrimaryVariantColor = Color(0XFFE0E0E0);
  static const Color _lightSecondaryColor = Colors.green;
  static const Color _lightOnPrimaryColor = Colors.black;

  static const Color _darkPrimaryColor = Color(0XFF0F0F0F);
  static const Color _darkScaffoldBackgroundColor = Colors.black;
  static const Color _darkBackgroundColor = Color(0XFF0F0F0F);
  static const Color _darkPrimaryVariantColor = Color(0XFF1F1F1F);
  static const Color _darkSecondaryColor = Colors.lightGreen;
  static const Color _darkOnPrimaryColor = Colors.white;

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: _lightScaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      color: _lightScaffoldBackgroundColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      toolbarTextStyle: _lightTextTheme.bodyMedium,
      titleTextStyle: _lightTextTheme.titleLarge,
    ),
    primaryColor: Colors.lightGreen,
    iconTheme: IconThemeData(
      color: _iconColor,
    ),
    textTheme: _lightTextTheme,
    canvasColor: Colors.transparent,
    unselectedWidgetColor: _lightPrimaryVariantColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      background: _lightBackgroundColor,
      secondary: _iconColor,
      onPrimary: _lightOnPrimaryColor,
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: _darkScaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      color: _darkScaffoldBackgroundColor,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
      toolbarTextStyle: _darkTextTheme.bodyMedium,
      titleTextStyle: _darkTextTheme.titleLarge,
    ),
    primaryColor: Colors.lightGreen,
    iconTheme: IconThemeData(
      color: _iconColor,
    ),
    textTheme: _darkTextTheme,
    canvasColor: Colors.transparent,
    unselectedWidgetColor: _darkPrimaryVariantColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkPrimaryVariantColor),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _iconColor,
      background: _darkBackgroundColor,
      onPrimary: _darkOnPrimaryColor,
    ),
  );

  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: _lightHeadline1TextStyle,
    displayMedium: _lightHeadline2TextStyle,
    displaySmall: _lightHeadline3TextStyle,
    headlineMedium: _lightHeadline4TextStyle,
    headlineSmall: _lightHeadline5TextStyle,
    titleLarge: _lightHeadline6TextStyle,
    bodyLarge: _lightBodyText1TextStyle,
    bodyMedium: _lightBodyText2TextStyle,
    labelLarge: _lightButtonTextStyle,
    titleMedium: _lightSubtitle1TextStyle,
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: _darkHeadline1TextStyle,
    displayMedium: _darkHeadline2TextStyle,
    displaySmall: _darkHeadline3TextStyle,
    headlineMedium: _darkHeadline4TextStyle,
    headlineSmall: _darkHeadline5TextStyle,
    titleLarge: _darkHeadline6TextStyle,
    bodyLarge: _darkBodyText1TextStyle,
    bodyMedium: _darkBodyText2TextStyle,
    labelLarge: _darkButtonTextStyle,
    titleMedium: _darkSubtitle1TextStyle,
  );

  static final TextStyle? _lightHeadline1TextStyle =
      ThemeData.light().textTheme.displayLarge?.copyWith(fontSize: 48);
  static final TextStyle? _lightHeadline2TextStyle =
      ThemeData.light().textTheme.displayMedium;
  static final TextStyle? _lightHeadline3TextStyle =
      ThemeData.light().textTheme.displaySmall;
  static final TextStyle? _lightHeadline4TextStyle =
      ThemeData.light().textTheme.headlineMedium?.copyWith(fontSize: 25);
  static final TextStyle? _lightHeadline5TextStyle =
      ThemeData.light().textTheme.headlineSmall;
  static final TextStyle? _lightHeadline6TextStyle =
      ThemeData.light().textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          );
  static final TextStyle? _lightBodyText1TextStyle =
      ThemeData.light().textTheme.bodyLarge;
  static final TextStyle? _lightBodyText2TextStyle =
      ThemeData.light().textTheme.bodyMedium;
  static final TextStyle? _lightSubtitle1TextStyle =
      ThemeData.light().textTheme.titleMedium;
  static final TextStyle? _lightButtonTextStyle =
      ThemeData.light().textTheme.labelLarge?.copyWith(color: _lightSecondaryColor);

  static final TextStyle? _darkHeadline1TextStyle =
      ThemeData.dark().textTheme.displayLarge?.copyWith(fontSize: 48);
  static final TextStyle? _darkHeadline2TextStyle =
      ThemeData.dark().textTheme.displayMedium;
  static final TextStyle? _darkHeadline3TextStyle =
      ThemeData.dark().textTheme.displaySmall;
  static final TextStyle? _darkHeadline4TextStyle =
      ThemeData.dark().textTheme.headlineMedium?.copyWith(fontSize: 25);
  static final TextStyle? _darkHeadline5TextStyle =
      ThemeData.dark().textTheme.headlineSmall;
  static final TextStyle? _darkHeadline6TextStyle =
      ThemeData.dark().textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          );
  static final TextStyle? _darkBodyText1TextStyle =
      ThemeData.dark().textTheme.bodyLarge;
  static final TextStyle? _darkBodyText2TextStyle =
      ThemeData.dark().textTheme.bodyMedium;
  static final TextStyle? _darkSubtitle1TextStyle =
      ThemeData.dark().textTheme.titleMedium;
  static final TextStyle? _darkButtonTextStyle =
      ThemeData.dark().textTheme.labelLarge?.copyWith(color: _darkSecondaryColor);
}
