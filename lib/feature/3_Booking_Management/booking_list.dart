import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Để hỗ trợ scroll chuột trên Web/Desktop
import 'dart:math';

// ==========================================
// 1. CONSTANTS & THEME
// ==========================================

class AppColors {
  static const Color bgDark = Color(0xFF0C0C0A);
  static const Color bgMain = Color(0xFF121212);
  static const Color bgContainer = Color(0xFF1E1E1E);
  static const Color bgInput = Color(0xFF2C2C2E);

  static const Color primaryGlow = Color(0xFFCB30E0);
  static const Color btnPrimary = Color(0xFFAB41F0);
  static const Color tableHeader = Color(0xFF8630CB);

  static const Color textWhite = Colors.white;
  static const Color textMain = Colors.white; // Đã đổi thành màu trắng
  static const Color textHint = Color(0xFF8A8A8E);

  static const Color statusActiveText = Color(0xFF4ADE80); // Green
  static const Color statusActiveBg = Color(0xFF1B5E20); // Green Dark
  static const Color statusApprovedText = Color(0xFF60A5FA); // Blue 400
  static const Color statusApprovedBg = Color(0xFF1E3A8A); // Blue 900
  static const Color statusUsing = Color(0xFFDC2626); // Red
  static const Color border = Color(0xFF1E293B); // Slate 800
}

// ==========================================
// 2. MOCK DATA MODELS
// ==========================================

class Station {
  final int id;
  final String name;
  final String address;

  Station({required this.id, required this.name, this.address = ""});
}

class Booking {
  final String id;
  final int stationId;
  final String stationName;
  final String stationAddress; // Thêm địa chỉ trạm
  final String user;
  final String avatar; // URL ảnh (giả lập)
  final String pcName;
  final String zone;
  final String row;
  final String type; // PC, PS5, Bida
  final String timeStart;
  final String timeEnd;
  final String confirmedAt;
  final String duration;
  final int totalPrice;
  final String status; // active, approved, completed
  final bool deposit;

  Booking({
    required this.id,
    required this.stationId,
    required this.stationName,
    this.stationAddress = "", // Mặc định rỗng
    required this.user,
    required this.avatar,
    required this.pcName,
    required this.zone,
    required this.row,
    required this.type,
    required this.timeStart,
    required this.timeEnd,
    required this.confirmedAt,
    required this.duration,
    required this.totalPrice,
    required this.status,
    required this.deposit,
  });
}

// Dữ liệu giả lập
final List<Station> stations = [
  Station(id: 0, name: "TỔNG QUAN HỆ THỐNG (Overview)"),
  Station(
      id: 1,
      name: "NetPool Cyber Center - Q1",
      address: "123 Nguyễn Huệ, Q1, TP.HCM"),
  Station(
      id: 2,
      name: "NetPool Gaming House - Bình Thạnh",
      address: "456 Xô Viết Nghệ Tĩnh, BT"),
  Station(
      id: 3, name: "NetPool VIP Zone - Q7", address: "789 Nguyễn Văn Linh, Q7"),
];

