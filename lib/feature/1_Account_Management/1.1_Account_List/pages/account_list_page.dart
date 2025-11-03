import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/1.1_Account_List/bloc/account_list_bloc.dart';

//! Account List - DS người chơi !//

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  final AccountListBloc accountListBloc = AccountListBloc();

  @override
  void initState() {
    accountListBloc.add(AccountListInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountListBloc, AccountListState>(
      bloc: accountListBloc,
      listenWhen: (previous, current) => current is AccountListActionState,
      buildWhen: (previous, current) => current is! AccountListActionState,
      listener: (context, state) {
        switch (state.runtimeType) {}
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
            Container(
              // Thêm padding cho toàn bộ body
              padding: const EdgeInsets.all(40.0),
              color: AppColors.mainBackground, // Màu nền tối bên ngoài
              alignment: Alignment.center,
              child: Container(
                // Đây là Container chính với hiệu ứng glow
                decoration: BoxDecoration(
                  color: AppColors.containerBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    // Áp dụng chính xác thông số Drop Shadow bạn đã cung cấp
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 20.0,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 1. Hàng Filter (Tìm kiếm, Dropdown, Button)
                    _buildFilterBar(),

                    // 2. Bảng Dữ liệu
                    _buildDataTable(),
                  ],
                ),
              ),
            ),
            // 3. Footer (Copyright)
            _buildFooter(),
          ],
        );
      },
    );
  }

  // --- WIDGET CON: HÀNG FILTER ---
  // --- WIDGET CON: HÀNG FILTER (ĐÃ SỬA) ---
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      // SỬA: Dùng Row để đẩy 2 nhóm (filter và button) ra xa nhau
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Căn trên khi bị xuống hàng
        children: [
          // Nhóm bên trái: Các bộ lọc
          // Dùng Wrap để tự xuống hàng khi không đủ chỗ
          Wrap(
            spacing: 16.0, // Khoảng cách ngang
            runSpacing: 16.0, // Khoảng cách dọc khi xuống hàng
            children: [
              // Ô tìm kiếm
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: TextField(
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm tên tài khoản",
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textHint),
                  ),
                ),
              ),

              // Dropdown "Tình trạng"
              _buildDropdown("Tình trạng", ["Hoạt động", "Bị khóa"]),

              // Dropdown "Chức vụ"
              _buildDropdown("Chức vụ", ["Admin", "Station Owner", "Player"]),
            ],
          ),

          // Nhóm bên phải: Button
          // Thêm Padding để giữ khoảng cách khi Wrap xuống hàng
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "TẠO TÀI KHOẢN",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGlow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: BẢNG DỮ LIỆU ---
  Widget _buildDataTable() {
    // SỬA: Bọc toàn bộ bảng trong Padding
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        // SỬA: Bo tròn cả 4 góc vì bảng không còn sát viền nữa
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          children: [
            // Header của Bảng
            Container(
              color: AppColors.tableHeader,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: const Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text("TÊN",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text("SĐT",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text("TRẠNG THÁI",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text("CHỨC NĂNG",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            // Các hàng dữ liệu (Data Rows)
            // Bọc trong Container để có thể cuộn nếu có nhiều dữ liệu
            SizedBox(
              height: 400, // Giới hạn chiều cao và cho phép cuộn
              // SỬA: Thêm màu nền cho phần body của bảng
              child: Container(
                color: AppColors.containerBackground, // Thêm màu nền này
                child: ListView.builder(
                  itemCount: 4, // Số lượng hàng (giống như ảnh)
                  itemBuilder: (context, index) {
                    return _buildDataRow(
                      name: "NGUYỄN PHƯƠNG QUANG",
                      phone: "090xxxxxxx",
                      isActive: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CON: MỘT HÀNG DỮ LIỆU ---
  Widget _buildDataRow(
      {required String name, required String phone, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Tên
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const CircleAvatar(
                  // Thay bằng ảnh thật của bạn
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150?img=1"),
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(color: AppColors.textWhite)),
              ],
            ),
          ),

          // SĐT
          Expanded(
            flex: 2,
            child:
                Text(phone, style: const TextStyle(color: AppColors.textWhite)),
          ),

          // Trạng thái
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusChip(isActive),
            ),
          ),

          // Chức năng (Edit, Delete buttons)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                  onPressed: () {},
                  tooltip: "Chỉnh sửa",
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {},
                  tooltip: "Xóa",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: CHIP "HOẠT ĐỘNG" ---
  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.activeStatus : Colors.grey,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        isActive ? "HOẠT ĐỘNG" : "BỊ KHÓA",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // --- WIDGET CON: TẠO DROPDOWN ---
  Widget _buildDropdown(String hint, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(color: AppColors.textHint)),
          dropdownColor: AppColors.inputBackground,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textHint),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: const TextStyle(color: AppColors.textWhite)),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  // --- WIDGET CON: FOOTER ---
  Widget _buildFooter() {
    return Center(
      child: Text(
        'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}
