import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundNavy = Color(0xFF142237); 
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F2038), 
      Color(0xFF142237), 
    ],
  );

  static const Color primaryGold = Color(0xFFD4AF37); 
  
  static const Color lightGold = Color(0xFFF3E5AB);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLightGray = Color(0xFFE0E0E0);
}