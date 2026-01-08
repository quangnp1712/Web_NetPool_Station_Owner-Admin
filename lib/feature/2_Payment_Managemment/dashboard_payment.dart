import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// --- CONSTANTS & STYLES ---
const Color kPrimaryColor = Color(0xFFCB30E0); // Tím chủ đạo
const Color kSecondaryColor = Color(0xFFD946EF); // Fuchsia
const Color kCyanColor = Color(0xFF06B6D4);
const Color kSuccessColor = Color(0xFF10B981); // Emerald
const Color kWarningColor = Color(0xFFF59E0B); // Amber
const Color kErrorColor = Color(0xFFEF4444); // Red
const Color kSurfaceColor = Color(0xFF0F172A); // Slate 900
const Color kBorderColor = Color(0xFF1E293B); // Slate 800

// --- MOCK DATA ---
class ChartData {
  final String name;
  final double revenue;
  final double profit;
  ChartData(this.name, this.revenue, this.profit);
}

final List<ChartData> revenueData = [
  ChartData('T2', 15000000, 7000000),
  ChartData('T3', 12000000, 4500000),
  ChartData('T4', 18000000, 9000000),
  ChartData('T5', 16500000, 8000000),
  ChartData('T6', 21000000, 11000000),
  ChartData('T7', 25000000, 14000000),
  ChartData('CN', 23000000, 12500000),
];

class StationData {
  final String name;
  final double value;
  final Color color;
  StationData(this.name, this.value, this.color);
}

final List<StationData> stationData = [
  StationData('Trạm Quận 1', 450, kPrimaryColor),
  StationData('Trạm Tân Bình', 300, kSecondaryColor),
  StationData('Trạm Thủ Đức', 150, const Color(0xFF8B5CF6)),
  StationData('Trạm Quận 7', 100, const Color(0xFF64748B)),
];

class Transaction {
  final String id;
  final String user;
  final String station;
  final double amount;
  final String status;
  final String time;
  Transaction(
      this.id, this.user, this.station, this.amount, this.status, this.time);
}

final List<Transaction> recentTransactions = [
  Transaction(
      'TRX-9921', 'Nguyễn Văn A', 'Trạm Quận 1', 150000, 'success', '10:30'),
  Transaction(
      'TRX-9922', 'Trần Thị B', 'Trạm Tân Bình', 320000, 'pending', '10:45'),
  Transaction(
      'TRX-9923', 'Lê Hoàng C', 'Trạm Quận 1', 50000, 'failed', '11:00'),
  Transaction(
      'TRX-9924', 'Phạm Minh D', 'Trạm Thủ Đức', 1200000, 'success', '11:15'),
  Transaction(
      'TRX-9925', 'Hoàng Yến E', 'Trạm Quận 7', 75000, 'success', '11:20'),
];

// --- MAIN PAGE ---
class StationPaymentOverviewPage extends StatelessWidget {
  const StationPaymentOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final double totalTransactions =
        stationData.fold(0, (sum, item) => sum + item.value);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          // Background Grid Pattern (Simplified with CustomPainter)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),

          // Ambient Light (Simplified with Gradient Container)
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

          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const HeaderSection(),
                const SizedBox(height: 32),

                // Stats Grid
                LayoutBuilder(builder: (context, constraints) {
                  // Responsive Grid logic
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
                        title: "Tổng Doanh Thu",
                        value: currencyFormat.format(130500000),
                        subtext: "so với tháng trước",
                        trend: "up",
                        trendValue: "12.5%",
                        icon: Icons.attach_money,
                        color: kPrimaryColor,
                      ),
                      StatCard(
                        title: "Lợi Nhuận Ròng",
                        value: currencyFormat.format(68200000),
                        subtext: "so với tháng trước",
                        trend: "up",
                        trendValue: "8.2%",
                        icon: Icons.memory, // CPU icon replacement
                        color: kSuccessColor,
                      ),
                      const StatCard(
                        title: "Tổng Giao Dịch",
                        value: "1,482",
                        subtext: "so với tháng trước",
                        trend: "down",
                        trendValue: "2.1%",
                        icon: Icons.credit_card,
                        color: kSecondaryColor,
                      ),
                      StatCard(
                        title: "Giá Trị Trung Bình",
                        value: currencyFormat.format(88000),
                        subtext: "so với tháng trước",
                        trend: "up",
                        trendValue: "4.3%",
                        icon: Icons.show_chart, // Activity icon replacement
                        color: kWarningColor,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // Charts Section (Area & Pie)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: RevenueChartCard(data: revenueData),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: StationPieChartCard(
                                data: stationData, total: totalTransactions),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          RevenueChartCard(data: revenueData),
                          const SizedBox(height: 24),
                          StationPieChartCard(
                              data: stationData, total: totalTransactions),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 32),

