import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// --- COLORS ---
class AppColors {
  static const Color bgDark = Color(0xFF181818);
  static const Color mainBackground = Color(0xFF181818);
  static const Color containerBackground = Color(0xFF1E1E1E);
  static const Color primaryGlow = Color(0xFFA020F0);
  static const Color cardDark = Color(0xFF252525);
  static const Color cardDarkHover = Color(0xFF2F2F2F);
  static const Color primaryPurple = Color(0xFFA020F0);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Colors.grey;
  static const Color statusGreen = Color(0xFF4CAF50);
  static const Color statusRed = Color(0xFFE53935);
  static const Color statusOrange = Color(0xFFFF9800);
}

// --- MODELS ---
class ScheduleData {
  final int scheduleId;
  final int stationId;
  final DateTime date;
  String statusCode;
  String statusName;
  final bool allowUpdate;
  final String openTime;
  final String closeTime;
  final List<TimeSlot> timeSlots;
  String interval;

  ScheduleData({
    required this.scheduleId,
    required this.stationId,
    required this.date,
    required this.statusCode,
    required this.statusName,
    required this.allowUpdate,
    required this.openTime,
    required this.closeTime,
    required this.timeSlots,
    required this.interval,
  });
}

class TimeSlot {
  final int timeSlotId;
  final String begin;
  final String end;
  final String periodCode;
  final String periodName;
  final String statusCode;
  final String statusName;

  TimeSlot({
    required this.timeSlotId,
    required this.begin,
    required this.end,
    required this.periodCode,
    required this.periodName,
    required this.statusCode,
    required this.statusName,
  });
}

