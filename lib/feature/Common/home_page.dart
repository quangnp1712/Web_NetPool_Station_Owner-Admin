import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String HomePageRoute = "/home";
  @override
  State<HomePage> createState() => _HomePageState();
}

// --- ĐỊNH NGHĨA MÀU SẮC ---
const Color _primaryColor = Color(0xFFC53BFF); // Màu tím/magenta chủ đạo
const Color _sidebarBg = Color(0xFF1A1A1A);
const Color _mainBg = Color(0xFF0F0F0F);
const Color _contentBg = Color(0xFF222222);
const Color _activeGreen = Color(0xFF00C853);
const Color _borderColor = Color(0xFF3C3C3C);

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar (Menu bên trái)
          _buildSidebar(),
          // 2. Main Content (Nội dung chính bên phải)
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CHO SIDEBAR ---
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: _sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'NETPOOL STATION BOOKING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const Divider(color: _borderColor, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                _buildSidebarItem(Icons.dashboard_rounded, 'Tổng quan'),
                // Mục có menu con
                ExpansionTile(
                  leading: Icon(Icons.account_circle, color: Colors.white),
                  title: Text('Quản lý Tài khoản',
                      style: TextStyle(color: Colors.white)),
                  initiallyExpanded: true, // Mở sẵn vì đang ở trang con
                  childrenPadding: const EdgeInsets.only(left: 30.0),
                  children: [
                    _buildSidebarSubItem('Danh sách tài khoản',
                        isSelected: true),
                    _buildSidebarSubItem('Tạo tài khoản'),
                  ],
                ),
                _buildSidebarItem(Icons.store_rounded, 'Quản lý Station'),
                _buildSidebarItem(Icons.people_rounded, 'Quản lý Nhân viên'),
              ],
            ),
          ),
          const Divider(color: _borderColor, height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildSidebarItem(Icons.logout, 'ĐĂNG XUẤT', isLogout: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
            color: isLogout ? Colors.redAccent : Colors.white,
            fontWeight: isLogout ? FontWeight.bold : FontWeight.normal),
      ),
      onTap: () {},
    );
  }

  Widget _buildSidebarSubItem(String title, {bool isSelected = false}) {
    return ListTile(
      title: Text(
        '−  $title',
        style: TextStyle(
          color: isSelected ? _primaryColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {},
    );
  }

  // --- WIDGET CHO MAIN CONTENT ---
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Breadcrumb + User Info)
          _buildHeader(),
          const SizedBox(height: 24),
          // 2. Content Body (Filter + Table)
          Expanded(
            child: _buildContentBody(),
          ),
          const SizedBox(height: 24),
          // 3. Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Breadcrumb
        Text(
          'Quản lý tài khoản / Danh sách tài khoản',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // User Info
        Row(
          children: [
            IconButton(
              icon: Badge(
                label: Text('2'),
                child: Icon(Icons.notifications_rounded, color: Colors.white),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              // Bạn có thể thay bằng NetworkImage
              backgroundColor: _primaryColor,
              child: Text('PQ'),
            ),
            const SizedBox(width: 12),
            Text(
              'Phương Quang',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentBody() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _contentBg,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          // 1. Filter bar
          _buildFilterBar(),
          const SizedBox(height: 24),
          // 2. Data Table
          Expanded(
            child: SingleChildScrollView(
              child: _buildDataTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    // Sử dụng Wrap để các item tự động xuống hàng trên màn hình hẹp
    return Wrap(
      spacing: 16.0, // Khoảng cách ngang
      runSpacing: 16.0, // Khoảng cách dọc
      children: [
        // Search bar
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên tài khoản',
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            ),
          ),
        ),
        // Dropdown "Tình trạng"
        SizedBox(
          width: 200,
          child: DropdownButtonFormField(
            decoration: InputDecoration(),
            hint: Text('Tình trạng'),
            items: [], // Thêm các DropdownMenuItem ở đây
            onChanged: (value) {},
          ),
        ),
        // Dropdown "Chức vụ"
        SizedBox(
          width: 200,
          child: DropdownButtonFormField(
            decoration: InputDecoration(),
            hint: Text('Chức vụ'),
            items: [], // Thêm các DropdownMenuItem ở đây
            onChanged: (value) {},
          ),
        ),
        // Spacer để đẩy nút qua phải
        // Trên web, dùng Wrap không cần Spacer, ta set alignment ở Row cha
        // Ở đây ta cứ để nó flow tự nhiên

        // Button "TẠO TÀI KHOẢN"
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.add_circle_outline_rounded),
          label: Text('TẠO TÀI KHOẢN'),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    // Style cho header của bảng
    final headerStyle =
        TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    return Container(
      width: double.infinity,
      child: DataTable(
        // Màu header
        headingRowColor:
            MaterialStateProperty.all(_primaryColor.withOpacity(0.5)),
        headingTextStyle: headerStyle,
        columns: const [
          DataColumn(label: Text('TÊN')),
          DataColumn(label: Text('SĐT')),
          DataColumn(label: Text('TRẠNG THÁI')),
          DataColumn(label: Text('CHỨC NĂNG')),
        ],
        rows: [
          // Dòng dữ liệu mẫu
          DataRow(
            cells: [
              // Tên
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade800,
                      child: Text('PQ'),
                      radius: 16,
                    ),
                    const SizedBox(width: 12),
                    Text('NGUYỄN PHƯƠNG QUANG'),
                  ],
                ),
              ),
              // SĐT
              DataCell(Text('090xxxxxxx')),
              // Trạng thái
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _activeGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'HOẠT ĐỘNG',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              // Chức năng
              DataCell(
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {}),
                    IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
          // Thêm các DataRow khác ở đây
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}
