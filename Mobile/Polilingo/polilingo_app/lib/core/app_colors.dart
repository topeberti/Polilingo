import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A237E); // Police Blue
  static const Color accentGold = Color(0xFFFFD700); // Energetic Gold
  static const Color goldLight = Color(0xFFFFF176);
  
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF121320);
  
  static const Color surfaceDark = Color(0xFF1E1F30);
  static const Color surfaceLight = Colors.white;
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  
  static const Color textPrimaryLight = Color(0xFF121320);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2B36A8),
      Color(0xFF1A227F),
      Color(0xFF0D1020),
    ],
    stops: [0.0, 0.6, 1.0],
  );
}
