import 'package:flutter/material.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final newCustomer = {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "note": _noteController.text.trim(),
        "date": DateTime.now(),
      };

      debugPrint("Yeni müşteri: $newCustomer");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müşteri başarıyla eklendi!")),
      );

      Navigator.pop(context, newCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Başlık
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color:
                                        isDark
                                            ? AppColors.darkSurface
                                            : AppColors.lightSurface,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  },
                                ),
                                SizedBox(width: 25),
                                Text(
                                  "Yeni Müşteri Ekle",
                                  style: AppStyles.headline1.copyWith(
                                    color:
                                        isDark
                                            ? AppColors.darkSurface
                                            : AppColors.lightSurface,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Ad Soyad
                            _buildTextField(
                              label: "Ad Soyad",
                              controller: _nameController,
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Lütfen müşteri adını girin";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Telefon Numarası
                            _buildTextField(
                              label: "Telefon Numarası",
                              controller: _phoneController,
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Lütfen telefon numarası girin";
                                } else if (value.length < 10) {
                                  return "Geçerli bir numara girin";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // // Not
                            // _buildTextField(
                            //   label: "Not (Opsiyonel)",
                            //   controller: _noteController,
                            //   icon: Icons.note_alt,
                            //   maxLines: 3,
                            // ),
                            const Spacer(),

                            // Kaydet Butonu
                            ElevatedButton(
                              onPressed: _saveCustomer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 14,
                                ),
                                backgroundColor:
                                    isDark
                                        ? AppColors.darkSurface.withOpacity(0.9)
                                        : AppColors.lightSurface.withOpacity(
                                          0.9,
                                        ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                "Kaydet",
                                style: AppStyles.bodyText.copyWith(
                                  color:
                                      isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Ortak TextField yapısı
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? AppColors.darkSurface : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor:
            isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      ),
      validator: validator,
    );
  }
}
