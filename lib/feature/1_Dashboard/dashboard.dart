import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data'; // For Uint8List
import 'dart:ui'; // For PointerDeviceKind

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return StationAdminApp();
  }
}

// --- APP COLORS (CYBER TOKYO THEME) ---
class AppColors {
  static const bgDark = Color(0xFF0C0C0A);
  static const btnPrimary = Color(0xFFAB41F0);
  static const bgLight = Color(0xFFFFFFFF);
  static const btnSecondary = Color(0xFFE0E0E0);
  static const bgCard = Color(0xFF222222);
  static const menuDisable = Color(0xFFDDDDDD);
  static const menuActive = Color(0xFFCB30E0);
  static const menuOnHover = Color(0xFFCB8BFF);

  static const Color primaryGlow = Color(0xFFCB30E0);
  static const Color mainBackground = Color(0xFF121212);
  static const Color containerBackground = Color(0xFF1E1E1E);
  static const Color inputBackground = Color(0xFF2C2C2E);
  static const Color tableHeader = Color(0xFF8630CB);
  static const Color activeStatus = Color(0xFF2EBD59);
  static const Color textWhite = Colors.white;
  static const Color textBlack = Colors.black;
  static const Color textHint = Color(0xFF8A8A8E);

  static const Color border = Color(0xFF333333);
  static const Color textMain = Color(0xFFE2E8F0);
  static const Color primaryBlue = Color(0xFF2563EB);

  static const Color statusActiveBg = Color(0xFF1B5E20);
  static const Color statusActiveText = Color(0xFF4ADE80);
  static const Color statusInactiveBg = Color(0xFF424242);
  static const Color statusInactiveText = Color(0xFFBDBDBD);

  static const Color statusUsing = Color(0xFFDC2626);
  static const Color statusFree = Color(0xFF10B981);
}

// --- MOCK REPOSITORIES & UTILS ---

class StationDetailSharedPref {
  static String getStationId() => "ST-001";
  static void clearStationId() {}
}

class AuthenticationPref {
  static String getRoleCode() => "STATION_OWNER";
}

// Giả lập Repository
class StationDetailRepository {
  Future<Map<String, dynamic>> findDetailStation(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'status': 200,
      'success': true,
      'message': 'Success',
      'body': {
        'data': {
          'stationId': 1,
          'stationCode': 'ST-001',
          'stationName': 'CyberCore Gaming Station',
          'address': '123 Đường Nguyễn Văn Linh',
          'province': 'TP. Hồ Chí Minh',
          'district': 'Quận 7',
          'commune': 'P. Tân Phong',
          'hotline': '0909 123 456',
          'statusCode': 'ACTIVE',
          'statusName': 'Active',
          'avatar':
              'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=2670',
        }
      }
    };
  }

  // Giả lập hàm Update
  Future<Map<String, dynamic>> updateStation(
      StationDetailModel model, String? placeId) async {
    await Future.delayed(
        const Duration(seconds: 2)); // Tăng delay để thấy hiệu ứng loading
    DebugLogger.printLog("Updating station with PlaceId: $placeId");
    return {'status': 200, 'success': true, 'message': 'Updated successfully'};
  }
}

class CityRepository {
  Future<Map<String, dynamic>> getProvinces() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 200, 'success': true, 'body': LocationData.provinces};
  }

  Future<Map<String, dynamic>> getDistricts(int provinceCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = provinceCode == 101
        ? LocationData.districts['HCM']
        : LocationData.districts['HN'];
    return {
      'status': 200,
      'success': true,
      'body': {'districts': list ?? []}
    };
  }

  Future<Map<String, dynamic>> getCommunes(int districtCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = districtCode == 202
        ? LocationData.wards['Q7']
        : LocationData.wards['Q1'];
    return {
      'status': 200,
      'success': true,
      'body': {'wards': list ?? []}
    };
  }
}

// --- MODELS ---

class AutocompleteModel {
  String? address; // Full address from API
  String? shortAddress; // Short address for text field
  String? placeId;
  CompoundModel? compound;
  AutocompleteModel({
    this.address,
    this.shortAddress,
    this.placeId,
    this.compound,
  });

  @override
  String toString() => address ?? '';
}

class CompoundModel {
  String? district;
  String? commune;
  String? province;
  CompoundModel({
    this.district,
    this.commune,
    this.province,
  });

  factory CompoundModel.fromMap(Map<String, dynamic> map) {
    return CompoundModel(
      district: map['district'] != null ? map['district'] as String : null,
      commune: map['commune'] != null ? map['commune'] as String : null,
      province: map['province'] != null ? map['province'] as String : null,
    );
  }
}

class StationDetailModel {
  int? stationId;
  String? avatar;
  String? stationCode;
  String? stationName;
  String? address;
  String? province;
  String? commune;
  String? district;
  String? hotline;
  String? statusCode;
  String? statusName;
  List<MediaModel>? media;
  MetaDataModel? metadata;

  StationDetailModel({
    this.stationId,
    this.avatar,
    this.stationCode,
    this.stationName,
    this.address,
    this.province,
    this.commune,
    this.district,
    this.hotline,
    this.statusCode,
    this.statusName,
    this.media,
    this.metadata,
  });

