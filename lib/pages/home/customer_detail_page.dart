import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';

class CustomerDetailPage extends StatefulWidget {
  final Map<String, dynamic> customer;
  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  late CollectionReference transactionsRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      transactionsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('customers')
          .doc(widget.customer['id'])
          .collection('transactions');
    }
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          title: Text(
            "Yeni İşlem Ekle",
            style: AppStyles.headline2.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  titleController,
                  "İşlem Adı",
                  isDark,
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.06,
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildTextField(
                  descController,
                  "İşlem Detayı",
                  isDark,
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.06,
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildTextField(
                  priceController,
                  "Ücret (₺)",
                  isDark,
                  keyboard: TextInputType.number,
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.06,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "İptal",
                style: AppStyles.caption.copyWith(
                  color: AppColors.lightAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descController.text.isEmpty ||
                    priceController.text.isEmpty)
                  return;

                await transactionsRef.add({
                  'title': titleController.text,
                  'description': descController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'date': DateTime.now(),
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.lightSecondary : AppColors.darkSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              child: const Text(
                "Ekle",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isDark, {
    TextInputType keyboard = TextInputType.text,
    double width = 300,
    double height = 50,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color:
                isDark
                    ? AppColors.darkText.withOpacity(0.7)
                    : AppColors.lightText.withOpacity(0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
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
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color:
                                isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                        Expanded(
                          child: Text(
                            widget.customer["name"],
                            textAlign: TextAlign.center,
                            style: AppStyles.headline1.copyWith(
                              color:
                                  isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      "Telefon: ${widget.customer["phone"]}",
                      style: AppStyles.bodyText.copyWith(
                        color:
                            isDark
                                ? AppColors.darkSurface.withOpacity(0.8)
                                : AppColors.lightSurface.withOpacity(0.8),
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.01,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.lightText.withOpacity(0.5)
                            : AppColors.darkText.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(color: AppColors.darkSurface),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      color:
                          isDark ? AppColors.lightSurface : AppColors.lightText,
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                      hintText: "İşlem ara...",
                      hintStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.lightSurface
                                : AppColors.lightText,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color:
                            isDark
                                ? AppColors.lightSurface
                                : AppColors.lightText,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      transactionsRef
                          .orderBy('date', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Henüz işlem yok."));
                    }

                    final docs =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final query = _searchController.text.toLowerCase();
                          return data['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query) ||
                              data['description']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query);
                        }).toList();

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final date = (data['date'] as Timestamp).toDate();

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.007,
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.lightText.withOpacity(0.8)
                                    : AppColors.darkText.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.04,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                        color:
                                            isDark
                                                ? AppColors.darkPrimary
                                                : AppColors.lightPrimary,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      data['description'],
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                        fontSize: screenWidth * 0.038,
                                      ),
                                    ),
                                    Text(
                                      "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                        fontSize: screenWidth * 0.033,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${data['price']} ₺",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.045,
                                  color:
                                      isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            isDark ? AppColors.lightSecondary : AppColors.darkSecondary,
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
