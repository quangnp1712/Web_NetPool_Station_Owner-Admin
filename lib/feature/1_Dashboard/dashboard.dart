import 'package:flutter/material.dart';

// --- Data Models ---

class Station {
  final int id;
  final String name;
  final String district;
  final int capacity;
  final String status;
  final String revenue;
  final int bookings;
  final int pending;
  final String imgUrl;

  Station({
    required this.id,
    required this.name,
    required this.district,
    required this.capacity,
    required this.status,
    required this.revenue,
    required this.bookings,
    required this.pending,
    required this.imgUrl,
  });
}

class ResourceConfig {
  final String name;
  final String type;
  final IconData icon;

  ResourceConfig(this.name, this.type, this.icon);
}

// --- Main Page ---

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String activeTab = "Tổng quan";

  final List<Station> stations = [
    Station(
      id: 1,
      name: "CyberCore Q7 - Stadium",
      district: "Quận 7, TP.HCM",
      capacity: 120,
      status: "Open",
      revenue: "12.500.000 ₫",
      bookings: 45,
      pending: 3,
      imgUrl:
          "https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=400&auto=format&fit=crop",
    ),
    Station(
      id: 2,
      name: "CyberCore Gò Vấp",
      district: "Gò Vấp, TP.HCM",
      capacity: 80,
      status: "Open",
      revenue: "8.200.000 ₫",
      bookings: 32,
      pending: 0,
      imgUrl:
          "https://images.unsplash.com/photo-1598550476439-c94837556ca2?q=80&w=400&auto=format&fit=crop",
    ),
    Station(
      id: 3,
      name: "CyberCore Bình Thạnh",
      district: "Bình Thạnh, TP.HCM",
      capacity: 90,
      status: "Open",
      revenue: "9.800.000 ₫",
      bookings: 40,
      pending: 5,
      imgUrl:
          "https://images.unsplash.com/photo-1552820728-8b83bb6b773f?q=80&w=400&auto=format&fit=crop",
    ),
    Station(
      id: 4,
      name: "CyberCore Thủ Đức (Bảo trì)",
      district: "Thủ Đức, TP.HCM",
      capacity: 52,
      status: "Closed",
      revenue: "0 ₫",
      bookings: 0,
      pending: 0,
      imgUrl:
          "https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=400&auto=format&fit=crop",
    ),
  ];

  final List<ResourceConfig> configs = [
    ResourceConfig("RTX 4060 Ti", "VGA", Icons.memory),
    ResourceConfig("Core i7 13th", "CPU", Icons.memory),
    ResourceConfig("PS5 Standard", "Console", Icons.gamepad),
    ResourceConfig("Bàn Aileex", "Billiards", Icons.layers),
    ResourceConfig("32 inch 165Hz", "Monitor", Icons.monitor),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFF121212), // Ensure background is dark if not set by parent theme
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Section ---
                _buildHeader(),
                const SizedBox(height: 24),

                // --- Tabs ---
                _buildTabs(),
                const SizedBox(height: 24),

                // --- Stats Grid ---
                _buildStatsGrid(),
                const SizedBox(height: 24),

                // --- Main Content (Responsive Row/Column) ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      // Desktop Layout
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                const SimpleRevenueChart(),
                                const SizedBox(height: 24),
                                _buildStationListSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildAlertsCard(),
                                const SizedBox(height: 24),
                                _buildConfigsCard(),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile/Tablet Layout
                      return Column(
                        children: [
                          const SimpleRevenueChart(),
                          const SizedBox(height: 24),
                          _buildStationListSection(),
                          const SizedBox(height: 24),
                          _buildAlertsCard(),
                          const SizedBox(height: 24),
                          _buildConfigsCard(),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFFA020F0), width: 2),
                    color: const Color(0xFF2A2A2A),
                    image: const DecorationImage(
                      image: NetworkImage(
                          "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "CyberCore Network",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(text: "Chủ sở hữu: "),
                          TextSpan(
                              text: "Nguyễn Văn Tuấn",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.business,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text("4 Station",
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(width: 16),
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text("Station đang hoạt động",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (isMobile) const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA020F0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 8,
                shadowColor: const Color(0xFFA020F0).withOpacity(0.4),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Thêm Station Mới",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      "Tổng quan",
      "Quản lý Stations",
      "Lịch Booking",
      "Tài chính & Ví",
      "Báo cáo"
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isActive = activeTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => activeTab = tab),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]
                      : null,
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth - 32) / 3,
            child: const SummaryCard(
              label: "Tổng Doanh Thu",
              value: "45.2M ₫",
              subText: "Hôm nay",
              icon: Icons.account_balance_wallet,
              trend: 12.5,
              color: Colors.green,
            ),
          ),
          SizedBox(
            width: isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth - 32) / 3,
            child: const SummaryCard(
              label: "Lịch Đặt Mới",
              value: "128",
              subText: "Đang chờ xử lý: 14",
              icon: Icons.calendar_month,
              trend: 8.2,
              color: Color(0xFFA020F0),
            ),
          ),
          SizedBox(
            width: isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth - 32) / 3,
            child: const SummaryCard(
              label: "Đánh Giá TB",
              value: "4.8/5.0",
              subText: "Dựa trên 850+ reviews",
              icon: Icons.star,
              trend: 0.5,
              color: Colors.amber,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStationListSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.business, color: Color(0xFFA020F0)),
                SizedBox(width: 8),
                Text("Danh sách Station",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            DropdownButton<String>(
              value: "Tất cả trạng thái",
              dropdownColor: const Color(0xFF1E1E1E),
              underline: Container(),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: ["Tất cả trạng thái", "Đang mở cửa", "Đóng cửa"]
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...stations.map((s) => StationListItem(station: s)),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: Colors.grey.shade800,
                style: BorderStyle
                    .solid), // Changed to solid for better visibility in flutter
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: Colors.grey.shade400,
          ),
          child: const SizedBox(
            width: double.infinity,
            child: Center(child: Text("Xem toàn bộ danh sách Station")),
          ),
        )
      ],
    );
  }

  Widget _buildAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text("Cần chú ý (2)",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            title: "CyberCore Thủ Đức",
            content: "Đang đóng cửa trên ứng dụng (Không nhận booking).",
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            title: "Booking Chờ Duyệt",
            content: "Có 5 đơn đặt chỗ mới chưa được xác nhận trong 15p qua.",
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
      {required String title, required String content, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(content,
              style: TextStyle(color: color.withOpacity(0.6), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildConfigsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory, color: Color(0xFFA020F0), size: 18),
              SizedBox(width: 8),
              Text("Dịch vụ & Cấu hình",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Công suất Đặt chỗ",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("248/342 (72%)",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.72,
              backgroundColor: Colors.grey.shade800,
              color: const Color(0xFFA020F0),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Chips
          const Text("TIỆN ÍCH NỔI BẬT",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: configs
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 10, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(item.type,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text("Quản lý Chi tiết Cấu hình",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final IconData icon;
  final double trend;
  final Color color;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subText,
    required this.icon,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip
          .antiAlias, // Ensures content doesn't bleed out of rounded corners
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Stack(
        children: [
          // Background Glow Effect - FIX: Increased size and blur
          Positioned(
            right: -50,
            top: -80,
            child: Container(
              width: 200, // Tăng kích thước
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.01),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 300, // Tăng độ mờ lên cao
                      spreadRadius: 20)
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend > 0
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${trend > 0 ? '+' : ''}$trend%",
                          style: TextStyle(
                            color: trend > 0
                                ? Colors.green.shade400
                                : Colors.red.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          trend > 0 ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: trend > 0
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(value,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(subText,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class StationListItem extends StatelessWidget {
  final Station station;

  const StationListItem({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final isOpen = station.status == "Open";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Image
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade800,
                  image: DecorationImage(
                    image: NetworkImage(station.imgUrl),
                    fit: BoxFit.cover,
                    onError: (e, s) {}, // Handle error silently
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.red,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(station.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(station.district,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monitor, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${station.capacity} chỗ",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats (Hidden on very small screens if needed, but here we keep flexible)
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Doanh thu hôm nay",
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(station.revenue,
                  style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4ADE80))),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Booking",
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Row(
                children: [
                  Text("${station.bookings}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  if (station.pending > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class SimpleRevenueChart extends StatelessWidget {
  const SimpleRevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'day': 'T2', 'value': 0.35},
      {'day': 'T3', 'value': 0.45},
      {'day': 'T4', 'value': 0.30},
      {'day': 'T5', 'value': 0.60},
      {'day': 'T6', 'value': 0.75},
      {'day': 'T7', 'value': 0.95},
      {'day': 'CN', 'value': 0.80},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: Color(0xFFA020F0), size: 20),
                      SizedBox(width: 8),
                      Text("Doanh thu tuần này",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      children: [
                        TextSpan(text: "Tổng thu: "),
                        TextSpan(
                            text: "42.000.000 ₫",
                            style: TextStyle(
                                color: Color(0xFF4ADE80),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: const Row(
                  children: [
                    Text("7 ngày qua",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // FIX: Tăng chiều cao container để tránh Overflow
          SizedBox(
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                // FIX: Tính toán chiều cao cột dựa trên maxBarHeight nhỏ hơn chiều cao tổng để chừa chỗ cho text
                const double maxBarHeight = 180.0;
                final height = (item['value'] as double) * maxBarHeight;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: height,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFFA020F0), Color(0xFFC084FC)],
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(item['day'] as String,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
