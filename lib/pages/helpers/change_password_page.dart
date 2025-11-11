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
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: AppColors.darkPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 250, height: 250),
                Text(
                  "Şifreyi Değiştir",
                  style: AppStyles.headline1.copyWith(
                    color: surface,
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
                  icon: Icons.lock,
                  color: textColor,
                  surface: surface,
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
                  surface: surface,
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
                  surface: surface,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: surface,
                      foregroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _changePassword,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                              "Şifreyi Güncelle",
                              style: AppStyles.caption.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Geri Dön",
                    style: TextStyle(
                      color: surface.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: color.withOpacity(0.6)),
        filled: true,
        fillColor: surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: color),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: color.withOpacity(0.9),
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
