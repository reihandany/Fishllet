// lib/controllers/theme_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final RxBool isDark = false.obs;
  final String _key = "isDarkTheme";

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool(_key) ?? false;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = !isDark.value;
    await prefs.setBool(_key, isDark.value);
  }
}