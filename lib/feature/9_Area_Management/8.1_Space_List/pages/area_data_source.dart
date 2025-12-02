import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/bloc/area_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/model/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/8.1_Space_List/services/hex_color_extension.dart';

class AreaDataSource extends DataTableSource {
  List<AreaModel> _areaList = [];
  StationSpaceModel? _currentSpace;
  final BuildContext context;
  AreaListBloc areaListBloc;

  int _totalRows = 0;
  int _pageOffset = 0;

  AreaDataSource({
    required this.context,
    required this.areaListBloc,
    required List<AreaModel> initialData,
  }) {
    _areaList = initialData;
    _totalRows = initialData.length;
  }

  /// Cập nhật dữ liệu Area (khi chọn Space mới hoặc thay đổi trang)
  void updateData(
    List<AreaModel> newList,
    int totalRows,
    int pageOffset,
    StationSpaceModel? currentSpace,
  ) {
    _areaList = newList;
    _totalRows = totalRows;
    _pageOffset = pageOffset;
    _currentSpace = currentSpace;
    notifyListeners();
  }

  /// Hàm sắp xếp (Logic giống StationDataSource)
  void sort<T extends Comparable>(
    T? Function(AreaModel d) getField,
    bool ascending,
  ) {
    _areaList.sort((a, b) {
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

  // --- WIDGET CON: CHIP "TRẠNG THÁI" ---
  Widget _buildStatusChip(String? statusCode, String? statusName) {
    bool isActive = (statusCode == "ACTIVE");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
          color: isActive
              ? AppColors.statusActiveBg.withOpacity(0.3)
              : AppColors.statusInactiveBg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              color: isActive
                  ? AppColors.statusActiveBg
                  : AppColors.statusInactiveBg.withOpacity(0.5))),
      child: Text(
        statusName ?? "Không rõ",
        style: TextStyle(
          color: isActive
              ? AppColors.statusActiveText
              : AppColors.statusInactiveText,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  DataRow? getRow(int index) {
    // Logic lấy row cho phân trang: index tuyệt đối -> index tương đối
    final int localIndex = index - _pageOffset;

    if (localIndex < 0 || localIndex >= _areaList.length) {
      // Trả về row trống khi data đang được tải cho trang mới
      return DataRow.byIndex(
          index: index,
          color: WidgetStateProperty.all(
              AppColors.containerBackground), // Giữ màu nền
          cells: [
            // 7
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
          ]);
    }

    final data = _areaList[localIndex];
    // Lấy màu Space an toàn
    final currentSpaceColor =
        _currentSpace?.space?.metadata?.bgColor.toColor(fallback: Colors.grey);

    return DataRow(
      color: MaterialStateProperty.all(AppColors.containerBackground),
      cells: [
        // Cell 1: # (STT)
        DataCell(Text((index + 1).toString(),
            style: const TextStyle(color: AppColors.textHint))),

        // Cell 2: Mã khu vực
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
          ),
          child: Text(data.areaCode ?? "--",
              style: const TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: 'monospace',
                  fontSize: 13)),
        )),

        // Cell 3: Tên khu vực
        DataCell(Text(data.areaName ?? "Chưa cập nhật",
            style: const TextStyle(
                color: AppColors.textMain, fontWeight: FontWeight.w500))),

        // Cell 4: Space
        DataCell(Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentSpaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: currentSpaceColor!, blurRadius: 4)
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_currentSpace?.spaceName ?? "--",
                style: const TextStyle(color: AppColors.textHint)),
          ],
        )),

        // Cell 5: Giá
        DataCell(Text("${data.price?.toStringAsFixed(0) ?? 0} đ",
            style: const TextStyle(
                color: Colors.greenAccent, fontWeight: FontWeight.bold))),

        // Cell 6: Trạng thái
        DataCell(_buildStatusChip(data.statusCode, data.statusName)),

        // Cell 7: Chức năng
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.blueAccent, size: 20),
              onPressed: () {
                // TODO: Chuyển sang trang chỉnh sửa Area
              },
              tooltip: "Chỉnh sửa",
              splashRadius: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () {
                // TODO: Xử lý sự kiện xóa
              },
              tooltip: "Xóa",
              splashRadius: 20,
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
