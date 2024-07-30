import 'package:alert_system_for_gaps/firebase_options.dart';
import 'package:alert_system_for_gaps/screens/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/color_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: Login(title: "Alert System For GAPS"),
    );
  }
}
