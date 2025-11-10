import 'package:flutter/material.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';
import 'package:musteridefterim/navigation/navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    VoidCallback onConfirm,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.lightText : AppColors.darkText,
            title: Text(
              title,
              style: AppStyles.headline2.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 22,
              ),
            ),
            content: Text(
              "Bu işlemi yapmak istediğinize emin misiniz?",
              style: AppStyles.headline2.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Hayır",
                  style: AppStyles.caption.copyWith(
                    color: isDark ? AppColors.darkAccent : AppColors.darkAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(
                  "Evet",
                  style: AppStyles.caption.copyWith(
                    color:
                        isDark
                            ? AppColors.darkSecondary
                            : AppColors.darkSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [AppColors.darkPrimary, AppColors.darkAccent]
                      : [AppColors.lightPrimary, AppColors.lightAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png'),
                Text(
                  "Rümeysa Gökçe",
                  style: AppStyles.headline1.copyWith(
                    color: AppColors.darkText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "gokce@example.com",
                  style: AppStyles.bodyText.copyWith(
                    color: AppColors.darkText,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 25),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildButton(
                          context,
                          title: "Şifre Değiştir",
                          icon: Icons.lock_open,
                          color:
                              isDark
                                  ? AppColors.lightSecondary
                                  : AppColors.darkSecondary.withOpacity(0.8),
                          onPressed:
                              () => _showConfirmationDialog(
                                context,
                                "Şifre Değiştir",
                                () {
                                  Navigator.pushNamed(
                                    context,
                                    '/change-password',
                                  );
                                },
                              ),
                        ),
                        SizedBox(height: 15),
                        _buildButton(
                          context,
                          title: "Çıkış Yap",
                          icon: Icons.logout,
                          color:
                              isDark
                                  ? AppColors.lightPrimary
                                  : AppColors.darkPrimary.withOpacity(0.8),
                          onPressed:
                              () => _showConfirmationDialog(
                                context,
                                "Çıkış Yap",
                                () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                              ),
                        ),
                        SizedBox(height: 15),
                        _buildButton(
                          context,
                          title: "Hesabı Sil",
                          icon: Icons.delete_forever,
                          color:
                              isDark
                                  ? AppColors.lightAccent
                                  : AppColors.darkAccent.withOpacity(0.8),
                          onPressed:
                              () => _showConfirmationDialog(
                                context,
                                "Hesabı Sil",
                                () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/signup',
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const NavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.darkText, size: 25),
        label: Text(
          title,
          style: AppStyles.caption.copyWith(
            color: AppColors.darkText,
            fontSize: 20,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
