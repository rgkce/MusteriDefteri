import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("Yeni şifreler eşleşmiyor.");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final user = _auth.currentUser;
      if (user == null) {
        _showMessage("Kullanıcı oturumu bulunamadı.");
        return;
      }

      // Mevcut kullanıcı bilgilerini doğrula
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(cred);

      // Şifreyi Firebase Authentication'da güncelle
      await user.updatePassword(newPassword);

      // İsteğe bağlı: Firestore’da kullanıcı verisini de güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'password': newPassword,
      });

      _showMessage("Şifre başarıyla güncellendi ✅");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showMessage("Mevcut şifre yanlış.");
      } else if (e.code == 'weak-password') {
        _showMessage("Yeni şifre çok zayıf. Daha güçlü bir şifre belirleyin.");
      } else {
        _showMessage("Hata: ${e.message}");
      }
    } catch (e) {
      _showMessage("Bir hata oluştu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pushReplacementNamed(context, '/profile'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 200, height: 200),
              Text(
                "Şifreyi Değiştir",
                style: AppStyles.headline1.copyWith(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              _buildPasswordField(
                controller: _oldPasswordController,
                hint: "Mevcut Şifre",
                obscure: _obscureOld,
                toggleVisibility:
                    () => setState(() => _obscureOld = !_obscureOld),
                icon: Icons.lock_outline,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                hint: "Yeni Şifre",
                obscure: _obscureNew,
                toggleVisibility:
                    () => setState(() => _obscureNew = !_obscureNew),
                icon: Icons.lock_outline,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: "Yeni Şifre (Tekrar)",
                obscure: _obscureConfirm,
                toggleVisibility:
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icons.lock_outline,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        isDark ? AppColors.darkAccent : AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Şifreyi Güncelle",
                            style: AppStyles.caption.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggleVisibility,
    required IconData icon,
    required Color color,
    required Color surface,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: color),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(
          color:
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            width: 1.5,
          ),
        ),
        prefixIcon: Icon(
          icon,
          color:
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color:
                isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