  factory StationDetailModel.fromMap(Map<String, dynamic> map) {
    return StationDetailModel(
      stationId: map['stationId'],
      avatar: map['avatar'],
      stationCode: map['stationCode'],
      stationName: map['stationName'],
      address: map['address'],
      province: map['province'],
      commune: map['commune'],
      district: map['district'],
      hotline: map['hotline'],
      statusCode: map['statusCode'],
      statusName: map['statusName'],
    );
  }
}

class StationDetailModelResponse {
  StationDetailModel? data;
  StationDetailModelResponse({this.data});
  factory StationDetailModelResponse.fromJson(Map<String, dynamic> json) {
    return StationDetailModelResponse(
        data: json['data'] != null
            ? StationDetailModel.fromMap(json['data'])
            : null);
  }
}

class MediaModel {
  String? url;
  MediaModel({this.url});
}

class MetaDataModel {
  String? rejectReason;
  DateTime? rejectAt;
  MetaDataModel({this.rejectReason, this.rejectAt});
}

class ProvinceModel {
  int code;
  String name;
  ProvinceModel({required this.code, required this.name});
  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
      code: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'],
      name: json['name']);

  @override
  bool operator ==(Object other) =>
      other is ProvinceModel && other.code == code;
  @override
  int get hashCode => code.hashCode;
}

class DistrictModel {
  int code;
  String name;
  DistrictModel({required this.code, required this.name});
  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
      code: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'],
      name: json['name']);

  @override
  bool operator ==(Object other) =>
      other is DistrictModel && other.code == code;
  @override
  int get hashCode => code.hashCode;
}

class CommuneModel {
  int code;
  String name;
  CommuneModel({required this.code, required this.name});
  factory CommuneModel.fromJson(Map<String, dynamic> json) => CommuneModel(
      code: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'],
      name: json['name']);

  @override
  bool operator ==(Object other) => other is CommuneModel && other.code == code;
  @override
  int get hashCode => code.hashCode;
}

// [NEW] Resource Model cho Tài Nguyên
class ResourceModel {
  String id;
  String name;
  String type;
  int quantity;
  String status;

  ResourceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.status,
  });
}

// [NEW] Model cho Space (Loại hình)
class SpaceTypeModel {
  String id;
  String name;
  String description;
  String status;
  IconData icon;

  SpaceTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.icon,
  });
}

// [REUSED] Model cho Area (Khu vực) - Sử dụng StationSpaceModel như trước nhưng đổi tên cho rõ nghĩa nếu cần
// Ở đây mình dùng StationAreaModel cho rõ nghĩa trong code mới
class StationAreaModel {
  String id;
  String name;
  String spaceTypeName; // Thuộc loại hình nào (NET, Bida...)
  int capacity;
  String status; // Full, Available, Maintenance

  StationAreaModel({
    required this.id,
    required this.name,
    required this.spaceTypeName,
    required this.capacity,
    required this.status,
  });
}

// --- MOCK DATA ---
class LocationData {
  static final List<Map<String, dynamic>> provinces = [
    {'id': 101, 'name': 'TP. Hồ Chí Minh'},
    {'id': 102, 'name': 'TP. Hà Nội'},
  ];
  static final Map<String, List<Map<String, dynamic>>> districts = {
    'HCM': [
      {'id': 201, 'name': 'Quận 1'},
      {'id': 202, 'name': 'Quận 7'}
    ],
    'HN': [
      {'id': 203, 'name': 'Q. Hoàn Kiếm'}
    ],
  };
  static final Map<String, List<Map<String, dynamic>>> wards = {
    'Q7': [
      {'id': 301, 'name': 'P. Tân Phong'},
      {'id': 302, 'name': 'P. Phú Mỹ Hưng'}
    ],
    'Q1': [
      {'id': 303, 'name': 'P. Bến Nghé'}
    ],
  };
}

void main() {
  runApp(const StationAdminApp());
}

class StationAdminApp extends StatelessWidget {
  const StationAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.mainBackground,
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const StationDetailScreen(),
    );
  }
}