// --- TIME FORMATTER ---
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // 1. Chỉ cho phép nhập số và dấu hai chấm
    if (RegExp(r'[^0-9:]').hasMatch(text)) {
      return oldValue;
    }

    // 2. Logic Format thông minh: 0900 -> 09:00
    // Nếu người dùng nhập liên tục 4 số, tự động chèn dấu : vào giữa
    if (text.length == 4 && !text.contains(':')) {
      // Kiểm tra nếu là 4 số (ví dụ 0900)
      if (RegExp(r'^\d{4}$').hasMatch(text)) {
        text = '${text.substring(0, 2)}:${text.substring(2)}';
      }
    }

    // 3. Giới hạn độ dài tối đa 5 ký tự (HH:MM)
    if (text.length > 5) {
      // Nếu chuỗi mới dài hơn 5 ký tự, trả về giá trị cũ (chặn nhập tiếp)
      return oldValue;
    }

    // 4. Validate giờ phút (Sửa lỗi logic đè giá trị)
    // Đảm bảo nếu nhập 99:99 thì sẽ thành 23:59
    if (text.length == 5 && text.contains(':')) {
      List<String> parts = text.split(':');
      int? hh = int.tryParse(parts[0]);
      int? mm = int.tryParse(parts[1]);

      String fixedHH = parts[0];
      String fixedMM = parts[1];

      if (hh != null && hh > 23) fixedHH = "23"; // Auto fix hour
      if (mm != null && mm > 59) fixedMM = "59"; // Auto fix min

      text = "$fixedHH:$fixedMM";
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// --- DATE FORMATTER (dd-MM-yyyy) ---
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Chỉ cho phép số và dấu gạch ngang
    if (RegExp(r'[^0-9-]').hasMatch(text)) return oldValue;

    // Tự động thêm dấu - khi gõ
    if (text.length == 2 && oldValue.text.length == 1) {
      text += '-';
    } else if (text.length == 5 && oldValue.text.length == 4) {
      text += '-';
    }

    // Xử lý paste hoặc nhập nhanh chuỗi 8 số: 17121999 -> 17-12-1999
    if (text.length == 8 && !text.contains('-')) {
      if (RegExp(r'^\d{8}$').hasMatch(text)) {
        text =
            '${text.substring(0, 2)}-${text.substring(2, 4)}-${text.substring(4)}';
      }
    }

    // Giới hạn độ dài dd-MM-yyyy là 10 ký tự
    if (text.length > 10) return oldValue;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// --- MAIN PAGE ---
class ScheduleManagerPage extends StatefulWidget {
  const ScheduleManagerPage({Key? key}) : super(key: key);

  @override
  State<ScheduleManagerPage> createState() => _ScheduleManagerPageState();
}

class _ScheduleManagerPageState extends State<ScheduleManagerPage> {
  // State
  DateTime _currentMonth = DateTime(2026, 1, 1);
  DateTime _selectedDate = DateTime(2026, 1, 4);
  String _activeTab = 'calendar'; // 'calendar' | 'slots'

  // Mock Database
  Map<String, ScheduleData> _scheduleDb = {};

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  // Helper: Format Date Key
  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Logic: Generate Mock Data
  void _generateMockData() {
    final Map<String, ScheduleData> data = {};
    final int year = 2026;
    final int month = 1;
    final int daysInMonth = 31;

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      final dateKey = _formatDateKey(date);
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      final startHour = isWeekend ? 7 : 9;
      final endHour = 22;

      final List<TimeSlot> slots = [];
      for (int h = startHour; h < endHour; h++) {
        String period = "MORNING";
        if (h >= 12) period = "AFTERNOON";
        if (h >= 18) period = "EVENING";

        String periodName = "Sáng";
        if (period == "AFTERNOON") periodName = "Chiều";
        if (period == "EVENING") periodName = "Tối";

        slots.add(TimeSlot(
          timeSlotId: int.parse("$i$h"),
          begin: "${h.toString().padLeft(2, '0')}:00:00",
          end: "${(h + 1).toString().padLeft(2, '0')}:00:00",
          periodCode: period,
          periodName: periodName,
          statusCode: "ENABLED",
          statusName: "Kích hoạt",
        ));
      }

      data[dateKey] = ScheduleData(
        scheduleId: i,
        stationId: 2,
        date: date,
        statusCode: i % 5 == 0 ? "DRAFT" : "ENABLED",
        statusName: i % 5 == 0 ? "Nháp" : "Đã Kích Hoạt",
        allowUpdate: true,
        openTime: "${startHour.toString().padLeft(2, '0')}:00",
        closeTime: "${endHour.toString().padLeft(2, '0')}:00",
        timeSlots: slots,
        interval: "HOUR",
      );
    }
    setState(() {
      _scheduleDb = data;
    });
  }

  // Helper: Get Vietnamese Date String (FIX: Chuyển đổi thứ sang Tiếng Việt)
  String _getVietnameseDate(DateTime date) {
    final List<String> days = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    // date.weekday trả về 1 (Thứ 2) -> 7 (CN), mảng bắt đầu từ 0
    return "${days[date.weekday - 1]}, ${DateFormat('dd/MM/yyyy').format(date)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: ListView(
        padding: EdgeInsets.zero,
        physics:
            const BouncingScrollPhysics(), // Scroll physics for the main page
        children: [
          Container(
            alignment: Alignment.center,
            padding:
                const EdgeInsets.symmetric(horizontal: 38.0, vertical: 38.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.containerBackground,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGlow.withOpacity(0.25),
                    blurRadius: 20.0,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildTabNavigation(),
                  const SizedBox(height: 24),

                  // Content Area
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _activeTab == 'calendar'
                        ? _buildCalendarTab()
                        : _buildSlotsTab(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS: HEADER ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cấu hình Lịch & Slots",
                style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Colors.white38),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("CyberCore Gaming Station",
                          style: TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600)),
                      Text("#ST-002",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Container(
                      height: 24,
                      width: 1,
                      color: Colors.white10,
                      margin: const EdgeInsets.symmetric(horizontal: 16)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text("Đang hoạt động",
                        style: TextStyle(
                            color: AppColors.statusGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tạo Lịch",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }

  Widget _breadcrumbItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  // --- WIDGETS: TABS ---
  Widget _buildTabNavigation() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
              "Lịch Hoạt Động", Icons.calendar_view_month, 'calendar'),
          _buildTabButton("Danh Sách Slot", Icons.list_alt, 'slots'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, String tabId) {
    bool isActive = _activeTab == tabId;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS: CALENDAR TAB ---
  Widget _buildCalendarTab() {
    return Column(
      key: const ValueKey('calendar'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Operating Hours Summary
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.access_time,
                    color: AppColors.primaryPurple, size: 20),
                SizedBox(width: 8),
                Text("GIỜ HOẠT ĐỘNG TIÊU CHUẨN",
                    style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2))
              ]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTimeSummaryItem(
                          "Thứ 2 - Thứ 6", "09:00 - 22:00", Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTimeSummaryItem("Thứ 7 - Chủ Nhật",
                          "07:00 - 22:00", AppColors.primaryPurple)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Compact Days Header (No divider, direct background)
        Container(
          decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              // Calendar Header (Removed extra padding and divider)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 12, 16, 0), // Bottom padding reduced
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tháng ${_currentMonth.month}, ${_currentMonth.year}",
                        style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.chevron_left,
                                color: Colors.grey, size: 20),
                            onPressed: () => setState(() => _currentMonth =
                                DateTime(_currentMonth.year,
                                    _currentMonth.month - 1))),
                        IconButton(
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.grey, size: 20),
                            onPressed: () => setState(() => _currentMonth =
                                DateTime(_currentMonth.year,
                                    _currentMonth.month + 1))),
                      ],
                    )
                  ],
                ),
              ),

              // Compact Days Header (No divider, direct background)
              Container(
                // ĐÃ XÓA: margin: const EdgeInsets.only(top: 8),
                // Xóa margin này sẽ làm mất khoảng trắng giữa Header và thanh Thứ
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    border: Border(bottom: BorderSide(color: Colors.white10))),
                child: Row(
                  children: ["CN", "HAI", "BA", "TƯ", "NĂM", "SÁU", "BẢY"]
                      .map((d) => Expanded(
                            child: Center(
                                child: Text(d,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold))),
                          ))
                      .toList(),
                ),
              ),

              // Days Grid
              _buildMonthGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSummaryItem(String label, String time, Color timeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(time,
              style: TextStyle(
                  color: timeColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final int startOffset =
        firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday; // Sun = 0
    final int totalCells = (daysInMonth + startOffset <= 35) ? 35 : 42;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics:
            const NeverScrollableScrollPhysics(), // Ensures page scrolls, not grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          if (index < startOffset || index >= startOffset + daysInMonth) {
            return const SizedBox.shrink();
          }

          final day = index - startOffset + 1;
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final dateKey = _formatDateKey(date);
          final schedule = _scheduleDb[dateKey];
          final isSelected = _formatDateKey(_selectedDate) == dateKey;
          final isToday = _formatDateKey(DateTime.now()) == dateKey;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _activeTab = 'slots';
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.1)
                    : const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.primaryPurple.withOpacity(0.3),
                    width: isSelected ? 2 : 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Day Number - Big & Centered
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text("$day",
                        style: TextStyle(
                          color:
                              isToday ? AppColors.primaryPurple : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        )),
                  ),
                  const SizedBox(height: 8),

                  // 2. Info - Small & Subtle (Fixed Layout, No Scroll -> Fixes Page Scroll Issue)
                  if (schedule != null)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${schedule.openTime}-${schedule.closeTime}",
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontFamily: 'monospace'), // Small text
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: (schedule.statusCode == 'ENABLED'
                                      ? AppColors.statusGreen
                                      : AppColors.statusOrange)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              schedule.statusCode == 'ENABLED'
                                  ? 'HOẠT ĐỘNG'
                                  : 'NGỪNG',
                              style: TextStyle(
                                  fontSize: 9, // Small text
                                  fontWeight: FontWeight.bold,
                                  color: schedule.statusCode == 'ENABLED'
                                      ? AppColors.statusGreen
                                      : AppColors.statusOrange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Expanded(
                        child: Center(
                            child: Icon(Icons.add,
                                size: 14, color: Colors.white10)))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS: SLOTS TAB ---
  Widget _buildSlotsTab() {
    final schedule = _scheduleDb[_formatDateKey(_selectedDate)];

    return Column(
      key: const ValueKey('slots'),
      children: [
        // Daily Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primaryPurple, size: 20),
                  const SizedBox(width: 12),
                  // FIX: Sử dụng hàm helper tiếng Việt
                  Text("Chi tiết: ${_getVietnameseDate(_selectedDate)}",
                      style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _showCreateDialog(editMode: schedule != null),
                  icon: Icon(schedule != null ? Icons.settings : Icons.add,
                      size: 18),
                  label: Text(schedule != null ? "Cấu hình" : "Tạo Lịch"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white),
                ),
                if (schedule != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {}, // Mock delete
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withOpacity(0.5))),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                  )
                ]
              ],
            )
          ],
        ),
        const SizedBox(height: 16),

        if (schedule == null)
          _buildEmptyState()
        else ...[
          _buildStatusBanner(schedule),
          _buildTimeSlotList(schedule.timeSlots),
        ]
      ],
    );
  }

  Widget _buildStatusBanner(ScheduleData schedule) {
    bool isDraft = schedule.statusCode == 'DRAFT';
    Color color = isDraft ? AppColors.statusOrange : AppColors.statusGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(isDraft ? Icons.edit : Icons.check_circle,
                    color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "TRẠNG THÁI: ${isDraft ? 'NHÁP (DRAFT)' : 'ĐÃ KÍCH HOẠT'}",
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      isDraft
                          ? "Cần kích hoạt để user có thể đặt chỗ."
                          : "Lịch đang hiển thị trên ứng dụng.",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
          Switch(
            value: !isDraft,
            activeColor: AppColors.statusGreen,
            onChanged: (val) {
              setState(() {
                schedule.statusCode = val ? 'ENABLED' : 'DRAFT';
                schedule.statusName = val ? 'Đã Kích Hoạt' : 'Nháp';
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildTimeSlotList(List<TimeSlot> slots) {
    // Group slots
    Map<String, List<TimeSlot>> grouped = {};
    for (var slot in slots) {
      if (!grouped.containsKey(slot.periodName)) grouped[slot.periodName] = [];
      grouped[slot.periodName]!.add(slot);
    }

    return Column(
      children: grouped.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.cardDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Text(entry.key.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryPurple.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.bgDark),
                    child: Text("${entry.value.length} SLOTS",
                        style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // Responsive in real app
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: entry.value.length,
                itemBuilder: (ctx, idx) {
                  final slot = entry.value[idx];
                  bool isEnabled = slot.statusCode == 'ENABLED';
                  return Container(
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? const Color(0xFF1E1E1E)
                          : AppColors.bgDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isEnabled
                              ? Colors.white10
                              : Colors.red.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time,
                                  size: 12,
                                  color: isEnabled
                                      ? Colors.grey
                                      : AppColors.statusOrange),
                              const SizedBox(width: 4),
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isEnabled
                                          ? AppColors.statusGreen
                                          : AppColors.statusOrange))
                            ]),
                        const SizedBox(height: 4),
                        Text(
                            "${slot.begin.substring(0, 5)} - ${slot.end.substring(0, 5)}",
                            style: TextStyle(
                                color: isEnabled ? Colors.white : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
          color: AppColors.cardDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, style: BorderStyle.solid)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today,
                size: 60, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text("Chưa có lịch cho ngày này",
                style: TextStyle(color: Colors.grey, fontSize: 18)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showCreateDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Tạo lịch ngay"),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  side: const BorderSide(color: AppColors.primaryPurple)),
            )
          ],
        ),
      ),
    );
  }

  // --- ACTIONS: DIALOG ---
  void _showCreateDialog({bool editMode = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: _CreateScheduleForm(
            initialDate: _selectedDate,
            isEdit: editMode,
            onSubmit: (type, data) {
              // Mock submit logic
              if (type == 'manual') {
                // Update DB logic would go here
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Đã lưu lịch ngày ${data['date']}")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã sao chép lịch thành công!")));
              }
              Navigator.pop(context);
              setState(() {}); // Refresh UI
            },
          ),
        ),
      ),
    );
  }
}

