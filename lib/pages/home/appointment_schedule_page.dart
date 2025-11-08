import 'package:flutter/material.dart';
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
  final Map<DateTime, List<Map<String, dynamic>>> _appointments = {};

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

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
              // 📅 Takvim Alanı
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
                    weekendTextStyle: TextStyle(
                      color: isDark ? AppColors.lightRed : AppColors.lightRed,
                      fontWeight: FontWeight.bold,
                    ),
                    outsideTextStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.lightText
                              : AppColors.darkTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),

                    // Bugün veya seçili gün dışında kalan normal hücrelerin arka planı
                    cellMargin: const EdgeInsets.all(4),
                    cellPadding: const EdgeInsets.all(2),
                    cellAlignment: Alignment.center,
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      color: isDark ? AppColors.darkRed : AppColors.darkRed,
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

              // 📋 Günlük Randevu Listesi
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

                      // Listeleme
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: selectedAppointments.length,
                                  itemBuilder: (context, index) {
                                    final appt = selectedAppointments[index];
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
                                        borderRadius: BorderRadius.circular(12),
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
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              setState(() {
                                                selectedAppointments.removeAt(
                                                  index,
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
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

      // ➕ Randevu ekleme butonu
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        backgroundColor:
            isDark ? AppColors.lightSecondary : AppColors.darkSecondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }

  void _showAddAppointmentDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            "Yeni Randevu Ekle",
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
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: "Saat (örn: 14:30)",
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
              onPressed: () {
                if (_selectedDay != null &&
                    _titleController.text.isNotEmpty &&
                    _timeController.text.isNotEmpty) {
                  setState(() {
                    _appointments[_selectedDay!] ??= [];
                    _appointments[_selectedDay!]!.add({
                      "title": _titleController.text,
                      "time": _timeController.text,
                    });
                  });
                  _titleController.clear();
                  _timeController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }
}
