import 'package:alert_system_for_gaps/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/color_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alert system for GAPS',
      theme: ThemeData.dark().copyWith(
      appBarTheme: const AppBarTheme(backgroundColor: bgColor, elevation: 0),
      scaffoldBackgroundColor: bgColor,
      primaryColor: greenColor,
      dialogBackgroundColor: secondaryColor,
      buttonTheme: const ButtonThemeData(
        buttonColor: greenColor
      ) ,
      textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: Colors.white),
      canvasColor: secondaryColor,
    ),
      home: Login(title: "Welcome to the Admin & Dashboard Panel"),
    );
  }
}