// ======================= SCREEN =======================

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({super.key});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  String _activeTab = 'overview';
  String _userRole = 'STATION-OWNER';

  // Tách 2 trạng thái loading
  bool _isHeaderLoading = true; // Loading toàn màn hình (cho Header)
  bool _isContentLoading = false; // Loading riêng cho Content (Skeleton)

  StationDetailModel? _stationData;
  String _fullAddressDisplay = "";

  List<SpaceTypeModel> _spaceTypes = [];
  List<StationAreaModel> _areas = [];
  List<ResourceModel> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadDataSequence();
  }

  // Hàm điều phối thứ tự load
  Future<void> _loadDataSequence() async {
    // 1. Load Header trước (Chặn toàn màn hình)
    await _loadStationHeader();

    // 2. Sau khi có Header, hiện giao diện chính và bắt đầu load Content (Skeleton)
    if (mounted) {
      setState(() {
        _isContentLoading = true;
      });

      // Giả lập delay 7s cho content animation
      await Future.delayed(const Duration(seconds: 7));

      _initMockData(); // Load data thật vào list

      if (mounted) {
        setState(() {
          _isContentLoading = false; // Tắt Skeleton
        });
      }
    }
  }

  Future<void> _loadStationHeader() async {
    setState(() => _isHeaderLoading = true);
    try {
      final res = await StationDetailRepository().findDetailStation("ST-001");
      final data = StationDetailModelResponse.fromJson(res['body']);
      if (mounted) {
        setState(() {
          _stationData = data.data;
          _fullAddressDisplay =
              "${_stationData?.address}, ${_stationData?.commune}, ${_stationData?.district}, ${_stationData?.province}";
          _isHeaderLoading = false;
        });
      }
    } catch (e) {
      DebugLogger.printLog("Error loading station: $e");
      if (mounted) setState(() => _isHeaderLoading = false);
    }
  }

  void _initMockData() {
    // 1. Mock Space Types (Loại hình)
    setState(() {
      _spaceTypes = [
        SpaceTypeModel(
          id: 'SP01',
          name: 'Cyber Game (NET)',
          description: 'Dịch vụ Internet tốc độ cao, PC cấu hình mạnh',
          status: 'Active',
          icon: Icons.computer,
        ),
        SpaceTypeModel(
          id: 'SP02',
          name: 'Billiards (Bida)',
          description: 'Bàn bida lỗ, bida phăng chuẩn thi đấu',
          status: 'Active',
          icon: Icons.sports_tennis,
        ),
        SpaceTypeModel(
          id: 'SP03',
          name: 'Playstation 5',
          description: 'Máy PS5, màn hình 4K 120Hz',
          status: 'Maintenance',
          icon: Icons.gamepad,
        ),
      ];

      // 2. Mock Areas (Khu vực)
      _areas = [
        StationAreaModel(
            id: 'A01',
            name: 'Tầng Trệt - Zone A',
            spaceTypeName: 'NET',
            capacity: 20,
            status: 'Full'),
        StationAreaModel(
            id: 'A02',
            name: 'Tầng Trệt - Zone B',
            spaceTypeName: 'NET',
            capacity: 15,
            status: 'Available'),
        StationAreaModel(
            id: 'A03',
            name: 'Tầng 1 - VIP Bida',
            spaceTypeName: 'Bida',
            capacity: 5,
            status: 'Available'),
        StationAreaModel(
            id: 'A04',
            name: 'Tầng 1 - Bida Phăng',
            spaceTypeName: 'Bida',
            capacity: 8,
            status: 'Full'),
        StationAreaModel(
            id: 'A05',
            name: 'Tầng 2 - PS5 Room',
            spaceTypeName: 'Playstation 5',
            capacity: 10,
            status: 'Maintenance'),
      ];

      // 3. Mock Resources (Tài nguyên)
      _resources = [
        ResourceModel(
            id: 'R01',
            name: 'PC i9 13900K',
            type: 'Hardware',
            quantity: 20,
            status: 'Good'),
        ResourceModel(
            id: 'R02',
            name: 'Màn hình 360Hz',
            type: 'Hardware',
            quantity: 20,
            status: 'Good'),
        ResourceModel(
            id: 'R03',
            name: 'Ghế Gaming SecretLab',
            type: 'Furniture',
            quantity: 35,
            status: 'Good'),
        ResourceModel(
            id: 'R04',
            name: 'Bàn Bida Aileex',
            type: 'Equipment',
            quantity: 13,
            status: 'Good'),
        ResourceModel(
            id: 'R05',
            name: 'Tay cầm PS5 DualSense',
            type: 'Accessory',
            quantity: 25,
            status: 'Damaged (5)'),
        ResourceModel(
            id: 'R06',
            name: 'Máy lạnh Panasonic',
            type: 'Utility',
            quantity: 10,
            status: 'Maintenance'),
      ];
    });
  }

  void _showEditModal(BuildContext context) {
    if (_stationData == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StationEditDialog(
        stationData: _stationData!,
        onSave: (updatedModel) {
          setState(() {
            _stationData = updatedModel;
            _fullAddressDisplay =
                "${_stationData?.address}, ${_stationData?.commune}, ${_stationData?.district}, ${_stationData?.province}";
          });
        },
      ),
    );
  }

  Color _getStatusColor(String? code) {
    switch (code?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'REJECT':
      case 'REJECTED':
        return Colors.redAccent;
      case 'PENDING':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  // --- HELPER: SKELETON (LOADING BAR) ---
  // Sử dụng LinearProgressIndicator để tạo hiệu ứng loading bar chạy vô tận
  Widget _buildSkeleton({double? width, double? height, double radius = 4}) {
    return SizedBox(
      width: width,
      height: height ?? 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LinearProgressIndicator(
          // Màu của thanh chạy (foreground)
          color: AppColors.textHint.withOpacity(0.3),
          // Màu nền (background)
          backgroundColor: AppColors.inputBackground,
          minHeight: height ?? 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // [LOADING 1] Chặn toàn màn hình khi đang load Header
    if (_isHeaderLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGlow)));
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoleSwitcher(),
                const SizedBox(height: 16),
                _buildHeaderCard(isDesktop),
                const SizedBox(height: 24),
                // Phần này sẽ hiển thị Skeleton nếu _isContentLoading = true
                _buildMainContent(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSwitcher() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleButton('STATION-ADMIN', AppColors.primaryBlue),
            const SizedBox(width: 4),
            _buildRoleButton('STATION-OWNER', AppColors.btnPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, Color color) {
    final isSelected = _userRole == role;
    return InkWell(
      onTap: () => setState(() => _userRole = role),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
        ),
        child: Text(
          role == 'STATION-ADMIN' ? 'ADMIN VIEW' : 'OWNER VIEW',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? color : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryGlow.withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: 0),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          isDesktop
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: _buildCoverImage()),
                      Expanded(flex: 7, child: _buildHeaderInfo()),
                    ],
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: 200, child: _buildCoverImage()),
                    _buildHeaderInfo(),
                  ],
                ),
          Container(
            color: AppColors.containerBackground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem('overview', 'Dashboard', Icons.dashboard),
                  const SizedBox(width: 12),
                  _buildTabItem(
                      'spaces', 'Loại hình (Spaces)', Icons.videogame_asset),
                  const SizedBox(width: 12),
                  _buildTabItem('areas', 'Khu vực', Icons.layers),
                  const SizedBox(width: 12),
                  _buildTabItem('resources', 'Tài nguyên', Icons.memory),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    final avatar = _stationData?.avatar;
    final displayImage = avatar;

    return Stack(
      fit: StackFit.expand,
      children: [
        displayImage != null && displayImage.isNotEmpty
            ? (displayImage.startsWith('http')
                ? Image.network(displayImage, fit: BoxFit.cover)
                : Image.memory(base64Decode(displayImage.split(',').last),
                    fit: BoxFit.cover))
            : Container(
                color: AppColors.inputBackground,
                child: const Icon(Icons.image, color: AppColors.textHint)),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.bgCard, AppColors.bgCard.withOpacity(0.0)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    final status = _stationData?.statusName ?? "";
    final statusColor = _getStatusColor(_stationData?.statusCode);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_stationData?.stationName ?? "",
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tag,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(_stationData?.stationCode ?? "ST-001",
                            style: const TextStyle(
                                fontFamily: 'Monospace',
                                fontSize: 12,
                                color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppColors.btnPrimary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_fullAddressDisplay,
                        style: const TextStyle(
                            color: AppColors.textMain,
                            overflow: TextOverflow.ellipsis)))
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.phone,
                    size: 16, color: AppColors.activeStatus),
                const SizedBox(width: 8),
                Text(_stationData?.hotline ?? "",
                    style: const TextStyle(color: AppColors.textMain))
              ]),
            ],
          ),
          const SizedBox(height: 24),
          _userRole == 'STATION-OWNER'
              ? ElevatedButton.icon(
                  onPressed: () {
                    _showEditModal(context);
                  },
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Cấu hình Station'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 8,
                    shadowColor: AppColors.btnPrimary.withOpacity(0.5),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: const Row(children: [
                    Icon(Icons.shield, size: 18, color: AppColors.textHint),
                    SizedBox(width: 8),
                    Text('Chế độ Xem (Read-only)',
                        style: TextStyle(color: AppColors.textHint))
                  ]),
                ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String id, String label, IconData icon) {
    final isActive = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.btnPrimary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive
                  ? AppColors.btnPrimary.withOpacity(0.5)
                  : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isActive ? AppColors.menuActive : AppColors.textHint),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isActive ? AppColors.menuActive : AppColors.textHint,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    // [LOADING 2] Hiển thị Skeleton nếu đang load content (7s)
    // Các hàm _build... sẽ tự check _isContentLoading để hiển thị Skeleton
    if (_activeTab == 'overview') {
      return _buildOverviewContent(isDesktop);
    } else if (_activeTab == 'spaces') {
      return _buildSpaceTypesList();
    } else if (_activeTab == 'areas') {
      return _buildFullAreasList();
    } else if (_activeTab == 'resources') {
      return _buildResourcesList();
    }
    return Container();
  }

  Widget _buildOverviewContent(bool isDesktop) {
    final totalResources = _resources.fold<int>(0, (p, e) => p + e.quantity);

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                  flex: isWide ? 1 : 0,
                  child: _buildStatCard(
                      'Loại hình (Spaces)',
                      _isContentLoading ? null : '${_spaceTypes.length}',
                      Icons.videogame_asset,
                      AppColors.primaryBlue)),
              SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
              Expanded(
                  flex: isWide ? 1 : 0,
                  child: _buildStatCard(
                      'Khu vực (Areas)',
                      _isContentLoading ? null : '${_areas.length}',
                      Icons.layers,
                      AppColors.btnPrimary)),
              SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
              Expanded(
                  flex: isWide ? 1 : 0,
                  child: _buildStatCard(
                      'Tài nguyên (Res)',
                      _isContentLoading ? null : '$totalResources',
                      Icons.memory,
                      AppColors.activeStatus)),
            ],
          );
        }),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isWide ? 2 : 0,
                child: _buildRecentAreasCard(),
              ),
              SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 24),
              Expanded(
                flex: isWide ? 1 : 0,
                child: _buildQuickActionsCard(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String? value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 14)),
              const SizedBox(
                  height: 12), // Tăng khoảng cách chút để bar không bị dính
              // Nếu value null (loading), hiện LinearProgressIndicator
              value == null
                  ? SizedBox(
                      width: 60, // Độ dài của thanh loading
                      height: 4, // Độ dày của thanh
                      child: LinearProgressIndicator(
                        color: color, // Màu chạy (foreground)
                        backgroundColor:
                            color.withOpacity(0.2), // Màu nền mờ (background)
                        borderRadius: BorderRadius.circular(
                            2), // Bo tròn góc thanh loading
                      ),
                    )
                  : Text(value,
                      style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách khu vực (Areas) ở Dashboard
  Widget _buildRecentAreasCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.layers, color: AppColors.btnPrimary, size: 20),
                    SizedBox(width: 8),
                    Text('Trạng thái Khu vực (Top 5)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textWhite)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _activeTab = 'areas'),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('Chi tiết'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.menuActive,
                    backgroundColor: AppColors.menuActive.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Container(
            color: AppColors.tableHeader.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Tên khu vực',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Loại hình',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Trạng thái',
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13))),
              ],
            ),
          ),
          // List Body
          _isContentLoading
              // Loading: Show fake list of skeletons
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5, // 5 skeleton items
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return Container(
                      color: AppColors.containerBackground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildSkeleton(width: 100, height: 16)),
                          Expanded(
                              flex: 2,
                              child: _buildSkeleton(width: 80, height: 14)),
                          Expanded(
                              flex: 2,
                              child: _buildSkeleton(width: 60, height: 14)),
                        ],
                      ),
                    );
                  },
                )
              // Loaded: Show real data
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(_areas.length, 5),
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final area = _areas[index];
                    final status = area.status;
                    final isFull = status == 'Full';
                    final isAvailable = status == 'Available';

                    final statusColor = isFull
                        ? AppColors.statusUsing
                        : (isAvailable
                            ? AppColors.activeStatus
                            : Colors.orange);

                    return Container(
                      color: AppColors.containerBackground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor,
                                      boxShadow: [
                                        BoxShadow(
                                            color: statusColor.withOpacity(0.6),
                                            blurRadius: 6)
                                      ]),
                                ),
                                const SizedBox(width: 12),
                                Text(area.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMain)),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(area.spaceTypeName,
                                  style: const TextStyle(
                                      color: AppColors.textHint))),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: statusColor.withOpacity(0.1),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.btnPrimary, size: 20),
              SizedBox(width: 8),
              Text('Thao tác nhanh',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textWhite)),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionBtn('Thêm Loại hình', 'NET, Billiards, PS5...', Icons.add,
              AppColors.primaryBlue, () {}),
          const SizedBox(height: 12),
          _buildActionBtn('QL Tài nguyên', 'Kiểm kê thiết bị', Icons.memory,
              AppColors.activeStatus, () {}),
          const SizedBox(height: 12),
          if (_userRole == 'STATION-OWNER')
            _buildActionBtn('Nhân sự', 'Phân quyền nhân viên',
                Icons.manage_accounts, Colors.orangeAccent, () {}),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.containerBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- FULL LIST BUILDERS FOR TABS ---

  Widget _buildSpaceTypesList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Loại hình (Spaces)',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm Loại hình'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // List Body with Loading Check
          _isContentLoading
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: _buildSkeleton(width: 44, height: 44, radius: 8),
                      title: _buildSkeleton(width: 150, height: 16),
                      subtitle: _buildSkeleton(width: 200, height: 12),
                      trailing:
                          _buildSkeleton(width: 60, height: 24, radius: 12),
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _spaceTypes.length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final type = _spaceTypes[index];
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(type.icon,
                            size: 24, color: AppColors.btnPrimary),
                      ),
                      title: Text(type.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite)),
                      subtitle: Text(type.description,
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      trailing: Chip(
                        label: Text(type.status,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white)),
                        backgroundColor: type.status == 'Active'
                            ? AppColors.activeStatus.withOpacity(0.5)
                            : Colors.grey,
                        padding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFullAreasList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Khu vực (Areas)',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Thêm Khu vực'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _isContentLoading
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading:
                          _buildSkeleton(width: 40, height: 40, radius: 20),
                      title: _buildSkeleton(width: 120, height: 16),
                      subtitle: _buildSkeleton(width: 180, height: 12),
                      trailing: _buildSkeleton(width: 50, height: 14),
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _areas.length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final area = _areas[index];
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.inputBackground,
                        child: Text(area.id,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textWhite)),
                      ),
                      title: Text(area.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite)),
                      subtitle: Text(
                          "Loại hình: ${area.spaceTypeName} • Sức chứa: ${area.capacity}",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      trailing: Text(area.status,
                          style: TextStyle(
                              color: area.status == 'Available'
                                  ? AppColors.activeStatus
                                  : (area.status == 'Full'
                                      ? AppColors.statusUsing
                                      : Colors.orange),
                              fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildResourcesList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách Tài nguyên',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_box, size: 16),
                  label: const Text('Nhập kho'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeStatus,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _isContentLoading
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: _buildSkeleton(width: 24, height: 24, radius: 4),
                      title: _buildSkeleton(width: 130, height: 16),
                      subtitle: _buildSkeleton(width: 100, height: 12),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSkeleton(width: 40, height: 14),
                          const SizedBox(height: 4),
                          _buildSkeleton(width: 30, height: 10),
                        ],
                      ),
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _resources.length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final res = _resources[index];
                    return ListTile(
                      tileColor: AppColors.containerBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: const Icon(Icons.inventory_2_outlined,
                          color: AppColors.textHint),
                      title: Text(res.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite)),
                      subtitle: Text("Loại: ${res.type} • ID: ${res.id}",
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("SL: ${res.quantity}",
                              style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold)),
                          Text(res.status,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: res.status == 'Good'
                                      ? AppColors.activeStatus
                                      : Colors.red)),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
// ======================= EDIT DIALOG (Local State) =======================

class StationEditDialog extends StatefulWidget {
  final StationDetailModel stationData;
  final Function(StationDetailModel) onSave;

  const StationEditDialog(
      {super.key, required this.stationData, required this.onSave});

  @override
  State<StationEditDialog> createState() => _StationEditDialogState();
}

class _StationEditDialogState extends State<StationEditDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _stationNameController;
  late TextEditingController _addressController;
  late TextEditingController _hotlineController;
  final _captchaController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final ScrollController _imageScrollController = ScrollController();

  // Location Data State
  List<ProvinceModel> _provinces = [];
  List<DistrictModel> _districts = [];
  List<CommuneModel> _communes = [];

  ProvinceModel? _selectedProvince;
  DistrictModel? _selectedDistrict;
  CommuneModel? _selectedCommune;
  String? _placeId;

  // Images State
  List<String> _base64Images = [];
  bool _isPickingImage = false;

  // Logic State
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Autocomplete
  Timer? _debounce;
  final FocusNode _addressFocusNode = FocusNode();
  List<AutocompleteModel> _addressSuggestions = [];
  bool _isLoadingSuggestions = false;

  // Captcha
  String _captchaText = "";
  bool _isVerifyingCaptcha = false;
  bool _isCaptchaVerified = false;
  final Random _random = Random();
  final List<Color> _captchaColors = [
    Colors.black,
    const Color.fromARGB(255, 255, 58, 58),
    const Color.fromARGB(255, 35, 123, 254),
    const Color.fromARGB(255, 43, 246, 53),
    const Color.fromARGB(255, 255, 103, 53),
    const Color.fromARGB(255, 204, 85, 255),
  ];

  Color _getRandomCaptchaColor() =>
      _captchaColors[_random.nextInt(_captchaColors.length)];

  String _parseAddressFromFullString(String? fullAddress) {
    if (fullAddress == null || fullAddress.isEmpty) return '';
    List<String> parts = fullAddress.split(',');
    if (parts.length > 3) {
      return parts.sublist(0, parts.length - 3).join(',').trim();
    }
    return fullAddress;
  }

  @override
  void initState() {
    super.initState();
    _stationNameController =
        TextEditingController(text: widget.stationData.stationName);
    _addressController =
        TextEditingController(text: widget.stationData.address);
    _hotlineController =
        TextEditingController(text: widget.stationData.hotline);

    // Init images if any
    if (widget.stationData.avatar != null) {
      _base64Images.add(widget.stationData.avatar!);
    }

    _generateCaptcha();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Load Provinces
    final provRes = await CityRepository().getProvinces();
    final provList = (provRes['body'] as List)
        .map((e) => ProvinceModel.fromJson(e))
        .toList();

    setState(() {
      _provinces = provList;
    });

    // 2. Set Selected Values (Mock matching by name)
    // In real app, match by ID
    try {
      if (widget.stationData.province != null) {
        final prov = _provinces.firstWhere(
            (e) => e.name == widget.stationData.province,
            orElse: () => _provinces.first);
        _selectedProvince = prov;
        await _loadDistricts(prov.code);

        if (widget.stationData.district != null && _districts.isNotEmpty) {
          final dist = _districts.firstWhere(
              (e) => e.name == widget.stationData.district,
              orElse: () => _districts.first);
          _selectedDistrict = dist;
          await _loadCommunes(dist.code);

          if (widget.stationData.commune != null && _communes.isNotEmpty) {
            final comm = _communes.firstWhere(
                (e) => e.name == widget.stationData.commune,
                orElse: () => _communes.first);
            _selectedCommune = comm;
          }
        }
      }
    } catch (e) {
      DebugLogger.printLog("Error matching initial location: $e");
    }

    _updateFullAddressPreview();
  }

  Future<void> _loadDistricts(int provinceCode) async {
    setState(() => _isLoading = true);
    final res = await CityRepository().getDistricts(provinceCode);
    final list = (res['body']['districts'] as List)
        .map((e) => DistrictModel.fromJson(e))
        .toList();
    setState(() {
      _districts = list;
      _isLoading = false;
    });
  }

  Future<void> _loadCommunes(int districtCode) async {
    setState(() => _isLoading = true);
    final res = await CityRepository().getCommunes(districtCode);
    final list = (res['body']['wards'] as List)
        .map((e) => CommuneModel.fromJson(e))
        .toList();
    setState(() {
      _communes = list;
      _isLoading = false;
    });
  }

  void _updateFullAddressPreview() {
    String addr = _addressController.text;
    String c = _selectedCommune?.name ?? "";
    String d = _selectedDistrict?.name ?? "";
    String p = _selectedProvince?.name ?? "";
    String full = [addr, c, d, p].where((s) => s.isNotEmpty).join(", ");
    setState(() {
      _fullAddressController.text = full;
    });
  }

  void _generateCaptcha() {
    String code = (10000 + Random().nextInt(90000)).toString();
    setState(() {
      _captchaText = code;
      _isCaptchaVerified = false;
      _captchaController.clear();
    });
  }

  Future<void> _verifyCaptcha() async {
    if (_captchaController.text.isEmpty) return;
    setState(() => _isVerifyingCaptcha = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isVerifyingCaptcha = false);

    if (_captchaController.text == _captchaText) {
      setState(() => _isCaptchaVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Captcha hợp lệ!", style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.activeStatus));
    } else {
      _generateCaptcha();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Sai mã Captcha", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _pickImages() async {
    setState(() => _isPickingImage = true);
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: true, withData: true);
      if (result != null) {
        List<String> newImgs = result.files
            .map((f) =>
                "data:image/${f.extension};base64,${base64Encode(f.bytes!)}")
            .toList();
        setState(() {
          _base64Images.addAll(newImgs);
        });
      }
    } catch (_) {}
    setState(() => _isPickingImage = false);
  }

  void _removeImage(int index) {
    setState(() {
      _base64Images.removeAt(index);
    });
  }

  // --- Autocomplete Logic ---
  Future<void> _searchAddress(String query) async {
    setState(() => _isLoadingSuggestions = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Mock API delay

    String contextSuffix = [
      _selectedCommune?.name,
      _selectedDistrict?.name,
      _selectedProvince?.name,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    if (contextSuffix.isNotEmpty) contextSuffix = ", $contextSuffix";

    List<AutocompleteModel> suggestions = [
      AutocompleteModel(
          placeId: "mock_place_id_1",
          address: "${query}$contextSuffix",
          shortAddress: query,
          compound: CompoundModel(
              district: _selectedDistrict?.name ?? "Quận 1",
              commune: _selectedCommune?.name ?? "Phường 1",
              province: _selectedProvince?.name ?? "TP. Hồ Chí Minh")),
      AutocompleteModel(
          placeId: "mock_place_id_2",
          address: "Số 10, ${query}$contextSuffix",
          shortAddress: "Số 10, $query",
          compound: CompoundModel(
              district: _selectedDistrict?.name ?? "Quận 7",
              commune: _selectedCommune?.name ?? "Tân Phong",
              province: _selectedProvince?.name ?? "TP. Hồ Chí Minh")),
    ];

    setState(() {
      _addressSuggestions = suggestions;
      _isLoadingSuggestions = false;
    });
  }

  Future<List<MediaModel>> _uploadImagesToFirebase() async {
    List<MediaModel> uploadedUrls = [];
    for (String dataUri in _base64Images) {
      if (dataUri.startsWith('http')) {
        uploadedUrls.add(MediaModel(url: dataUri));
        continue;
      }
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        String mockUrl =
            "https://mock-firebase-storage.com/image_${DateTime.now().millisecondsSinceEpoch}.png";
        uploadedUrls.add(MediaModel(url: mockUrl));
      } catch (e) {
        DebugLogger.printLog("Lỗi upload: $e");
      }
    }
    return uploadedUrls;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      // 1. Upload Images
      List<MediaModel> mediaUrls = await _uploadImagesToFirebase();

      // 2. Prepare Update Model
      StationDetailModel updatedModel = StationDetailModel(
        stationId: widget.stationData.stationId,
        stationName: _stationNameController.text,
        hotline: _hotlineController.text,
        address: _addressController.text,
        province: _selectedProvince?.name,
        district: _selectedDistrict?.name,
        commune: _selectedCommune?.name,
        avatar: mediaUrls.isNotEmpty ? mediaUrls.first.url : null,
        // Keep other fields
        stationCode: widget.stationData.stationCode,
        statusCode: widget.stationData.statusCode,
        statusName: widget.stationData.statusName,
      );

      // 3. Call API Update
      await StationDetailRepository().updateStation(updatedModel, _placeId);

      // 4. Success
      widget.onSave(updatedModel);
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cập nhật thành công!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.activeStatus));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _addressController.dispose();
    _hotlineController.dispose();
    _captchaController.dispose();
    _fullAddressController.dispose();
    _imageScrollController.dispose();
    _addressFocusNode.dispose();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border)),
      child: Container(
        width: 900,
        height: 750,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cập nhật Station',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textHint)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Body
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageUploader(),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: _buildTextFormField(
                                label: "Tên Station",
                                controller: _stationNameController,
                                hint: "Nhập tên...",
                                validator: (val) => (val?.isEmpty ?? true)
                                    ? "Vui lòng nhập Tên Station"
                                    : null,
                              )),
                              const SizedBox(width: 24),
                              Expanded(
                                  child: _buildTextFormField(
                                label: "Số điện thoại",
                                controller: _hotlineController,
                                hint: "09xx.xxx.xxx",
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return "Vui lòng nhập SĐT";
                                  if (val.length < 10)
                                    return "SĐT phải đủ 10 số";
                                  return null;
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildDropdown<ProvinceModel>(
                                label: "Tỉnh/Thành",
                                hint: "Chọn Tỉnh",
                                value: _selectedProvince,
                                items: _provinces
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (v) async {
                                  setState(() {
                                    _selectedProvince = v;
                                    _selectedDistrict = null;
                                    _selectedCommune = null;
                                    _districts = [];
                                    _communes = [];
                                  });
                                  if (v != null) {
                                    await _loadDistricts(v.code);
                                  }
                                  _updateFullAddressPreview();
                                },
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildDropdown<DistrictModel>(
                                label: "Quận/Huyện",
                                hint: "Chọn Quận",
                                value: _selectedDistrict,
                                items: _districts
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (v) async {
                                  setState(() {
                                    _selectedDistrict = v;
                                    _selectedCommune = null;
                                    _communes = [];
                                  });
                                  if (v != null) {
                                    await _loadCommunes(v.code);
                                  }
                                  _updateFullAddressPreview();
                                },
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildDropdown<CommuneModel>(
                                label: "Phường/Xã",
                                hint: "Chọn Phường",
                                value: _selectedCommune,
                                items: _communes
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedCommune = v;
                                  });
                                  _updateFullAddressPreview();
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAddressAutocompleteField(),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                              label: "Địa chỉ đầy đủ (Preview)",
                              controller: _fullAddressController,
                              hint: "...",
                              readOnly: true),
                          const SizedBox(height: 32),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),
                          _buildCaptchaSection(),
                        ],
                      ),
                    ),
                  ),
                  if (_isSubmitting)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.activeStatus),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy bỏ',
                          style: TextStyle(color: AppColors.textHint))),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isCaptchaVerified && !_isSubmitting
                        ? _submitForm
                        : null,
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Lưu thay đổi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.btnPrimary.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
              color: readOnly ? AppColors.textHint : AppColors.textWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.5)),
            filled: true,
            fillColor:
                readOnly ? Colors.transparent : AppColors.inputBackground,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: readOnly ? Colors.transparent : AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.btnPrimary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.statusUsing)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            isDense: true,
          ),
        )
      ],
    );
  }

  Widget _buildAddressAutocompleteField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Địa chỉ chi tiết (Số nhà, đường)",
          style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      RawAutocomplete<AutocompleteModel>(
        textEditingController: _addressController,
        focusNode: _addressFocusNode,
        displayStringForOption: (AutocompleteModel option) =>
            _parseAddressFromFullString(option.address),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<AutocompleteModel>.empty();
          }
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          // Debounce manual call to search because we want to update state async
          // RawAutocomplete doesn't support async optionsBuilder easily without state
          // So we use a hack: trigger search, update state var, RawAutocomplete rebuilds
          // Ideally use a stream or ValueNotifier

          // NOTE: Simplified for setstate: we trigger search and rebuild.
          // But RawAutocomplete expects synchronous return.
          // We can return current _addressSuggestions but trigger fetch.

          _debounce = Timer(const Duration(milliseconds: 300), () {
            _searchAddress(textEditingValue.text);
          });

          // Return cached suggestions
          return _addressSuggestions;
        },
        onSelected: (AutocompleteModel selection) {
          String shortAddr = _parseAddressFromFullString(selection.address);
          _addressController.text = shortAddr;
          setState(() {
            _placeId = selection.placeId;
          });
          _updateFullAddressPreview();
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted) {
          return TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            style: const TextStyle(color: AppColors.textWhite),
            onChanged: (val) {
              setState(() => _placeId = null);
              _updateFullAddressPreview();
            },
            decoration: InputDecoration(
                hintText: "Ví dụ: 483 Thống Nhất",
                hintStyle:
                    TextStyle(color: AppColors.textHint.withOpacity(0.5)),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.btnPrimary)),
                suffixIcon: _isLoadingSuggestions
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)))
                    : null),
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Vui lòng nhập địa chỉ" : null,
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<AutocompleteModel> onSelected,
            Iterable<AutocompleteModel> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.primaryGlow.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8)),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final AutocompleteModel option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(option.address ?? '',
                            style: const TextStyle(color: AppColors.textWhite)),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.bgCard,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              hint: Text(hint,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textHint)),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textHint),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptchaSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 120,
          height: 48,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _captchaText.split('').map((char) {
                    return Transform.rotate(
                      angle: (_random.nextDouble() * 0.4) - 0.2,
                      child: Text(
                        char,
                        style: GoogleFonts.permanentMarker(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getRandomCaptchaColor(),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      icon: const Icon(Icons.refresh,
                          color: Colors.blue, size: 18),
                      onPressed: _generateCaptcha)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _captchaController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Nhập mã...",
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
              suffixIcon: IconButton(
                icon: _isVerifyingCaptcha
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(
                        _isCaptchaVerified
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                        color: _isCaptchaVerified
                            ? AppColors.activeStatus
                            : AppColors.textWhite),
                onPressed: _verifyCaptcha,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Hình ảnh",
            style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.textHint),
          ),
          child: _base64Images.isEmpty
              ? Center(
                  child: TextButton.icon(
                    onPressed: () {
                      if (!_isPickingImage) {
                        _pickImages();
                      }
                    },
                    icon: _isPickingImage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.textWhite))
                        : const Icon(Icons.photo_camera,
                            color: AppColors.textWhite, size: 20),
                    label: Text(
                      _isPickingImage ? "Đang tải..." : "Tải ảnh lên",
                      style: const TextStyle(
                          color: AppColors.textWhite, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.btnSecondary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                )
              : _buildImageGridView(),
        ),
        if (_base64Images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () {
                if (!_isPickingImage) {
                  _pickImages();
                }
              },
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.white),
              label: Text(
                  _isPickingImage ? "Đang xử lý..." : "Thêm/Thay đổi ảnh",
                  style: const TextStyle(color: Colors.white)),
            ),
          )
      ],
    );
  }

  Widget _buildImageGridView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
          },
        ),
        child: Scrollbar(
          thumbVisibility: true,
          controller: _imageScrollController,
          child: ListView.builder(
            controller: _imageScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _base64Images.length,
            itemBuilder: (context, index) {
              String imageSource = _base64Images[index];
              bool isUrl = imageSource.startsWith('http');

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isUrl
                          ? Image.network(
                              imageSource,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                      width: 180,
                                      height: 180,
                                      color: Colors.grey,
                                      child: const Icon(Icons.broken_image)),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null)));
                              },
                            )
                          : Image.memory(
                              base64Decode(imageSource.contains(',')
                                  ? imageSource.split(',').last
                                  : imageSource),
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: Center(child: Text("Lỗi ảnh"))),
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
