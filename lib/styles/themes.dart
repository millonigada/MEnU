import 'package:flutter/material.dart';
import 'colors.dart';

BoxShadow containerShadow = BoxShadow(
  color: Colors.grey[350],
  offset: const Offset(
    0.0,
    0.0,
  ),
  blurRadius: 7.0,
  spreadRadius: 2.0,
);

ThemeData myTheme = ThemeData(

  primarySwatch: createMaterialColor(primaryColorLight),
  primaryColor: primaryColorLight,
  primaryColorLight: primaryColorLightFaded,
  backgroundColor: greyBackgroundColor,
  accentColor: secondaryColorLight,
  scaffoldBackgroundColor: whiteColor,
  hintColor: blackColor,
  cardColor: whiteColor,
  disabledColor: greyLightModeColor,

  iconTheme: IconThemeData(
      color: primaryColorLight
  ),

  textTheme: TextTheme(
    //for button text
      headline1: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18),

      //for gold headings
      headline2: TextStyle(color: primaryColorLight, fontWeight: FontWeight.w500, fontSize: 18),

      //for other text and prices
      headline3: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 18),

      //for normal text
      headline4: TextStyle(color: Colors.black87, fontWeight: FontWeight.w400, fontSize: 14),

      //for purple text
      headline5: TextStyle(color: primaryColorLight, fontWeight: FontWeight.w400, fontSize: 16, fontStyle: FontStyle.italic),

      //for drawer tiles
      headline6: TextStyle(color: Colors.black87, fontWeight: FontWeight.w400, fontSize: 16)
  ),

  // textButtonTheme: TextButtonThemeData(
  //   style: ButtonStyle(
  //     backgroundColor: MaterialStateProperty.all<Color>(secondaryColorLight)
  //   )
  // )

);

BoxDecoration signUpTextFieldBoxDecor = BoxDecoration(
  color: signUpTextFieldColor,
  borderRadius: BorderRadius.all(Radius.circular(6)),
);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

List<BoxShadow> applyBoxShadow(BuildContext context){
  return [containerShadow];
}
