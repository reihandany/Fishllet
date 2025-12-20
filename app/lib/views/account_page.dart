// lib/views/account_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../config/app_theme.dart';
import 'login_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ACCOUNT PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman profil akun user dengan pengaturan
/// Tampilkan halaman khusus untuk guest user
class AccountPage extends StatelessWidget {
  AccountPage({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 12),
            Text('Logout Confirmation'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?\nYour cart will be cleared.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
              Get.snackbar(
                'Logged Out',
                'You have been logged out successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                icon: const Icon(Icons.logout, color: Colors.white),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.buildGradientAppBar(
        context: context,
        title: Text(
          'Akun Saya',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        // Jika guest, tampilkan halaman khusus guest
        if (authController.isGuest.value) {
          return _buildGuestView();
        }

        // Jika user normal, tampilkan profil normal
        return _buildNormalProfileView();
      }),
    );
  }

  // Guest View - Halaman khusus untuk guest
  Widget _buildGuestView() {
    return Builder(
      builder: (context) {
        final isDark = AppColors.isDark(context);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off,
                    size: 80,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Profil Tidak Tersedia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkText
                        : const Color(0xFF2380c4),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  'Anda harus login atau register terlebih dahulu untuk mengakses profil dan fitur lengkap lainnya.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.offAll(() => LoginPage());
                    },
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Login / Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2380c4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Anda masuk sebagai Guest. Fitur checkout & payment tidak tersedia.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Normal Profile View
  Widget _buildNormalProfileView() {
    return Builder(
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header dengan warna konsisten
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppGradients.getGradient(context),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Obx(() {
                          final username = authController.username.value;
                          final initial = username.isNotEmpty
                              ? username[0].toUpperCase()
                              : 'U';
                          return Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B8FCC),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Username
                    Obx(
                      () => Text(
                        authController.username.value,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Settings Section
              _buildSectionTitle('Pengaturan'),
              _buildSettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                trailing: Obx(
                  () => Switch(
                    value: themeController.isDark.value,
                    onChanged: (value) => themeController.toggleTheme(),
                    activeThumbColor: const Color(0xFF3B8FCC),
                  ),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notifications toggle
                  },
                  activeThumbColor: const Color(0xFF3B8FCC),
                ),
              ),
              const Divider(),

              // Account Section
              _buildSectionTitle('Akun'),
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Edit profile feature will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF2380c4),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Change password feature will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF2380c4),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
              ),
              const Divider(),

              // About Section
              _buildSectionTitle('Tentang'),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'About Fishllet',
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('About Fishllet'),
                      content: const Text(
                        'Fishllet - Your Favorite Fish Store\n\nVersion 1.0.0\n\nDeveloped with ❤️ using Flutter',
                        style: TextStyle(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  Get.snackbar(
                    'Privacy Policy',
                    'Your data is safe with us',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF2380c4),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'Terms & Conditions',
                onTap: () {
                  Get.snackbar(
                    'Terms & Conditions',
                    'Please read our terms carefully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF2380c4),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
              ),
              const Divider(),

              // Logout Section
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutConfirmation,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.isDark(context)
                    ? AppColors.secondary
                    : const Color(0xFF3B8FCC),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = AppColors.isDark(context);
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B8FCC).withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.secondary : const Color(0xFF3B8FCC),
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.text(context),
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey,
              ),
          onTap: onTap,
        );
      },
    );
  }
}
