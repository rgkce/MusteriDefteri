import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isPolicyAccepted = false;

  // -----------------------------
  //  E-POSTA VALIDASYONU
  // -----------------------------
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@(?:gmail|hotmail|outlook|yahoo|icloud)\.com$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _showPolicyDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Text(
            "Gizlilik Politikası, Kullanım Koşulları ve İzinler",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 350,
            child: SingleChildScrollView(
              child: Text("""
**Gizlilik Politikası**
Bu uygulama, kullanıcı verilerini yalnızca hizmetlerin doğru çalışabilmesi amacıyla toplar. Veriler asla üçüncü taraflarla paylaşılmaz.

**Kullanım Koşulları**
Uygulamayı kullanarak sağlanan hizmet şartlarını kabul etmiş olursunuz. Kullanıcı bilgilerin doğruluğundan kendisi sorumludur.

**İzinler**
Uygulama düzgün çalışabilmek için aşağıdaki izinleri kullanabilir:
• İnternet erişimi
• Bildirim alma
• Cihaz bilgisi okuma

Uygulamayı kullanarak bu izinleri kabul etmiş olursunuz.
                """, style: TextStyle(color: textColor, height: 1.4)),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Kapat"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------
  //  KAYIT İŞLEMİ
  // -----------------------------
  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Lütfen tüm alanları doldurun.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError(
        "Lütfen geçerli bir e-posta adresi girin. "
        "(Ör: @gmail.com / @hotmail.com)",
      );
      return;
    }

    if (password.length < 6) {
      _showError("Şifre en az 6 karakter olmalıdır.");
      return;
    }

    if (password != confirmPassword) {
      _showError('Şifreler uyuşmuyor.');
      return;
    }

    if (!_isPolicyAccepted) {
      _showError('Devam etmek için politikayı kabul etmelisiniz.');
      return;
    }

    try {
      setState(() => _isLoading = true);

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Kayıt başarısız oldu.');
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Minimal design colors
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png", width: 100, height: 100),
              const SizedBox(height: 16),
              Text(
                "Kayıt Ol",
                style: AppStyles.headline1.copyWith(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Yeni bir hesap oluşturun",
                style: AppStyles.caption.copyWith(
                  color:
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _nameController,
                hint: "Ad Soyad",
                icon: Icons.person_outline,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                hint: "E-posta",
                icon: Icons.email_outlined,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                hint: "Şifre",
                icon: Icons.lock_outline,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
                obscure: _obscurePassword,
                onToggleObscure: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _confirmPasswordController,
                hint: "Şifre Tekrar",
                icon: Icons.lock_outline,
                color: textColor,
                surface: surfaceColor,
                isDark: isDark,
                obscure: _obscureConfirmPassword,
                onToggleObscure: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _isPolicyAccepted,
                    activeColor:
                        isDark ? AppColors.darkAccent : AppColors.lightPrimary,
                    onChanged: (value) {
                      setState(() => _isPolicyAccepted = value ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showPolicyDialog,
                      child: Text(
                        "Gizlilik Politikası, Kullanım Koşulları ve İzinleri okudum, kabul ediyorum.",
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isPolicyAccepted ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        isDark ? AppColors.darkAccent : AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0, // Flat
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "Kayıt Ol",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Zaten hesabın var mı?",
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkAccent
                                : AppColors.lightPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    required Color surface,
    required bool isDark,
    bool obscure = false,
    VoidCallback? onToggleObscure,
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
        suffixIcon:
            onToggleObscure != null
                ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                  onPressed: onToggleObscure,
                )
                : null,
      ),
    );
  }
}
