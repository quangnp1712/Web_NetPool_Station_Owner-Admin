import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- CONSTANTS & STYLES ---
const Color kBackgroundColor = Color(0xFF09090B);
const Color kSurfaceColor = Color(0xFF0F172A); // Slate 900
const Color kBorderColor = Color(0xFF1E293B); // Slate 800

const Color kPrimaryColor = Color(0xFFCB30E0); // Tím chủ đạo
const Color kSecondaryColor = Color(0xFFD946EF); // Fuchsia
const Color kSuccessColor = Color(0xFF10B981); // Emerald
const Color kInfoColor = Color(0xFF06B6D4); // Cyan
const Color kErrorColor = Color(0xFFEF4444); // Red
const Color kWarningColor = Color(0xFFF59E0B); // Amber

// --- MOCK DATA ---
class PeakHourData {
  final String time;
  final int bookings;
  PeakHourData(this.time, this.bookings);
}

final List<PeakHourData> peakHoursData = [
  PeakHourData('08:00', 12),
  PeakHourData('10:00', 25),
  PeakHourData('12:00', 45),
  PeakHourData('14:00', 30),
  PeakHourData('16:00', 55),
  PeakHourData('18:00', 85),
  PeakHourData('20:00', 90),
  PeakHourData('22:00', 60),
];

class BookingStatusData {
  final String name;
  final double value;
  final Color color;
  BookingStatusData(this.name, this.value, this.color);
}

final List<BookingStatusData> bookingStatusData = [
  BookingStatusData('Hoàn thành', 65, kSuccessColor),
  BookingStatusData('Đang sử dụng', 25, kPrimaryColor),
  BookingStatusData('Đã hủy', 10, kErrorColor),
];

class Booking {
  final String id;
  final String stationName; // Thêm tên trạm
  final String stationAddress; // Thêm địa chỉ trạm
  final String user;
  final String type; // PC, PS5, Bida
  final String device;
  final String time;
  final String duration;
  final String status;
  final String avatar;

  Booking({
    required this.id,
    required this.stationName,
    required this.stationAddress,
    required this.user,
    required this.type,
    required this.device,
    required this.time,
    required this.duration,
    required this.status,
    required this.avatar,
  });
}

final List<Booking> recentBookings = [
  Booking(
      id: 'BK-001',
      stationName: 'CyberCore Premium Q1',
      stationAddress: '123 Lê Lợi, Q.1, TP.HCM',
      user: 'Trần Văn Nam',
      type: 'PC',
      device: 'PC-VIP-01',
      time: '18:30 - 20:30',
      duration: '2h',
      status: 'active',
      avatar: 'N'),
  Booking(
      id: 'BK-002',
      stationName: 'Bida Club Thủ Đức',
      stationAddress: '88 Võ Văn Ngân, Thủ Đức',
      user: 'Lê Thị Hoa',
      type: 'Bida',
      device: 'Pool-Std-03',
      time: '19:00 - 20:00',
      duration: '1h',
      status: 'pending',
      avatar: 'H'),
  Booking(
      id: 'BK-003',
      stationName: 'PS5 Hub Gò Vấp',
      stationAddress: '32 Phan Văn Trị, Gò Vấp',
      user: 'Nguyễn Minh',
      type: 'PS5',
      device: 'PS5-Room-02',
      time: '14:00 - 16:00',
      duration: '2h',
      status: 'completed',
      avatar: 'M'),
  Booking(
      id: 'BK-004',
      stationName: 'CyberCore Premium Q1',
      stationAddress: '123 Lê Lợi, Q.1, TP.HCM',
      user: 'Hoàng Long',
      type: 'PC',
      device: 'PC-Std-12',
      time: '09:00 - 12:00',
      duration: '3h',
      status: 'cancelled',
      avatar: 'L'),
  Booking(
      id: 'BK-005',
      stationName: 'CyberCore Premium Q1',
      stationAddress: '123 Lê Lợi, Q.1, TP.HCM',
      user: 'Phạm Trang',
      type: 'PC',
      device: 'PC-VIP-05',
      time: '20:00 - 22:00',
      duration: '2h',
      status: 'active',
      avatar: 'T'),
];

