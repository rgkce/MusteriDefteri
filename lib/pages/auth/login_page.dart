import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Şifreyi göster/gizle için
  bool _obscureText = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        message = 'Şifre hatalı. Lütfen tekrar deneyin.';
      } else {
        message = 'Giriş başarısız: ${e.message}';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", width: 200, height: 200),
                const SizedBox(height: 10),
                Text(
                  "Hoş Geldiniz",
                  style: AppStyles.headline1.copyWith(
                    color: surface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "E-posta",
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    filled: true,
                    fillColor: surface.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email, color: textColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Şifre",
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    filled: true,
                    fillColor: surface.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: textColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: textColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Giriş Yap Button
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
                    onPressed: _isLoading ? null : _login,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                              "Giriş Yap",
                              style: AppStyles.caption.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 12),

                // Şifremi Unuttum
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/forgot");
                    },
                    child: Text(
                      "Şifremi Unuttum?",
                      style: AppStyles.bodyText.copyWith(
                        color: surface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Kayıt Ol Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hesabın yok mu?",
                      style: AppStyles.bodyText.copyWith(
                        color: surface,
                        fontSize: 17,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      },
                      child: Text(
                        "Kayıt Ol",
                        style: AppStyles.bodyText.copyWith(
                          color: surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
