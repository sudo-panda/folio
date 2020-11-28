import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static Color _iconColor = Colors.blueAccent.shade200;

  static const Color _lightPrimaryColor = Colors.lightGreen;
  static const Color _lightScaffoldBackgroundColor = Color(0XFFF0F7FF);
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
    backgroundColor: _lightBackgroundColor,
    appBarTheme: AppBarTheme(
      color: _lightScaffoldBackgroundColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      textTheme: _lightTextTheme,
    ),
    primaryColor: Colors.lightGreen,
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
    ),
    iconTheme: IconThemeData(
      color: _iconColor,
    ),
    textTheme: _lightTextTheme,
    canvasColor: Colors.transparent,
    buttonColor: _lightSecondaryColor,
    unselectedWidgetColor: _lightPrimaryVariantColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: _darkScaffoldBackgroundColor,
    backgroundColor: _darkBackgroundColor,
    appBarTheme: AppBarTheme(
      color: _darkScaffoldBackgroundColor,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
      textTheme: _darkTextTheme,
    ),
    primaryColor: Colors.lightGreen,
    colorScheme: ColorScheme.light(
      primary: _darkPrimaryColor,
      primaryVariant: _darkPrimaryVariantColor,
      secondary: _darkSecondaryColor,
      onPrimary: _darkOnPrimaryColor,
    ),
    iconTheme: IconThemeData(
      color: _iconColor,
    ),
    textTheme: _darkTextTheme,
    canvasColor: Colors.transparent,
    buttonColor: _darkSecondaryColor,
    unselectedWidgetColor: _darkPrimaryVariantColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkPrimaryVariantColor)),
    ),
  );

  static final TextTheme _lightTextTheme = TextTheme(
    headline1: _lightHeadline1TextStyle,
    headline2: _lightHeadline2TextStyle,
    headline3: _lightHeadline3TextStyle,
    headline4: _lightHeadline4TextStyle,
    headline5: _lightHeadline5TextStyle,
    headline6: _lightHeadline6TextStyle,
    bodyText1: _lightBodyText1TextStyle,
    bodyText2: _lightBodyText2TextStyle,
    button: _lightButtonTextStyle,
    subtitle1: _lightSubtitle1TextStyle,
  );

  static final TextTheme _darkTextTheme = TextTheme(
    headline1: _darkHeadline1TextStyle,
    headline2: _darkHeadline2TextStyle,
    headline3: _darkHeadline3TextStyle,
    headline4: _darkHeadline4TextStyle,
    headline5: _darkHeadline5TextStyle,
    headline6: _darkHeadline6TextStyle,
    bodyText1: _darkBodyText1TextStyle,
    bodyText2: _darkBodyText2TextStyle,
    button: _darkButtonTextStyle,
    subtitle1: _darkSubtitle1TextStyle,
  );

  static final TextStyle _lightHeadline1TextStyle =
      ThemeData.light().textTheme.headline1.copyWith(fontSize: 48);
  static final TextStyle _lightHeadline2TextStyle =
      ThemeData.light().textTheme.headline2;
  static final TextStyle _lightHeadline3TextStyle =
      ThemeData.light().textTheme.headline3;
  static final TextStyle _lightHeadline4TextStyle =
      ThemeData.light().textTheme.headline4.copyWith(fontSize: 25);
  static final TextStyle _lightHeadline5TextStyle =
      ThemeData.light().textTheme.headline5;
  static final TextStyle _lightHeadline6TextStyle =
      ThemeData.light().textTheme.headline6.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          );
  static final TextStyle _lightBodyText1TextStyle =
      ThemeData.light().textTheme.bodyText1;
  static final TextStyle _lightBodyText2TextStyle =
      ThemeData.light().textTheme.bodyText2;
  static final TextStyle _lightSubtitle1TextStyle =
      ThemeData.light().textTheme.subtitle1;
  static final TextStyle _lightButtonTextStyle =
      ThemeData.light().textTheme.button.copyWith(color: _lightSecondaryColor);

  static final TextStyle _darkHeadline1TextStyle =
      ThemeData.dark().textTheme.headline1.copyWith(fontSize: 48);
  static final TextStyle _darkHeadline2TextStyle =
      ThemeData.dark().textTheme.headline2;
  static final TextStyle _darkHeadline3TextStyle =
      ThemeData.dark().textTheme.headline3;
  static final TextStyle _darkHeadline4TextStyle =
      ThemeData.dark().textTheme.headline4.copyWith(fontSize: 25);
  static final TextStyle _darkHeadline5TextStyle =
      ThemeData.dark().textTheme.headline5;
  static final TextStyle _darkHeadline6TextStyle =
      ThemeData.dark().textTheme.headline6.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          );
  static final TextStyle _darkBodyText1TextStyle =
      ThemeData.dark().textTheme.bodyText1;
  static final TextStyle _darkBodyText2TextStyle =
      ThemeData.dark().textTheme.bodyText2;
  static final TextStyle _darkSubtitle1TextStyle =
      ThemeData.dark().textTheme.subtitle1;
  static final TextStyle _darkButtonTextStyle =
      ThemeData.dark().textTheme.button.copyWith(color: _darkSecondaryColor);
}
