import 'dart:ui';

import 'package:flutter/material.dart';

Color getRoleColor(String? role) {
  if (role == "A") {
    return Colors.green;
  } else if (role == "B") {
    return Colors.red;
  } else if (role == "C") {
    return Colors.blueAccent;
  } else if (role == "D") {
    return Colors.amberAccent;
  } else if (role == "E") {
    return Colors.cyanAccent;
  } else if (role == "Business Analyst") {
    return Colors.deepPurpleAccent;
  } else if (role == "UI/UX Designer") {
    return Colors.indigoAccent;
  }
  return Colors.black38;
}
