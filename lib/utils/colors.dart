import 'package:flutter/material.dart';

// Define your custom colors
const Color accentColor = Color.fromRGBO(252, 153, 82, 1); // rgb(252, 153, 82)
const Color secondaryColor = Color.fromRGBO(8, 8, 12, 1); // rgb(8, 8, 12)
const Color primaryColor = Color.fromRGBO(250, 250, 250, 1); // White color
const Color lightContainer = Color.fromRGBO(240, 240, 240, 1.0);
// Light theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: accentColor,
    onPrimary: secondaryColor,
  ),
  scaffoldBackgroundColor: primaryColor,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: secondaryColor),
    bodyMedium: TextStyle(color: secondaryColor),
  ),
  appBarTheme: AppBarTheme(
    color: primaryColor,
    iconTheme: IconThemeData(color: accentColor),
    toolbarTextStyle: TextTheme(
      titleLarge: TextStyle(color: secondaryColor, fontSize: 20),
    ).bodyMedium,
    titleTextStyle: TextTheme(
      titleLarge: TextStyle(color: secondaryColor, fontSize: 20),
    ).titleLarge,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: accentColor,
    textTheme: ButtonTextTheme.primary,
  ),
);

// Dark theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: secondaryColor,
  colorScheme: ColorScheme.dark(
    primary: secondaryColor,
    secondary: accentColor,
    onPrimary: primaryColor,
  ),
  scaffoldBackgroundColor: secondaryColor,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: primaryColor),
    bodyMedium: TextStyle(color: primaryColor),
  ),
  appBarTheme: AppBarTheme(
    color: secondaryColor,
    iconTheme: IconThemeData(color: accentColor),
    toolbarTextStyle: TextTheme(
      titleLarge: TextStyle(color: primaryColor, fontSize: 20),
    ).bodyMedium,
    titleTextStyle: TextTheme(
      titleLarge: TextStyle(color: primaryColor, fontSize: 20),
    ).titleLarge,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: accentColor,
    textTheme: ButtonTextTheme.primary,
  ),
);