// --- SUB-WIDGET: FORM ---
class _CreateScheduleForm extends StatefulWidget {
  final DateTime initialDate;
  final bool isEdit;
  final Function(String type, Map<String, dynamic> data) onSubmit;

  const _CreateScheduleForm(
      {Key? key,
      required this.initialDate,
      required this.isEdit,
      required this.onSubmit})
      : super(key: key);

  @override
  State<_CreateScheduleForm> createState() => _CreateScheduleFormState();
}

class _CreateScheduleFormState extends State<_CreateScheduleForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Fields
  late TextEditingController _dateCtrl;
  final TextEditingController _fromCtrl = TextEditingController(text: "09:00");
  final TextEditingController _toCtrl = TextEditingController(text: "22:00");
  String _interval = "HOUR";

  String _copySource = "current_week";
  String _copyTarget = "next_week";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dateCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.initialDate));
  }

  // Helper: Get Week Range String
  String _getWeekRange(DateTime date) {
    // Find Monday of the week
    final int dayOfWeek = date.weekday;
    final DateTime start = date.subtract(Duration(days: dayOfWeek - 1));
    final DateTime end = start.add(const Duration(days: 6));
    return "${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM').format(end)}";
  }

  // Helper: Get Month String
  String _getMonthStr(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dates for display
    final DateTime baseDate = widget.initialDate;
    final String currentWeekRange = _getWeekRange(baseDate);
    final String nextWeekRange =
        _getWeekRange(baseDate.add(const Duration(days: 7)));
    final String currentMonthStr = _getMonthStr(baseDate);
    final String nextMonthStr =
        _getMonthStr(DateTime(baseDate.year, baseDate.month + 1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.date_range, color: AppColors.primaryPurple),
              SizedBox(width: 8),
              Text(widget.isEdit ? "Cấu hình Lịch" : "Tạo Lịch Mới",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
            ]),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.grey))
          ],
        ),
        const SizedBox(height: 24),

        // Custom Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.bgDark, borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10)),
            labelColor: AppColors.primaryPurple,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                  height: 40,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit, size: 16),
                        const SizedBox(width: 8),
                        Text(widget.isEdit ? "Chỉnh sửa" : "Tạo Thủ Công")
                      ])),
              const Tab(
                  height: 40,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 16),
                        SizedBox(width: 8),
                        Text("Sao Chép Lịch")
                      ])),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Manual Tab
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Ngày áp dụng"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _dateCtrl,
                            icon: Icons.calendar_today,
                            isDate: true, // Enable custom formatter
                            // Thêm nút mở lịch
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month,
                                  color: AppColors.primaryPurple),
                              onPressed: () async {
                                DateTime firstDate = DateTime(2025);
                                DateTime lastDate = DateTime(2030);
                                DateTime initialDate = widget.initialDate;

                                try {
                                  DateTime parsed = DateFormat('dd-MM-yyyy')
                                      .parse(_dateCtrl.text);
                                  // Check if parsed date is within valid range
                                  if (parsed.isAfter(firstDate
                                          .subtract(const Duration(days: 1))) &&
                                      parsed.isBefore(lastDate
                                          .add(const Duration(days: 1)))) {
                                    initialDate = parsed;
                                  }
                                } catch (e) {
                                  // Invalid format or other error, keep initialDate as widget.initialDate
                                }

                                // Final safety check
                                if (initialDate.isBefore(firstDate))
                                  initialDate = firstDate;
                                if (initialDate.isAfter(lastDate))
                                  initialDate = lastDate;

                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: firstDate,
                                  lastDate: lastDate,
                                  builder: (context, child) => Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                          primary: AppColors.primaryPurple,
                                          surface: AppColors.cardDark,
                                          onSurface: Colors.white),
                                      dialogBackgroundColor: AppColors.cardDark,
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _dateCtrl.text =
                                        DateFormat('dd-MM-yyyy').format(picked);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Khung giờ hoạt động"),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text("Mở cửa",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 4),
                              _buildTextField(_fromCtrl,
                                  icon: Icons.access_time,
                                  isTime: true), // Enable validation
                            ])),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text("Đóng cửa",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 4),
                              _buildTextField(_toCtrl,
                                  icon: Icons.access_time_filled,
                                  isTime: true), // Enable validation
                            ])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Độ dài mỗi slot"),
                    Row(
                      children: [
                        _buildChoiceChip("1 Giờ", "HOUR"),
                        const SizedBox(width: 12),
                        _buildChoiceChip("30 Phút", "HALF_HOUR"),
                      ],
                    )
                  ],
                ),
              ),

              // Copy Tab
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.3))),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blueAccent),
                          SizedBox(width: 12),
                          Expanded(
                              child: Text(
                                  "Sao chép cấu hình từ quá khứ áp dụng cho tương lai.",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Option: By Week
                    _buildCopyOption(
                        "Theo Tuần",
                        "Từ tuần ($currentWeekRange) \u2192 Tuần kế tiếp ($nextWeekRange)",
                        "current_week"),
                    const SizedBox(height: 12),

                    // Option: By Month
                    _buildCopyOption(
                        "Theo Tháng",
                        "Từ tháng ($currentMonthStr) \u2192 Tháng kế tiếp ($nextMonthStr)",
                        "current_month"),

                    const SizedBox(height: 24),

                    // Visual Preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                                _copySource == 'current_week'
                                    ? "NGUỒN (TUẦN)"
                                    : "NGUỒN (THÁNG)",
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                                _copySource == 'current_week'
                                    ? currentWeekRange
                                    : currentMonthStr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.arrow_forward,
                                color: AppColors.primaryPurple)),
                        Column(
                          children: [
                            Text(
                                _copyTarget == 'next_week'
                                    ? "ĐÍCH (TUẦN)"
                                    : "ĐÍCH (THÁNG)",
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                                _copyTarget == 'next_week'
                                    ? nextWeekRange
                                    : nextMonthStr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Hủy bỏ", style: TextStyle(color: Colors.grey))),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  // Chuyển đổi ngược lại yyyy-MM-dd để submit
                  try {
                    DateTime d = DateFormat('dd-MM-yyyy').parse(_dateCtrl.text);
                    String isoDate = DateFormat('yyyy-MM-dd').format(d);
                    widget.onSubmit('manual', {
                      'date': isoDate,
                      'from': _fromCtrl.text,
                      'to': _toCtrl.text,
                      'interval': _interval
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ngày không hợp lệ")));
                  }
                } else {
                  widget.onSubmit(
                      'copy', {'source': _copySource, 'target': _copyTarget});
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              child: Text(
                  _tabController.index == 0 ? "Lưu Cấu Hình" : "Sao Chép Ngay",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        )
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)));

  // Update: Add isTime parameter
  Widget _buildTextField(TextEditingController ctrl,
      {IconData? icon,
      bool isTime = false,
      bool isDate = false,
      Widget? suffixIcon}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
      inputFormatters: [
        if (isTime) TimeInputFormatter(),
        if (isDate) DateInputFormatter(),
      ],
      keyboardType:
          (isTime || isDate) ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bgDark,
        prefixIcon:
            icon != null ? Icon(icon, size: 16, color: Colors.grey) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white10)),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value) {
    bool selected = _interval == value;
    return InkWell(
      onTap: () => setState(() => _interval = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryPurple.withOpacity(0.2)
                : AppColors.bgDark,
            border: Border.all(
                color: selected ? AppColors.primaryPurple : Colors.white10),
            borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildCopyOption(String title, String subtitle, String value) {
    bool selected = _copySource == value;
    return InkWell(
      onTap: () => setState(() {
        _copySource = value;
        _copyTarget = value == 'current_week' ? 'next_week' : 'next_month';
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: selected ? AppColors.cardDark : AppColors.bgDark,
            border: Border.all(
                color: selected ? AppColors.primaryPurple : Colors.white10),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ])),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primaryPurple)
          ],
        ),
      ),
    );
  }
}
