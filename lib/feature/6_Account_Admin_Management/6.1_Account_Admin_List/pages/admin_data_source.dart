import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/bloc/admin_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.1_Account_Admin_List/model/admin_list_model.dart';

/// Lớp Nguồn dữ liệu (Data Source) cho PaginatedDataTable2
/// Nó quản lý danh sách, sắp xếp, và tạo các hàng (rows)
class AdminDataSource extends DataTableSource {
  List<AdminListModel> _adminList = [];
  final BuildContext context;
  final AdminListBloc adminListBloc;
  // --- THÊM: Biến cho phân trang ---

  int _totalRows = 0;
  int _pageOffset = 0;

  AdminDataSource({
    required this.context,
    required this.adminListBloc,
    required List<AdminListModel> initialData,
  }) {
    _adminList = initialData;
  }

  void updateData(List<AdminListModel> newList, int totalRows, int pageOffset) {
    _adminList = newList;
    _totalRows = totalRows;
    _pageOffset = pageOffset;
    notifyListeners();
  }

  void sort<T extends Comparable>(
    T? Function(AdminListModel d) getField,
    bool ascending,
  ) {
    _adminList.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return ascending ? -1 : 1;
      if (bValue == null) return ascending ? 1 : -1;
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  // --- Widget con: Chip Status ---
  Widget _buildStatusChip(String status, String statusName) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'ENABLE':
        color = Colors.green;
        break;
      case 'INACTIVE':
      case 'DISABLE':
        color = Colors.redAccent;
        break;
      case 'PENDING':
        color = Colors.orangeAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusName.isNotEmpty ? statusName : status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  DataRow? getRow(int index) {
    final int localIndex = index - _pageOffset;
    if (localIndex < 0 || localIndex >= _adminList.length) {
      return DataRow.byIndex(
          index: index,
          color: WidgetStateProperty.all(
              AppColors.containerBackground), // Giữ màu nền
          cells: [
            // 6
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
          ]);
    }
    final data = _adminList[localIndex];

    return DataRow(
      color: WidgetStateProperty.all(AppColors.bgCard),
      cells: [
        // Cell 1: Avatar + Tên
        DataCell(Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: (data.avatar != null && data.avatar!.isNotEmpty)
                  ? NetworkImage(data.avatar!)
                  : null,
              child: (data.avatar == null || data.avatar!.isEmpty)
                  ? Text(
                      (data.username != null && data.username!.isNotEmpty)
                          ? data.username![0].toUpperCase()
                          : "A",
                      style: const TextStyle(color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.username ?? "Chưa cập nhật",
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // Tùy chọn: Tối đa 2 dòng
              ),
            ),
          ],
        )),

        // Cell 2: Email
        DataCell(Text(data.email ?? "")),

        // Cell 3: SĐT
        DataCell(Text(data.phone ?? "")),

        // Cell 4: Station Quản lý
        DataCell(Text(
          data.stationName ?? "Chưa gán",
          style: TextStyle(
              color: data.stationName == null ? Colors.grey : Colors.white),
        )),

        // Cell 5: Trạng thái
        DataCell(_buildStatusChip(
            data.statusCode ?? "UNKNOWN", data.statusName ?? "")),

        // Cell 6: Chức năng
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
  int get rowCount => _totalRows;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}