final List<Booking> mockBookings = [
  // ZONE A - DÃY 1
  Booking(
      id: "BK-001",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "Nguyễn Văn A",
      avatar: "A",
      pcName: "VIP-01",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "14:00",
      timeEnd: "18:00",
      confirmedAt: "2024-01-19 10:30",
      duration: "4h",
      totalPrice: 200000,
      status: "approved",
      deposit: true),
  Booking(
      id: "BK-009",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "Trần Văn H",
      avatar: "H",
      pcName: "VIP-02",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "15:00",
      timeEnd: "19:00",
      confirmedAt: "2024-01-19 11:00",
      duration: "4h",
      totalPrice: 200000,
      status: "approved",
      deposit: true),
  Booking(
      id: "BK-008",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User G",
      avatar: "G",
      pcName: "VIP-03",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "08:00",
      timeEnd: "10:00",
      confirmedAt: "2024-01-20 09:00",
      duration: "2h",
      totalPrice: 100000,
      status: "approved",
      deposit: true),
  Booking(
      id: "BK-104",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User I",
      avatar: "I",
      pcName: "VIP-04",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "10:00",
      timeEnd: "12:00",
      confirmedAt: "2024-01-20 09:30",
      duration: "2h",
      totalPrice: 100000,
      status: "active",
      deposit: true),
  Booking(
      id: "BK-105",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User J",
      avatar: "J",
      pcName: "VIP-05",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "13:00",
      timeEnd: "15:00",
      confirmedAt: "2024-01-20 10:00",
      duration: "2h",
      totalPrice: 100000,
      status: "approved",
      deposit: true),
  Booking(
      id: "BK-106",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User K",
      avatar: "K",
      pcName: "VIP-06",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "16:00",
      timeEnd: "18:00",
      confirmedAt: "2024-01-20 10:30",
      duration: "2h",
      totalPrice: 100000,
      status: "approved",
      deposit: true),
  Booking(
      id: "BK-107",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User L",
      avatar: "L",
      pcName: "VIP-07",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "19:00",
      timeEnd: "21:00",
      confirmedAt: "2024-01-20 11:00",
      duration: "2h",
      totalPrice: 100000,
      status: "active",
      deposit: true),
  Booking(
      id: "BK-108",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User M",
      avatar: "M",
      pcName: "VIP-08",
      zone: "ZONE A - VIP",
      row: "Dãy 1",
      type: "PC",
      timeStart: "22:00",
      timeEnd: "00:00",
      confirmedAt: "2024-01-20 12:00",
      duration: "2h",
      totalPrice: 100000,
      status: "approved",
      deposit: true),

  // ZONE B
  Booking(
      id: "BK-002",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "Trần Thị B",
      avatar: "B",
      pcName: "STD-15",
      zone: "ZONE B - STANDARD",
      row: "Dãy 2",
      type: "PC",
      timeStart: "09:00",
      timeEnd: "12:00",
      confirmedAt: "2024-01-19 09:15",
      duration: "3h",
      totalPrice: 60000,
      status: "approved",
      deposit: true),
  Booking(
      id: "BK-007",
      stationId: 1,
      stationName: "NetPool Cyber Center - Q1",
      stationAddress: "123 Nguyễn Huệ, Q1, TP.HCM",
      user: "User F",
      avatar: "F",
      pcName: "STD-01",
      zone: "ZONE B - STANDARD",
      row: "Dãy 1",
      type: "PC",
      timeStart: "18:00",
      timeEnd: "22:00",
      confirmedAt: "2024-01-19 11:00",
      duration: "4h",
      totalPrice: 80000,
      status: "active",
      deposit: true),

  // PS5 & BIDA
  Booking(
      id: "BK-003",
      stationId: 2,
      stationName: "NetPool Gaming House - BT",
      stationAddress: "456 Xô Viết Nghệ Tĩnh, BT",
      user: "Lê Hoàng C",
      avatar: "C",
      pcName: "PS5-02",
      zone: "PS ROOM",
      row: "Dãy A",
      type: "PS5",
      timeStart: "19:00",
      timeEnd: "23:00",
      confirmedAt: "2024-01-20 14:00",
      duration: "4h",
      totalPrice: 150000,
      status: "approved",
      deposit: false),
  Booking(
      id: "BK-005",
      stationId: 3,
      stationName: "NetPool VIP Zone - Q7",
      stationAddress: "789 Nguyễn Văn Linh, Q7",
      user: "Hoàng K",
      avatar: "K",
      pcName: "BIDA-01",
      zone: "SẢNH CHÍNH",
      row: "Khu Bàn Lỗ",
      type: "Bida",
      timeStart: "10:00",
      timeEnd: "18:00",
      confirmedAt: "2024-01-21 08:00",
      duration: "8h",
      totalPrice: 500000,
      status: "approved",
      deposit: false),
];

