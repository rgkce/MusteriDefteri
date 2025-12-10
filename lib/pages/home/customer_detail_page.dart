import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  // ----------------------------- YENİ İŞLEM EKLEME DİYALOĞU -----------------------------
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
                style: AppStyles.caption.copyWith(fontWeight: FontWeight.bold),
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
                    isDark
                        ? AppColors.lightSecondary
                        : AppColors.lightSecondary.withOpacity(0.7),
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

  // ----------------------------- DÜZENLEME DİYALOĞU -----------------------------
  void _showEditTransactionDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleController = TextEditingController(text: data['title']);
    final descController = TextEditingController(text: data['description']);
    final priceController = TextEditingController(
      text: data['price'].toString(),
    );

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
            "İşlemi Düzenle",
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
                style: AppStyles.caption.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await doc.reference.update({
                  'title': titleController.text,
                  'description': descController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark
                        ? AppColors.lightSecondary
                        : AppColors.lightSecondary.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              child: const Text(
                "Güncelle",
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

  // ----------------------------- TEXTFIELD WIDGET -----------------------------
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
          hintStyle: TextStyle(
            color:
                isDark
                    ? AppColors.darkText.withOpacity(0.7)
                    : AppColors.lightText.withOpacity(0.7),
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
        ),
      ),
    );
  }

  // ----------------------------- BUILD -----------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Minimal Theme Colors
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    // final primaryColor =
    //     isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          widget.customer["name"],
          style: AppStyles.headline2.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- INFO HEADER ----------
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: screenWidth * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${widget.customer["phone"]}",
                    style: AppStyles.bodyText.copyWith(
                      color: textColor.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- SEARCH ----------
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 10,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                decoration: InputDecoration(
                  hintText: "İşlem ara...",
                  hintStyle: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // ---------- TRANSACTION LIST ----------
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: textColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Henüz işlem yok.",
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final query = _searchController.text.toLowerCase();
                        return data['title'].toString().toLowerCase().contains(
                              query,
                            ) ||
                            data['description']
                                .toString()
                                .toLowerCase()
                                .contains(query);
                      }).toList();

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 10,
                    ),
                    itemCount: docs.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final date = (data['date'] as Timestamp).toDate();

                      return Slidable(
                        key: ValueKey(doc.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.4,
                          children: [
                            SlidableAction(
                              onPressed: (_) => _showEditTransactionDialog(doc),
                              backgroundColor: AppColors.edit,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                            ),
                            SlidableAction(
                              onPressed: (_) => doc.reference.delete(),
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                                      style: AppStyles.bodyText.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'],
                                      style: AppStyles.caption.copyWith(
                                        color:
                                            isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${date.day}.${date.month}.${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                      style: AppStyles.caption.copyWith(
                                        fontSize: 12,
                                        color:
                                            isDark
                                                ? AppColors.lightSurface
                                                : AppColors.darkSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${data['price']} ₺",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color:
                                      isDark
                                          ? AppColors.darkAccent
                                          : AppColors
                                              .lightAccent, // Teal/Greenish
                                ),
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
