import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';
import 'package:musteridefterim/navigation/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  String _sortOption = "Eklenme Sırası";
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCustomers();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userName = doc.data()?['name'] ?? "Kullanıcı";
        userEmail = doc.data()?['email'] ?? user.email ?? "E-posta Yok";
      });
    }
  }

  Future<void> _loadCustomers() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('customers')
            .orderBy('dateAdded', descending: true)
            .get();

    final data =
        snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc["name"],
            "phone": doc["phone"],
            "dateAdded": (doc["dateAdded"] as Timestamp).toDate(),
          };
        }).toList();

    setState(() {
      customers = data;
      filteredCustomers = List.from(customers);
    });
  }

  Future<void> _addOrUpdateCustomer({
    String? id,
    required String name,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('customers');

    // Aynı isimli müşteri var mı kontrol et
    final existing = await ref.where('name', isEqualTo: name.trim()).get();

    // Eğer yeni müşteri ekleniyorsa ve aynı isimli kayıt varsa uyar
    if (id == null && existing.docs.isNotEmpty) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              title: Text(
                "Aynı İsimde Müşteri Var",
                style: AppStyles.headline1.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                  fontSize: 20,
                ),
              ),
              content: Text(
                "Bu isimde zaten bir müşteri mevcut. Lütfen farklı bir isim girin.",
                style: AppStyles.caption.copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Tamam",
                    style: TextStyle(
                      color:
                          isDark ? AppColors.lightAccent : AppColors.darkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
      return; // Eklemeyi iptal et
    }

    // Güncelleme varsa direkt güncelle
    if (id != null) {
      await ref.doc(id).update({"name": name, "phone": phone});
    } else {
      await ref.add({
        "name": name.trim(),
        "phone": phone.trim(),
        "dateAdded": DateTime.now(),
      });
    }

    await _loadCustomers();
  }

  Future<void> _deleteCustomerFromFirebase(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('customers')
        .doc(id)
        .delete();
    await _loadCustomers();
  }

  void _sortCustomers() {
    setState(() {
      if (_sortOption == "A-Z") {
        filteredCustomers.sort(
          (a, b) => a["name"].toLowerCase().compareTo(b["name"].toLowerCase()),
        );
      } else if (_sortOption == "Zaman") {
        filteredCustomers.sort(
          (a, b) => a["dateAdded"].compareTo(b["dateAdded"]),
        );
      } else {
        filteredCustomers = List.from(customers);
      }
    });
  }

  void _filterCustomers(String query) {
    final search = query.toLowerCase().trim();

    List<Map<String, dynamic>> results =
        customers.where((customer) {
          final name = (customer["name"] ?? "").toString().toLowerCase();
          final phone = (customer["phone"] ?? "").toString().toLowerCase();
          return name.contains(search) || phone.contains(search);
        }).toList();

    setState(() {
      filteredCustomers = results;
    });

    // Sıralamayı filtre sonrası uygulamak için ayrı çağır
    _sortFilteredCustomers();
  }

  void _sortFilteredCustomers() {
    setState(() {
      if (_sortOption == "A-Z") {
        filteredCustomers.sort(
          (a, b) => a["name"].toString().toLowerCase().compareTo(
            b["name"].toString().toLowerCase(),
          ),
        );
      } else if (_sortOption == "Zaman") {
        filteredCustomers.sort(
          (a, b) => a["dateAdded"].compareTo(b["dateAdded"]),
        );
      }
    });
  }

  void _showAddOrEditCustomerPopup(
    BuildContext context,
    bool isDark, {
    Map<String, dynamic>? customer,
  }) {
    final TextEditingController nameController = TextEditingController(
      text: customer?["name"] ?? "",
    );
    final TextEditingController phoneController = TextEditingController(
      text: customer?["phone"] ?? "",
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppColors.darkSurface.withOpacity(0.95)
                      : AppColors.lightSurface.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  customer == null ? "Yeni Müşteri Ekle" : "Müşteri Güncelle",
                  style: AppStyles.headline1.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Müşteri Adı",
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.darkText.withOpacity(0.05)
                            : AppColors.lightText.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,

                  // ✅ sadece rakam ve max 11 karakter
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],

                  decoration: InputDecoration(
                    labelText: "Telefon Numarası",
                    filled: true,
                    fillColor:
                        isDark
                            ? AppColors.darkText.withOpacity(0.05)
                            : AppColors.lightText.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      customer == null ? Icons.person_add_alt_1 : Icons.edit,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark
                              ? AppColors.lightTextSecondary
                              : AppColors.lightSecondary.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          phoneController.text.isNotEmpty) {
                        await _addOrUpdateCustomer(
                          id: customer?["id"],
                          name: nameController.text,
                          phone: phoneController.text,
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    label: Text(
                      customer == null ? "Ekle" : "Güncelle",
                      style: AppStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCustomer(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.lightText : AppColors.darkText,
          title: Text(
            "Müşteri Sil",
            style: AppStyles.headline2.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 22,
            ),
          ),
          content: Text(
            "${customer["name"]} adlı müşteriyi silmek istediğinize emin misiniz?",
            style: AppStyles.caption.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Hayır",
                style: AppStyles.caption.copyWith(
                  color: AppColors.darkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCustomerFromFirebase(customer["id"]);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                "Evet",
                style: AppStyles.caption.copyWith(
                  color: AppColors.darkRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // width and height variables removed

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Üst bar - Minimal
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Müşteriler",
                      style: AppStyles.headline1.copyWith(
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _sortOption = value;
                            _sortCustomers();
                          });
                        },
                        padding: EdgeInsets.zero,
                        color:
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        icon: Icon(
                          Icons.sort_rounded,
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                          size: 24,
                        ),
                        itemBuilder:
                            (context) => const [
                              PopupMenuItem(
                                value: "Eklenme Sırası",
                                child: Text("Eklenme Sırası"),
                              ),
                              PopupMenuItem(value: "A-Z", child: Text("A-Z")),
                              PopupMenuItem(
                                value: "Zaman",
                                child: Text("Zamana Göre"),
                              ),
                            ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arama - Minimal
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterCustomers,
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: "Müşteri ara...",
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.lightAccent,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // Liste
              Expanded(
                child:
                    filteredCustomers.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Müşteri bulunamadı",
                                style: AppStyles.bodyText.copyWith(
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredCustomers.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return _buildCustomerCard(customer, isDark);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        onPressed: () => _showAddOrEditCustomerPopup(context, isDark),
        child: const Icon(Icons.add, color: AppColors.lightSurface),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              () => Navigator.pushNamed(
                context,
                '/customer-detail',
                arguments: customer,
              ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.darkAccent.withOpacity(0.2)
                            : AppColors.lightAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (customer["name"] as String).isNotEmpty
                          ? customer["name"][0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkAccent
                                : AppColors.lightAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer["name"],
                        style: AppStyles.bodyText.copyWith(
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer["phone"],
                        style: AppStyles.caption.copyWith(
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  onSelected: (value) {
                    if (value == "edit") {
                      _showAddOrEditCustomerPopup(
                        context,
                        isDark,
                        customer: customer,
                      );
                    } else if (value == "delete") {
                      _deleteCustomer(customer);
                    }
                  },
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem(value: "edit", child: Text("Güncelle")),
                        PopupMenuItem(value: "delete", child: Text("Sil")),
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
