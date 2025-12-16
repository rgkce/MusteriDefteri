import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';
import 'package:musteridefterim/navigation/navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    // final surfaceColor =
    //     isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            "Profil",
            style: AppStyles.headline2.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 1. Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightAccent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          child: Text(
                            (user?.email?.isNotEmpty == true)
                                ? user!.email![0].toUpperCase()
                                : "U",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? AppColors.darkAccent
                                      : AppColors.lightAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.email ?? "Kullanıcı",
                        style: AppStyles.headline2.copyWith(
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Ücretsiz Üye",
                          style: AppStyles.caption.copyWith(
                            color: textColor.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 2. Settings Sections
                _buildSectionHeader(context, "HESAP AYARLARI"),
                _buildSettingsGroup(context, isDark, [
                  _SettingsItem(
                    icon: Icons.lock_outline_rounded,
                    title: "Şifre Değiştir",
                    onTap:
                        () => Navigator.pushNamed(context, '/change-password'),
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "OTURUM"),
                _buildSettingsGroup(context, isDark, [
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    title: "Çıkış Yap",
                    onTap:
                        () => _showConfirmationDialog(
                          context,
                          "Çıkış Yap",
                          "Çıkış yapmak istediğinize emin misiniz?",
                          () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                          isDark,
                        ),
                  ),
                  _SettingsItem(
                    icon: Icons.delete_forever_rounded,
                    title: "Hesabı Sil",
                    isDestructive: true,
                    onTap:
                        () => _showConfirmationDialog(
                          context,
                          "Hesabı Sil",
                          "Hesabınızı kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
                          () async {
                            try {
                              await FirebaseAuth.instance.currentUser?.delete();
                              Navigator.pushReplacementNamed(
                                context,
                                '/signup',
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Hata: ${e.toString()}"),
                                ),
                              );
                            }
                          },
                          isDark,
                        ),
                  ),
                ]),

                const SizedBox(height: 40),

                // 3. Version Footer
                Center(
                  child: Text(
                    "v1.0.0",
                    style: AppStyles.caption.copyWith(
                      color: textColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const NavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color:
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    bool isDark,
    List<_SettingsItem> items,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        item.isDestructive
                            ? AppColors.error.withOpacity(0.1)
                            : (isDark
                                ? Colors.white.withOpacity(0.05)
                                : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color:
                        item.isDestructive
                            ? AppColors.error
                            : (isDark
                                ? AppColors.darkText
                                : AppColors.lightText),
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        item.isDestructive
                            ? AppColors.error
                            : (isDark
                                ? AppColors.darkText
                                : AppColors.lightText),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 64, // Align with text
                  color:
                      isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: AppStyles.headline2.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            content: Text(
              content,
              style: AppStyles.bodyText.copyWith(
                color:
                    isDark
                        ? AppColors.darkText.withOpacity(0.7)
                        : AppColors.lightText.withOpacity(0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Vazgeç",
                  style: AppStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(
                  "Onayla",
                  style: AppStyles.caption.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
