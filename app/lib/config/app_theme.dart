// lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3B8FCC);
  static const Color secondary = Color(0xFF5AA5D6);
  static const Color accent = Color(
    0xFF3B8FCC,
  ); // Use primary as accent for consistency

  // Dark mode colors - improved contrast with dark blue theme
  static const Color darkBackground = Color(0xFF0D1B2A);
  static const Color darkSurface = Color(0xFF1B263B);
  static const Color darkCard = Color(0xFF243447);
  static const Color darkCardElevated = Color(0xFF2C3E50);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF3B4A5A);

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
  // Light mode gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dark mode gradient - dark blue theme
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF0D1B2A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Get gradient based on theme
  static LinearGradient getGradient(BuildContext context) {
    return AppColors.isDark(context) ? darkGradient : primaryGradient;
  }
}

class AppStyles {
  static PreferredSizeWidget buildGradientAppBar({
    required Widget title,
    List<Widget>? actions,
    double height = 60,
    bool centerTitle = true,
    BuildContext? context,
  }) {
    // If context is provided, use adaptive gradient
    if (context != null) {
      final isDark = AppColors.isDark(context);
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
          decoration: BoxDecoration(
            gradient: isDark
                ? AppGradients.darkGradient
                : AppGradients.primaryGradient,
          ),
        ),
      );
    }

    // Fallback to default (light mode) gradient
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
        decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
      ),
    );
  }
}
