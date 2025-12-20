// lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3B8FCC);
  static const Color secondary = Color(0xFF5AA5D6);
  static const Color accent = Color(0xFF3B8FCC); // Use primary as accent for consistency
  
  // Dark mode colors - improved contrast
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkCardElevated = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF3D3D3D);
  
  // Light mode colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  
  // Adaptive colors based on theme
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : lightBackground;
  }
  
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSurface 
        : lightSurface;
  }
  
  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCard 
        : lightCard;
  }
  
  static Color cardElevated(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCardElevated 
        : lightCard;
  }
  
  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkText 
        : lightText;
  }
  
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextSecondary 
        : lightTextSecondary;
  }
  
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkDivider 
        : Colors.grey.shade200;
  }
  
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppStyles {
  static AppBar buildGradientAppBar({
    required Widget title,
    List<Widget>? actions,
    double height = 60,
    bool centerTitle = true,
  }) {
    return AppBar(
      toolbarHeight: height,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: Colors.white),
      surfaceTintColor: Colors.transparent,
      title: title,
      actions: actions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryGradient,
        ),
      ),
    );
  }
}
