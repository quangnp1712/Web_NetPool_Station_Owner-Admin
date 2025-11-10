import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Account_Admin_Management/9.1_Account_Admin_List/model/admin_list_model.dart';

/// Lớp Nguồn dữ liệu (Data Source) cho PaginatedDataTable2
/// Nó quản lý danh sách, sắp xếp, và tạo các hàng (rows)
class AdminDataSource extends DataTableSource {
  List<AdminListModel> _AdminList = []; // Sửa: Dữ liệu của trang hiện tại
  final BuildContext context;

  // --- THÊM: Biến cho phân trang ---
  int _totalRows = 0; // Tổng số data trên server
  int _pageOffset = 0; // Vị trí bắt đầu của trang hiện tại
  // -------------------------------

  AdminDataSource({
    required this.context,
    required List<AdminListModel> initialData,
  }) {
    _AdminList = initialData;
  }

  /// Cập nhật dữ liệu (ví dụ: khi BLoC load xong)
  // SỬA: Thêm totalRows và pageOffset
  void updateData(List<AdminListModel> newList, int totalRows, int pageOffset) {
    _AdminList = newList;
    _totalRows = totalRows;
    _pageOffset = pageOffset;
    notifyListeners(); // Thông báo cho DataTable2 biết dữ liệu đã thay đổi
  }

  /// Hàm sắp xếp (đã chuyển vào đây)
  void sort<T extends Comparable>(
    T? Function(AdminListModel d) getField,
    bool ascending,
  ) {
    _AdminList.sort((a, b) {
      // Sửa: Sắp xếp _AdminList
      final aValue = getField(a);
      final bValue = getField(b);

      // Xử lý null an toàn
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return ascending ? -1 : 1;
      if (bValue == null) return ascending ? 1 : -1;

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners(); // Thông báo cho DataTable2 biết thứ tự đã thay đổi
  }

  // --- WIDGET CON: CHIP "HOẠT ĐỘNG" (đã chuyển vào đây) ---
  Widget _buildStatusChip(String statusCode, String statusName) {
    bool isActive = (statusCode == "ENABLE");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.activeStatus : Colors.grey,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        statusName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // --- Ghi đè (Override) các hàm bắt buộc của DataTableSource ---

  @override
  DataRow? getRow(int index) {
    // SỬA: Logic lấy hàng cho phân trang
    // 'index' là index tuyệt đối (ví dụ: 0-99)
    // 'localIndex' là index tương đối của trang hiện tại (ví dụ: 0-9)
    final int localIndex = index - _pageOffset;

    // Nếu index không thuộc trang này, trả về null (DataTable2 sẽ hiển thị loading)
    if (localIndex < 0 || localIndex >= _AdminList.length) {
      return null;
    }

    final data = _AdminList[localIndex];

    // Đây là logic tạo DataCell của bạn
    return DataRow(
      color: WidgetStateProperty.all(AppColors.bgCard),
      cells: [
        // Cell 1: Tên
        DataCell(Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(data.avatar.toString()),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Text(data.username.toString()),
          ],
        )),
        // Cell 2: SĐT (Thêm Email theo gợi ý trước)
        DataCell(Text(data.email.toString())),
        // Cell 3: Trạng thái
        DataCell(
            _buildStatusChip(data.statusCode ?? "", data.statusName ?? "")),
        // Cell 4: Chức năng
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
              onPressed: () {
                // TODO: Xử lý sự kiện sửa
              },
              tooltip: "Chỉnh sửa",
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                // TODO: Xử lý sự kiện xóa
              },
              tooltip: "Xóa",
            ),
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => _totalRows; // Sửa: Trả về tổng số hàng trên server

  @override
  bool get isRowCountApproximate =>
      false; // Luôn là false nếu bạn biết chính xác

  @override
  int get selectedRowCount => 0; // Số hàng đang được chọn (không dùng)
}