                // Recent Transactions Table
                const RecentTransactionsTable(),
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
            Text(
              "Tổng quan giao dịch",
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isSmallScreen) const SizedBox(height: 16),
        Row(
          children: [
            _buildActionButton(Icons.calendar_today, "THÁNG 5 2024", false),
            const SizedBox(width: 12),
            _buildActionButton(Icons.download, "XUẤT DỮ LIỆU", true),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? null : kSurfaceColor,
        gradient: isPrimary
            ? const LinearGradient(colors: [kPrimaryColor, Color(0xFF7E22CE)])
            : null,
        borderRadius: BorderRadius.circular(4),
        border: isPrimary ? null : Border.all(color: kBorderColor),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: isPrimary ? Colors.white : Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
              color: isPrimary ? Colors.white : Colors.grey[300],
            ),
          ),
        ],
      ),
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
          // Corner accents
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
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      trend == 'up'
                          ? Icons.arrow_outward
                          : Icons.arrow_downward,
                      size: 16,
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
                    Text(
                      subtext,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.grey[500]),
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

class RevenueChartCard extends StatelessWidget {
  final List<ChartData> data;

  const RevenueChartCard({super.key, required this.data});

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
                    "PHÂN TÍCH DÒNG TIỀN",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  _LegendItem(color: kPrimaryColor, label: "DOANH THU"),
                  const SizedBox(width: 16),
                  _LegendItem(color: kSecondaryColor, label: "LỢI NHUẬN"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: kBorderColor, strokeWidth: 1),
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[value.toInt()].name,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000000).toStringAsFixed(0)}M',
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
                lineBarsData: [
                  // Revenue Line
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                            e.key.toDouble(), e.value.revenue.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: kPrimaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor.withOpacity(0.3),
                          kPrimaryColor.withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Profit Line
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) =>
                            FlSpot(e.key.toDouble(), e.value.profit.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: kSecondaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          kSecondaryColor.withOpacity(0.3),
                          kSecondaryColor.withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StationPieChartCard extends StatelessWidget {
  final List<StationData> data;
  final double total;

  const StationPieChartCard(
      {super.key, required this.data, required this.total});

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
                  color: kSecondaryColor,
                  margin: const EdgeInsets.only(right: 8)),
              Text(
                "DOANH THU THEO TRẠM",
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
                    centerSpaceRadius: 70,
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
                        total.toStringAsFixed(0),
                        style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                      const Text(
                        "TỔNG GD",
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
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Text(
                      "${((item.value / total) * 100).toStringAsFixed(0)}%",
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

class RecentTransactionsTable extends StatelessWidget {
  const RecentTransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
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
                      "GIAO DỊCH GẦN ĐÂY",
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
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list,
                          size: 14, color: kPrimaryColor),
                      const SizedBox(width: 4),
                      const Text("BỘ LỌC",
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 48),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.black12),
                dataRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.transparent),
                columnSpacing: 24,
                columns: [
                  _buildDataColumn("MÃ GD"),
                  _buildDataColumn("KHÁCH HÀNG"),
                  _buildDataColumn("TRẠM"),
                  _buildDataColumn("SỐ TIỀN"),
                  _buildDataColumn("TRẠNG THÁI"),
                  _buildDataColumn("THỜI GIAN", numeric: true),
                ],
                dividerThickness: 0.1,
                rows: recentTransactions.map((trx) {
                  return DataRow(
                    cells: [
                      DataCell(Text(trx.id,
                          style: const TextStyle(
                              color: kPrimaryColor, fontFamily: 'monospace'))),
                      DataCell(Text(trx.user,
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Text(trx.station,
                          style: const TextStyle(color: Colors.grey))),
                      DataCell(Text(
                          "${NumberFormat('#,###').format(trx.amount)} đ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                      DataCell(_buildStatusBadge(trx.status)),
                      DataCell(Text(trx.time,
                          style: const TextStyle(
                              color: Colors.grey, fontFamily: 'monospace'))),
                    ],
                  );
                }).toList(),
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

  DataColumn _buildDataColumn(String label, {bool numeric = false}) {
    return DataColumn(
      label: Text(label,
          style: const TextStyle(
              color: Colors.grey, fontSize: 12, letterSpacing: 1.0)),
      numeric: numeric,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'success':
        bg = kSuccessColor.withOpacity(0.1);
        text = kSuccessColor;
        label = 'Thành công';
        break;
      case 'pending':
        bg = kWarningColor.withOpacity(0.1);
        text = kWarningColor;
        label = 'Đang xử lý';
        break;
      case 'failed':
      default:
        bg = kErrorColor.withOpacity(0.1);
        text = kErrorColor;
        label = 'Thất bại';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: text.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color, blurRadius: 4)]),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}

// Custom Painter for Background Grid
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