// --- MAIN PAGE ---
class StationBookingOverviewPage extends StatelessWidget {
  const StationBookingOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(painter: GridPainter()),
          ),
          // Ambient Light
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kPrimaryColor.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const HeaderSection(),
                const SizedBox(height: 32),

                // Stats Grid
                LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1100
                      ? 4
                      : (constraints.maxWidth > 600 ? 2 : 1);
                  double childAspectRatio =
                      constraints.maxWidth > 1100 ? 1.4 : 1.6;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: childAspectRatio,
                    children: [
                      StatCard(
                        title: "Tổng Lượt Đặt",
                        value: "342",
                        subtext: "Hôm nay",
                        trend: "up",
                        trendValue: "12%",
                        icon: Icons.calendar_month,
                        color: kPrimaryColor,
                      ),
                      StatCard(
                        title: "Tỷ Lệ Lấp Đầy",
                        value: "85%",
                        subtext: "Trung bình giờ cao điểm",
                        trend: "up",
                        trendValue: "5.4%",
                        icon: Icons.monitor,
                        color: kSuccessColor,
                      ),
                      const StatCard(
                        title: "Khách Vãng Lai",
                        value: "128",
                        subtext: "Check-in trực tiếp",
                        trend: "down",
                        trendValue: "2.1%",
                        icon: Icons.people,
                        color: kInfoColor,
                      ),
                      StatCard(
                        title: "Tỷ Lệ Hủy",
                        value: "2.4%",
                        subtext: "Thấp hơn mức cho phép",
                        trend: "down",
                        trendValue: "0.5%",
                        icon: Icons.cancel,
                        color: kErrorColor,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // Charts Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: PeakHoursChart(data: peakHoursData)),
                          const SizedBox(width: 24),
                          Expanded(
                              flex: 1,
                              child: StatusPieChart(data: bookingStatusData)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          PeakHoursChart(data: peakHoursData),
                          const SizedBox(height: 24),
                          StatusPieChart(data: bookingStatusData),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 32),

                // Booking Table
                const BookingTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Flex(
      direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(
                  "QUẢN LÝ LỊCH TRÌNH",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Tổng quan đặt lịch",
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isSmallScreen) const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kPrimaryColor, Color(0xFF7E22CE)]),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_box, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "ĐẶT LỊCH MỚI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final String trend;
  final String trendValue;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.trend,
    required this.trendValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              top: 0,
              right: 0,
              child: _CornerAccent(color: color, isTopRight: true)),
          Positioned(
              bottom: 0,
              left: 0,
              child: _CornerAccent(color: color, isTopRight: false)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.grey[400],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kBorderColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: trend == 'up' ? kSuccessColor : kErrorColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendValue,
                      style: TextStyle(
                        color: trend == 'up' ? kSuccessColor : kErrorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        subtext,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PeakHoursChart extends StatelessWidget {
  final List<PeakHourData> data;

  const PeakHoursChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                      width: 4,
                      height: 20,
                      color: kPrimaryColor,
                      margin: const EdgeInsets.only(right: 8)),
                  Text(
                    "KHUNG GIỜ CAO ĐIỂM",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(4),
                  color: kSurfaceColor,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: kPrimaryColor),
                    const SizedBox(width: 4),
                    Text(
                      "LIVE DATA",
                      style: TextStyle(fontSize: 10, color: Colors.grey[300]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: kBorderColor.withOpacity(0.5), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[value.toInt()].time,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontFamily: 'monospace'),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: 'monospace'),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.bookings.toDouble(),
                        color: kPrimaryColor
                            .withOpacity(e.value.bookings > 80 ? 1.0 : 0.6),
                        width: 30,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPieChart extends StatelessWidget {
  final List<BookingStatusData> data;

  const StatusPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 4,
                  height: 20,
                  color: kSuccessColor,
                  margin: const EdgeInsets.only(right: 8)),
              Text(
                "TRẠNG THÁI",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: data.map((item) {
                      return PieChartSectionData(
                        color: item.color,
                        value: item.value,
                        title: '',
                        radius: 20,
                      );
                    }).toList(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "100%",
                        style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                      const Text(
                        "HIỆU SUẤT",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            letterSpacing: 1.2),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: item.color, blurRadius: 4)
                              ]),
                        ),
                        const SizedBox(width: 8),
                        Text(item.name,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Text(
                      "${item.value.toInt()}%",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class BookingTable extends StatelessWidget {
  const BookingTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      clipBehavior:
          Clip.antiAlias, // QUAN TRỌNG: Cắt nội dung tràn ra khỏi viền bo tròn
      child: Column(
        children: [
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
                    Text(
                      "DANH SÁCH ĐẶT LỊCH GẦN ĐÂY",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                    color: kPrimaryColor.withOpacity(0.1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.filter_list, size: 14, color: kPrimaryColor),
                      SizedBox(width: 4),
                      Text("BỘ LỌC NÂNG CAO",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bọc SingleChildScrollView bằng ScrollConfiguration để hỗ trợ kéo chuột trên Desktop/Web
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
                    headingRowColor: MaterialStateProperty.all(Colors.black12),
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
                    rows: recentBookings.map((booking) {
                      return DataRow(
                        cells: [
                          // 1. Mã
                          DataCell(Text(booking.id,
                              style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold))),

                          // 2. Trạm (Mới)
                          DataCell(Container(
                            width: 180, // Giới hạn chiều rộng để xuống dòng
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  color: kBorderColor,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.grey.shade800),
                                ),
                                alignment: Alignment.center,
                                child: Text(booking.avatar,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              ),
                              Text(booking.user,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          )),

                          // 4. Thiết bị (Gộp Type & Device)
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTypeBadgeInline(booking.type),
                              const SizedBox(height: 4),
                              Text(booking.device,
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
                                Text(booking.time,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontFamily: 'monospace')),
                                const SizedBox(height: 2),
                                Text("${booking.duration} sử dụng",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 11)),
                              ],
                            ),
                          ),

                          // 6. Trạng thái
                          DataCell(
                              Center(child: _buildStatusBadge(booking.status))),

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () {},
              child: const Text("XEM TẤT CẢ",
                  style: TextStyle(color: Colors.grey, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  // Cập nhật hàm _buildDataColumn
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;
    bool pulse = false;

    switch (status) {
      case 'active':
        bg = kPrimaryColor.withOpacity(0.1);
        text = kPrimaryColor;
        label = 'Đang Dùng';
        pulse = true;
        break;
      case 'completed':
        bg = kSuccessColor.withOpacity(0.1);
        text = kSuccessColor;
        label = 'Hoàn Thành';
        break;
      case 'pending':
        bg = kWarningColor.withOpacity(0.1);
        text = kWarningColor;
        label = 'Chờ Xác Nhận';
        break;
      case 'cancelled':
      default:
        bg = kErrorColor.withOpacity(0.1);
        text = kErrorColor;
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

class _CornerAccent extends StatelessWidget {
  final Color color;
  final bool isTopRight;

  const _CornerAccent({required this.color, required this.isTopRight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTopRight
              ? BorderSide(color: color.withOpacity(0.5), width: 2)
              : BorderSide.none,
          right: isTopRight
              ? BorderSide(color: color.withOpacity(0.5), width: 2)
              : BorderSide.none,
          bottom: !isTopRight
              ? BorderSide(color: color.withOpacity(0.5), width: 2)
              : BorderSide.none,
          left: !isTopRight
              ? BorderSide(color: color.withOpacity(0.5), width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.3)
      ..strokeWidth = 1;

    const double gridSize = 40;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
