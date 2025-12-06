import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musteridefterim/constants/app_colors.dart';
import 'package:musteridefterim/constants/app_styles.dart';
import 'package:musteridefterim/navigation/navbar.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentSchedulePage extends StatefulWidget {
  const AppointmentSchedulePage({super.key});

  @override
  State<AppointmentSchedulePage> createState() =>
      _AppointmentSchedulePageState();
}

class _AppointmentSchedulePageState extends State<AppointmentSchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();

    // SAAT input otomatik formatlama
    _timeController.addListener(() {
      final text = _timeController.text;

      if (text.length == 2 && !text.contains(":")) {
        _timeController.text = "$text:";
        _timeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _timeController.text.length),
        );
      }
    });
  }

  Future<void> _loadAppointments() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('appointments')
            .get();

    final Map<DateTime, List<Map<String, dynamic>>> loaded = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['date']);

      // Burada artık saat farkı veya geçmiş kontrolü yapmayacağız
      loaded[date] ??= [];
      loaded[date]!.add({
        'id': doc.id,
        'title': data['title'],
        'time': data['time'],
      });
    }

    setState(() => _appointments = loaded);
  }

  Future<void> _addOrUpdateAppointment({String? id}) async {
    final user = _auth.currentUser;
    if (user == null || _selectedDay == null) return;

    final data = {
      'title': _titleController.text.trim(),
      'time': _timeController.text.trim(),
      'date': _selectedDay!.toIso8601String(),
    };

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('appointments');

    if (id == null) {
      await ref.add(data);
    } else {
      await ref.doc(id).update(data);
    }

    await _loadAppointments();
  }

  Future<void> _deleteAppointment(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('appointments')
        .doc(id)
        .delete();

    await _loadAppointments();
  }

  // ▪️ Randevu ekleme/güncelleme popup
  void _showAddOrEditDialog({Map<String, dynamic>? existing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (existing != null) {
      _titleController.text = existing['title'];
      _timeController.text = existing['time'];
    } else {
      _titleController.clear();
      _timeController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            existing == null ? "Yeni Randevu Ekle" : "Randevuyu Güncelle",
            style: AppStyles.headline2.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Randevu Başlığı"),
              ),
              SizedBox(height: 10),
              // ▪️ Saat input – sadece saat formatı girilebilsin
              TextField(
                controller: _timeController,
                maxLength: 5, // HH:MM
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: const InputDecoration(
                  labelText: "Saat (örn: 14:30)",
                  counterText: "",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final time = _timeController.text;

                // Saat doğrulama
                final isValid = RegExp(
                  r'^[0-2][0-9]:[0-5][0-9]$',
                ).hasMatch(time);

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Lütfen geçerli bir saat formatı girin (HH:MM)",
                      ),
                    ),
                  );
                  return;
                }

                if (_titleController.text.isNotEmpty &&
                    _timeController.text.isNotEmpty) {
                  await _addOrUpdateAppointment(id: existing?['id']);
                  Navigator.pop(context);
                }
              },
              child: Text(existing == null ? "Kaydet" : "Güncelle"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedAppointments =
        _appointments[_selectedDay ?? DateTime.now()] ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              Text(
                "Randevu Takvimi",
                style: AppStyles.headline1.copyWith(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.lightSecondary
                              : AppColors.darkSecondary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.lightPrimary.withOpacity(0.6)
                              : AppColors.darkPrimary.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppStyles.headline2.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 📋 Günlük Randevular
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.darkSurface.withOpacity(0.1)
                            : AppColors.lightSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_selectedDay?.day ?? DateTime.now().day}.${_selectedDay?.month ?? DateTime.now().month}.${_selectedDay?.year ?? DateTime.now().year} tarihli randevular:",
                        style: AppStyles.bodyText.copyWith(
                          color:
                              isDark ? AppColors.lightText : AppColors.darkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            selectedAppointments.isEmpty
                                ? Center(
                                  child: Text(
                                    "Henüz randevu eklenmemiş.",
                                    style: AppStyles.caption.copyWith(
                                      color:
                                          isDark
                                              ? AppColors.lightText
                                              : AppColors.darkText,
                                    ),
                                  ),
                                )
                                : Builder(
                                  builder: (context) {
                                    // ✅ Listeyi kopyala ve saate göre sırala
                                    final sortedAppointments = List<
                                      Map<String, dynamic>
                                    >.from(selectedAppointments)..sort((a, b) {
                                      final timeA =
                                          a["time"] as String; // örn: "09:30"
                                      final timeB = b["time"] as String;

                                      final partsA = timeA.split(":");
                                      final partsB = timeB.split(":");

                                      final minutesA =
                                          int.parse(partsA[0]) * 60 +
                                          int.parse(partsA[1]);
                                      final minutesB =
                                          int.parse(partsB[0]) * 60 +
                                          int.parse(partsB[1]);

                                      return minutesA.compareTo(
                                        minutesB,
                                      ); // küçük → büyük
                                    });

                                    return ListView.builder(
                                      padding: const EdgeInsets.only(
                                        bottom: 80, // FAB ile çakışmasın diye
                                      ),
                                      itemCount: sortedAppointments.length,
                                      itemBuilder: (context, index) {
                                        final appt = sortedAppointments[index];

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? AppColors.lightText
                                                        .withOpacity(0.8)
                                                    : AppColors.darkText
                                                        .withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    appt["title"],
                                                    style: AppStyles.bodyText
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              isDark
                                                                  ? AppColors
                                                                      .darkPrimary
                                                                  : AppColors
                                                                      .lightPrimary,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Saat: ${appt["time"]}",
                                                    style: AppStyles.caption
                                                        .copyWith(
                                                          color:
                                                              isDark
                                                                  ? AppColors
                                                                      .darkText
                                                                  : AppColors
                                                                      .lightText,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                    ),
                                                    color: AppColors.edit,
                                                    onPressed: () {
                                                      _showAddOrEditDialog(
                                                        existing: appt,
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                    ),
                                                    color: AppColors.error,
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AlertDialog(
                                                              title: Text(
                                                                'Dikkat!',
                                                                style: AppStyles
                                                                    .headline1
                                                                    .copyWith(
                                                                      color:
                                                                          isDark
                                                                              ? AppColors.darkText
                                                                              : AppColors.lightText,
                                                                    ),
                                                              ),
                                                              content: Text(
                                                                'Bu randevuyu silmek istediğinize emin misiniz?',
                                                                style: AppStyles
                                                                    .headline2
                                                                    .copyWith(
                                                                      color:
                                                                          isDark
                                                                              ? AppColors.darkText
                                                                              : AppColors.lightText,
                                                                    ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () =>
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop(),
                                                                  child: Text(
                                                                    'İptal',
                                                                    style: AppStyles.caption.copyWith(
                                                                      color:
                                                                          AppColors
                                                                              .darkAccent,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    _deleteAppointment(
                                                                      appt['id'],
                                                                    );
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                  },
                                                                  child: Text(
                                                                    'Sil',
                                                                    style: AppStyles.caption.copyWith(
                                                                      color:
                                                                          AppColors
                                                                              .darkSecondary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ],
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(),
        backgroundColor:
            isDark ? AppColors.lightSecondary : AppColors.darkSecondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }
}