// ==========================================
// 4. BOOKING LIST PAGE
// ==========================================

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  // State
  int _selectedStationId = 0; // 0 = Overview
  String _activeTab = "PC"; // PC | PS5 | Bida
  String _searchTerm = "";
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  // Mock Logic: Get Zone Price
  int getZonePrice(String zoneName) {
    if (zoneName.contains("VIP")) return 15000;
    if (zoneName.contains("STANDARD") || zoneName.contains("STD")) return 10000;
    if (zoneName.contains("PS")) return 25000;
    if (zoneName.contains("Bida") || zoneName.contains("SẢNH")) return 60000;
    return 0;
  }

  // --- Filtering & Logic ---
  List<Booking> get filteredBookings {
    return mockBookings.where((item) {
      if (item.status == 'pending') return false;

      final matchStation =
          _selectedStationId == 0 || item.stationId == _selectedStationId;
      final matchSearch =
          item.user.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              item.pcName.toLowerCase().contains(_searchTerm.toLowerCase());

      if (_selectedStationId != 0) {
        final matchType = item.type == _activeTab;
        return matchStation && matchSearch && matchType;
      }

      return matchStation && matchSearch;
    }).toList()
      ..sort((a, b) =>
          a.confirmedAt.compareTo(b.confirmedAt)); // Sort by confirmedAt
  }

  // --- Grouping Logic (Zone -> Row) ---
  Map<String, Map<String, List<Booking>>> get groupedBookings {
    if (_selectedStationId == 0) return {};

    final groups = <String, Map<String, List<Booking>>>{};

    for (var booking in filteredBookings) {
      final zone = booking.zone;
      final row = booking.row;

      groups.putIfAbsent(zone, () => {});
      groups[zone]!.putIfAbsent(row, () => []);
      groups[zone]![row]!.add(booking);
    }
    return groups;
  }

  // --- Stats Logic ---
  Map<String, int> get stationStats {
    if (_selectedStationId == 0) return {};
    final stationBookings = mockBookings.where(
        (b) => b.stationId == _selectedStationId && b.status == 'approved');
    return {
      'pc': stationBookings.where((b) => b.type == 'PC').length,
      'ps5': stationBookings.where((b) => b.type == 'PS5').length,
      'bida': stationBookings.where((b) => b.type == 'Bida').length,
    };
  }

  // ==========================================
  // UI BUILD METHODS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF09090B),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            // Switch View
            if (_selectedStationId == 0)
              _buildOverviewView()
            else
              _buildStationDetailView(),
          ],
        ),
      ),
    );
  }

  // --- Header & Station Selector ---
  Widget _buildHeader() {
    final selectedStationName =
        stations.firstWhere((s) => s.id == _selectedStationId).name;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tableHeader.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedStationId == 0
                          ? Icons.dashboard
                          : Icons.calendar_today,
                      color: AppColors.primaryGlow,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedStationId == 0
                        ? "Dashboard Overview"
                        : "Quản Lý Lịch Đặt",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedStationId == 0
                    ? "Tổng quan danh sách đặt lịch toàn hệ thống"
                    : selectedStationName,
                style: const TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Custom Dropdown
        Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedStationId,
              dropdownColor: AppColors.bgInput,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textHint),
              isExpanded: true,
              items: stations.map((station) {
                return DropdownMenuItem<int>(
                  value: station.id,
                  child: Text(
                    station.name,
                    style: const TextStyle(
                        color: AppColors.textMain, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStationId = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          style: const TextStyle(color: AppColors.textMain),
          onChanged: (val) => setState(() => _searchTerm = val),
          decoration: InputDecoration(
            hintText: "Tìm tên khách hoặc máy...",
            hintStyle: const TextStyle(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // --- VIEW 1: OVERVIEW TABLE ---
  Widget _buildOverviewView() {
    final displayData = filteredBookings;
    final totalPages = (displayData.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, displayData.length);
    final paginatedData = displayData.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Banner Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            image: const DecorationImage(
              image: NetworkImage(
                  "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1200&q=80"),
              fit: BoxFit.cover,
              opacity: 0.6,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.bgMain, Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chào mừng trở lại, Admin!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: AppColors.textMain, fontSize: 14),
                        children: [
                          const TextSpan(text: "Hôm nay có "),
                          TextSpan(
                            text: "${filteredBookings.length}",
                            style: const TextStyle(
                                color: AppColors.primaryGlow,
                                fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " lịch đặt đã được xác nhận."),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Table Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgContainer.withOpacity(0.5),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Table Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 4,
                            height: 20,
                            color: Colors.purple,
                            margin: const EdgeInsets.only(right: 8)),
                        const Text(
                          "DANH SÁCH ĐẶT LỊCH GẦN ĐÂY",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryGlow.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.primaryGlow.withOpacity(0.1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.filter_list,
                              size: 14, color: AppColors.primaryGlow),
                          SizedBox(width: 4),
                          Text("BỘ LỌC NÂNG CAO",
                              style: TextStyle(
                                  color: AppColors.primaryGlow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Data Table
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 48),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.white.withOpacity(0.05),
                      ),
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.black12),
                        dataRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.transparent),
                        columnSpacing:
                            24, // Tăng khoảng cách cột một chút cho dễ nhìn
                        horizontalMargin: 24,
                        dataRowHeight:
                            80, // Tăng chiều cao row để chứa thông tin 2 dòng của trạm
                        columns: [
                          _buildDataColumn("MÃ"),
                          // Cột MỚI: Trạm
                          _buildDataColumn("TRẠM & ĐỊA ĐIỂM"),
                          _buildDataColumn("KHÁCH HÀNG"),
                          _buildDataColumn("THIẾT BỊ"), // Gộp Type và Device
                          _buildDataColumn("THỜI GIAN"), // Gộp Time và Duration
                          _buildDataColumn("TRẠNG THÁI", center: true),
                          _buildDataColumn("THAO TÁC", numeric: true),
                        ],
                        dividerThickness: 0.1,
                        rows: paginatedData.map((booking) {
                          return DataRow(
                            cells: [
                              // 1. Mã
                              DataCell(Text(booking.id,
                                  style: const TextStyle(
                                      color: AppColors.primaryGlow,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold))),

                              // 2. Trạm (Mới)
                              DataCell(Container(
                                width: 180, // Giới hạn chiều rộng để xuống dòng
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.stationName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 10, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            booking.stationAddress,
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),

                              // 3. Khách hàng
                              DataCell(Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: Colors.grey.shade800),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(booking.avatar,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                  ),
                                  Text(booking.user,
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                ],
                              )),

                              // 4. Thiết bị (Gộp Type & Device)
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTypeBadgeInline(booking.type),
                                  const SizedBox(height: 4),
                                  Text(booking.pcName,
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                          fontFamily: 'monospace')),
                                ],
                              )),

                              // 5. Thời gian (Gộp Time & Duration)
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${booking.timeStart} - ${booking.timeEnd}",
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontFamily: 'monospace')),
                                    const SizedBox(height: 2),
                                    Text("${booking.duration} sử dụng",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11)),
                                  ],
                                ),
                              ),

                              // 6. Trạng thái
                              DataCell(Center(
                                  child: _buildStatusBadge(booking.status))),

                              // 7. Thao tác
                              DataCell(IconButton(
                                icon: const Icon(Icons.more_horiz,
                                    color: Colors.grey),
                                onPressed: () {},
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              // Pagination
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text("XEM TẤT CẢ",
                          style: TextStyle(
                              color: Colors.grey, letterSpacing: 1.2)),
                    ),
                    Row(
                      children: [
                        Text(
                          "Hiển thị ${paginatedData.isNotEmpty ? startIndex + 1 : 0} - $endIndex trong tổng số ${displayData.length}",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text("$_currentPage",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.btnPrimary)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataColumn _buildDataColumn(String label,
      {bool numeric = false, bool center = false}) {
    return DataColumn(
      label: Expanded(
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.grey, fontSize: 10, letterSpacing: 1.0),
          textAlign: center
              ? TextAlign.center
              : (numeric ? TextAlign.right : TextAlign.left),
        ),
      ),
      numeric: numeric,
    );
  }

  // Badge nhỏ gọn cho cột Thiết bị
  Widget _buildTypeBadgeInline(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'PC':
        icon = Icons.computer;
        color = Colors.blue;
        break;
      case 'PS5':
        icon = Icons.gamepad;
        color = Colors.purple;
        break;
      case 'Bida':
        icon = Icons.sports_baseball;
        color = Colors.green;
        break;
      default:
        icon = Icons.device_unknown;
        color = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          type.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // --- VIEW 2: STATION DETAIL (Cards) ---
  Widget _buildStationDetailView() {
    final stats = stationStats;
    final groups = groupedBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Stats Cards
        Row(
          children: [
            _buildStatCard("Net / PC", Icons.computer, Colors.blue,
                stats['pc'] ?? 0, 'PC'),
            const SizedBox(width: 16),
            _buildStatCard("Playstation 5", Icons.gamepad, Colors.purple,
                stats['ps5'] ?? 0, 'PS5'),
            const SizedBox(width: 16),
            _buildStatCard("Billiards", Icons.sports_baseball, Colors.green,
                stats['bida'] ?? 0, 'Bida'),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Tabs
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: ['PC', 'PS5', 'Bida'].map((type) {
              final isActive = _activeTab == type;
              return InkWell(
                onTap: () => setState(() => _activeTab = type),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: isActive
                                ? AppColors.primaryGlow
                                : Colors.transparent,
                            width: 2)),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textHint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // 3. Zone -> Row -> Machine Hierarchy
        if (groups.isEmpty)
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgContainer.withOpacity(0.2),
              border:
                  Border.all(color: AppColors.border, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.layers, size: 48, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text("Không có lịch đặt nào cho $_activeTab",
                    style: const TextStyle(color: AppColors.textHint)),
              ],
            ),
          )
        else
          ...groups.entries.map((entry) {
            final zoneName = entry.key;
            final rows = entry.value;
            final zonePrice = getZonePrice(zoneName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgContainer.withOpacity(0.5),
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zone Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.grid_view,
                                  color: AppColors.primaryGlow, size: 20),
                              const SizedBox(width: 12),
                              Text(zoneName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMain)),
                              if (zonePrice > 0) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusActiveText
                                        .withOpacity(0.1),
                                    border: Border.all(
                                        color: AppColors.statusActiveText
                                            .withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${zonePrice}đ/h",
                                    style: const TextStyle(
                                        color: AppColors.statusActiveText,
                                        fontSize: 12,
                                        fontFamily: 'monospace'),
                                  ),
                                )
                              ]
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bgInput,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              "${rows.values.expand((x) => x).length} máy đang có lịch",
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 11),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // List of Rows
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: rows.entries.map((rowEntry) {
                          final rowName = rowEntry.key;
                          final bookings = rowEntry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgDark,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.layers,
                                        size: 14, color: AppColors.textHint),
                                    const SizedBox(width: 8),
                                    Text(rowName,
                                        style: const TextStyle(
                                            color: AppColors.textMain,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Machines Wrap (Grid)
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: bookings
                                      .map((b) => _buildMachineCard(b))
                                      .toList(),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  // --- WIDGET HELPER: MACHINE CARD ---
  Widget _buildMachineCard(Booking booking) {
    final isActive = booking.status == 'active';
    final borderColor = isActive ? AppColors.statusActiveText : Colors.blue;
    final glowColor = isActive ? AppColors.statusActiveText : Colors.blue;

    return Container(
      width: 140, // Kích thước cố định cho ô vuông
      height: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Name & Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  booking.pcName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textMain),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking.duration,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              )
            ],
          ),

          // Center: Slot Info
          Column(
            children: [
              const Text("SLOT",
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                      letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(
                booking.timeStart,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.statusActiveText : Colors.blue),
              ),
              Text("to ${booking.timeEnd}",
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),

          // Footer: User & Status
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                      radius: 6,
                      backgroundColor: AppColors.bgInput,
                      child: Text(booking.avatar[0],
                          style: const TextStyle(fontSize: 10))),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(booking.user,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMain),
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: (isActive
                          ? AppColors.statusActiveBg
                          : AppColors.statusApprovedBg)
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? "ĐANG CHƠI" : "ĐÃ ĐẶT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppColors.statusActiveText
                        : AppColors.statusApprovedText,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPER: STAT CARD ---
  Widget _buildStatCard(
      String title, IconData icon, Color color, int count, String typeKey) {
    final isActive = _activeTab == typeKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = typeKey),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? AppColors.bgContainer : AppColors.bgMain,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color.withOpacity(0.5) : AppColors.border,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15)]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHint)),
                  Icon(icon,
                      size: 18, color: isActive ? color : AppColors.textHint),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "$count ",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const TextSpan(
                        text: "lịch đặt",
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- ICON & STATUS HELPERS ---
  Widget _getDeviceIcon(String type) {
    switch (type) {
      case 'PC':
        return const Icon(Icons.computer, size: 16, color: Colors.blue);
      case 'PS5':
        return const Icon(Icons.gamepad, size: 16, color: Colors.purple);
      case 'Bida':
        return const Icon(Icons.sports_baseball, size: 16, color: Colors.green);
      default:
        return const Icon(Icons.devices, size: 16, color: Colors.grey);
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;
    bool pulse = false;

    switch (status) {
      case 'active':
        bg = AppColors.primaryGlow.withOpacity(0.1);
        text = AppColors.primaryGlow;
        label = 'Đang Dùng';
        pulse = true;
        break;
      case 'completed':
        bg = AppColors.statusActiveText.withOpacity(0.1);
        text = AppColors.statusActiveText;
        label = 'Hoàn Thành';
        break;
      case 'pending':
        bg = Colors.orange.withOpacity(0.1);
        text = Colors.orange;
        label = 'Chờ Xác Nhận';
        break;
      case 'cancelled':
      default:
        bg = AppColors.statusUsing.withOpacity(0.1);
        text = AppColors.statusUsing;
        label = 'Đã Hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: text.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[
            Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: text, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: text, fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
