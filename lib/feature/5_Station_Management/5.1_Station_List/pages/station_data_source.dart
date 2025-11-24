import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/bloc/station_list_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.1_Station_List/model/station_list_model.dart';

/// Lớp Nguồn dữ liệu (Data Source) cho PaginatedDataTable2
/// Nó quản lý danh sách, sắp xếp, và tạo các hàng (rows)
class StationDataSource extends DataTableSource {
  List<StationListModel> _stationList = []; // Sửa: Dữ liệu của trang hiện tại
  final BuildContext context;
  final StationListBloc stationListBloc;
  // --- THÊM: Biến cho phân trang ---
  int _totalRows = 0; // Tổng số data trên server
  int _pageOffset = 0; // Vị trí bắt đầu của trang hiện tại
  // -------------------------------

  StationDataSource({
    required this.context,
    required this.stationListBloc,
    required List<StationListModel> initialData,
  }) {
    _stationList = initialData;
  }

  /// Cập nhật dữ liệu (ví dụ: khi BLoC load xong)
  // SỬA: Thêm totalRows và pageOffset
  void updateData(
      List<StationListModel> newList, int totalRows, int pageOffset) {
    _stationList = newList;
    _totalRows = totalRows;
    _pageOffset = pageOffset;
    notifyListeners(); // Thông báo cho DataTable2 biết dữ liệu đã thay đổi
  }

  /// Hàm sắp xếp (đã chuyển vào đây)
  void sort<T extends Comparable>(
    T? Function(StationListModel d) getField,
    bool ascending,
  ) {
    _stationList.sort((a, b) {
      // Sửa: Sắp xếp _StationList
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
    bool isActive = (statusCode == "ACTIVE");
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

// --- THÊM MỚI: HÀM HIỂN THỊ POPUP LÝ DO ---
  void _showRejectReasonDialog(BuildContext context, MetaDataModel? metadata) {
    if (metadata == null) return;

    // Format ngày tháng (ví dụ: 04/11/2025)
    final String formattedDate = metadata.rejectAt != null
        ? DateFormat('dd/MM/yyyy').format(metadata.rejectAt!)
        : "Không rõ";

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.inputBackground, // Nền đen
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text(
                'Lý do bị từ chối',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Giúp dialog co lại
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metadata.rejectReason == null || metadata.rejectReason == ""
                    ? "Không có lý do."
                    : metadata.rejectReason!,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Ngày từ chối: $formattedDate",
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Đã hiểu',
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  DataRow? getRow(int index) {
    // SỬA: Logic lấy hàng cho phân trang
    // 'index' là index tuyệt đối (ví dụ: 0-99)
    // 'localIndex' là index tương đối của trang hiện tại (ví dụ: 0-9)
    final int localIndex = index - _pageOffset;

    // Nếu index không thuộc trang này, trả về null (DataTable2 sẽ hiển thị loading)
    if (localIndex < 0 || localIndex >= _stationList.length) {
      // Trả về một hàng trống (với chiều cao) để giữ layout
      return DataRow.byIndex(
          index: index,
          color: WidgetStateProperty.all(
              AppColors.containerBackground), // Giữ màu nền
          cells: [
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
            DataCell(Container()),
          ]);
    }

    final data = _stationList[localIndex];

    // Đây là logic tạo DataCell của bạn
    return DataRow(
      color: WidgetStateProperty.all(AppColors.bgCard),
      cells: [
        // Cell 1: Tên station
        DataCell(Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(data.avatar.toString()),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.stationName.toString(),
                overflow: TextOverflow.ellipsis, // Tùy chọn: Thêm ...
                maxLines: 2, // Tùy chọn: Tối đa 2 dòng
              ),
            ),
          ],
        )),

        // Cell 2: Hotline
        DataCell(Text(data.hotline.toString())),

        // Cell 3: district
        DataCell(Text(data.district.toString())),

        // Cell 4: province
        DataCell(Text(data.province.toString())),

        // Cell 5: Trạng thái
        DataCell(
            _buildStatusChip(data.statusCode ?? "", data.statusName ?? "")),
        // Cell 6: Chức năng
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
              onPressed: () {
                stationListBloc
                    .add(ShowStationDetailEvent(stationId: data.stationId));
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
            Visibility(
              // Chỉ hiển thị khi bị từ chối
              visible: data.statusCode == "REJECT",
              child: IconButton(
                icon:
                    const Icon(Icons.info_outline, color: Colors.orangeAccent),
                onPressed: () {
                  // Gọi hàm hiển thị popup
                  _showRejectReasonDialog(context, data.metadata);
                },
                tooltip: "Xem lý do từ chối",
              ),
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
