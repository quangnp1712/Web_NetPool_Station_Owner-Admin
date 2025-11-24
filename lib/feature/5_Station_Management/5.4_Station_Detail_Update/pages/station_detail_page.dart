// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/responsive/responsive.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/bloc/station_detail_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/shared_preferences/station_detail_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/navigation_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/repository/landing_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/menu_controller.dart';

//! Station Detail - Xem Sửa Station !//

class StationDetailPage extends StatefulWidget {
  const StationDetailPage({super.key});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  late final String stationId;
  final UserSessionController sessionController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final StationDetailBloc stationDetailBloc = StationDetailBloc();

  // [THÊM] Timer cho debounce search
  Timer? _debounce;

  // Controllers cho form chính
  final _stationNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _hotlineController = TextEditingController();
  final _fullAddressController = TextEditingController();

  // Controllers và State cho Captcha
  final _captchaController = TextEditingController();
  bool _isCaptchaVerified = false; // State chính để kiểm soát
  bool _isVerifyingCaptcha = false; // State cho loading button 'Xác thực'
  final Random _random = Random();
  String _captchaText = "";

  //  Danh sách màu an toàn (màu tối) để không trùng màu nền (xám sáng)
  final List<Color> _captchaColors = [
    Colors.black,
    const Color.fromARGB(255, 255, 58, 58),
    const Color.fromARGB(255, 35, 123, 254),
    const Color.fromARGB(255, 43, 246, 53),
    const Color.fromARGB(255, 255, 103, 53),
    const Color.fromARGB(255, 204, 85, 255),
  ];
  // ---------------------------------------

  // Helper chọn màu sắc dựa trên StatusCode
  Color _getStatusColor(String? code) {
    switch (code?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green; // Xanh lá cho Active
      case 'REJECT':
      case 'REJECTED':
        return Colors.redAccent; // Đỏ cho Reject
      case 'PENDING':
        return Colors.orangeAccent; // Vàng/Cam cho Pending
      default:
        return Colors.grey; // Xám cho các trạng thái khác
    }
  }

  // --- THÊM: Hàm lấy màu ngẫu nhiên (an toàn) ---
  Color _getRandomCaptchaColor() {
    return _captchaColors[_random.nextInt(_captchaColors.length)];
  }

  // -------------------------------------------
  // Danh sách dữ liệu
  List<ProvinceModel> _provinceList = [];
  List<DistrictModel> _districtList = [];
  List<CommuneModel> _communeList = [];

  // Giá trị cho dropdowns
  ProvinceModel? _selectedProvince;
  DistrictModel? _selectedDistrict;
  CommuneModel? _selectedCommune;
  // -------------------------------------------

  // Trạng thái loading
  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingCommunes = false;
  bool isLoading = true;

  // --- THÊM: State cho Upload Ảnh ---
  List<String> _base64Images = []; // Dạng: "data:image/png;base64,..."
  bool _isPickingImage = false;
  // --------------------------------

  // [THÊM] FocusNode bền vững cho Autocomplete
  late final FocusNode _addressFocusNode;
  // --------------------------------

  @override
  void initState() {
    super.initState();

    // [THÊM] Khởi tạo FocusNode
    _addressFocusNode = FocusNode();
    if (StationDetailSharedPref.getStationId() != "") {
      stationId = StationDetailSharedPref.getStationId();
    } else {
      stationId = sessionController.activeStationId.value ?? "";
    }

    stationDetailBloc.add(StationDetailInitialEvent(stationId: stationId));

    _addressController.addListener(() {
      final currentState = stationDetailBloc.state;

      // 2. Gửi sự kiện UpdateFullAddressEvent
      if (currentState.isEditMode) {
        stationDetailBloc.add(UpdateFullAddressEvent(
          address: _addressController.text,
          commune: _selectedCommune,
          district: _selectedDistrict,
          province: _selectedProvince,
        ));
      }
    });
  }

  @override
  void dispose() {
    // --- THÊM: Dispose controllers ---
    _stationNameController.dispose();
    _addressController.dispose();
    _hotlineController.dispose();
    _captchaController.dispose();
    _fullAddressController.dispose();
    _debounce?.cancel();
    _addressFocusNode.dispose();
    stationDetailBloc.close();
    StationDetailSharedPref.clearStationId();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Đây là layout gốc của AccountListPage
    return BlocConsumer<StationDetailBloc, StationDetailState>(
      bloc: stationDetailBloc,
      listener: (context, state) {
        if (state.stationDetailStatus == StationDetailStatus.failure) {
          ShowSnackBar(state.message, false);
        }
        if (state.stationDetailStatus == StationDetailStatus.success) {
          ShowSnackBar(state.message, true);
          if (state.isEditMode) {
            stationDetailBloc
                .add(StationDetailInitialEvent(stationId: stationId));
          }
        }
        if (state.blocState ==
            StationDetailBlocState.StationUpdateSuccessState) {
          stationDetailBloc.add(ResetFormEvent());
        }
        if (state.blocState ==
            StationDetailBlocState.ShowStationListPageState) {
          if (!menuController.isActive(stationListPageName)) {
            menuController.changeActiveItemTo(stationListPageName,
                parentName: stationParentName);
            if (ResponsiveWidget.isSmallScreen(context)) Get.back();
            navigationController.navigateAndSyncURL(stationListPageRoute);
          }
        }
      },
      builder: (context, state) {
        // view detail
        if (!state.isEditMode) {
          _base64Images = state.base64Images;

          _stationNameController.value =
              TextEditingValue(text: state.stationName.toString());
          _addressController.value =
              TextEditingValue(text: state.address.toString());
          _hotlineController.value =
              TextEditingValue(text: state.phone.toString());
        }

        _isPickingImage = state.isPickingImage;
        _selectedProvince = state.selectedProvince;
        _fullAddressController.text = state.fullAddressController;
        _isLoadingProvinces = state.isLoadingProvinces;
        _provinceList = state.provincesList ?? [];
        _isLoadingDistricts = state.isLoadingDistricts;
        _districtList = state.districtList ?? [];
        _communeList = state.communeList ?? [];
        _selectedCommune = state.selectedCommune;
        _selectedDistrict = state.selectedDistrict;
        _isLoadingCommunes = state.isLoadingCommunes;
        _captchaText = state.captchaText;
        _isCaptchaVerified = state.isCaptchaVerified;
        _isVerifyingCaptcha = state.isVerifyingCaptcha;
        isLoading = state.stationDetailStatus == StationDetailStatus.loading;

        if (state.isClearCaptchaController) {
          _captchaController.clear();
        }
        if (state.blocState == StationDetailBlocState.ResetFormState) {
          //  Reset controllers mới
          _stationNameController.clear();
          _addressController.clear();
          _hotlineController.clear();
          _captchaController.clear();

          stationDetailBloc.add(GenerateCaptchaEvent());
        }

        if (state.blocState == StationDetailBlocState.RemoveImageState) {
          _base64Images = [];
          _base64Images = state.base64Images;
        }
        if (state.blocState == StationDetailBlocState.PickImagesState) {
          _base64Images = [];
          _base64Images = state.base64Images;
        }
        if (state.blocState == StationDetailBlocState.SelectedProvinceState) {
          _selectedProvince = state.selectedProvince;
          if (_selectedProvince != null) {
            stationDetailBloc
                .add(LoadDistrictsEvent(provinceCode: _selectedProvince!.code));
          }
        }
        if (state.blocState == StationDetailBlocState.SelectedDistrictState) {
          _selectedDistrict = state.selectedDistrict;
          if (_selectedDistrict != null) {
            stationDetailBloc
                .add(LoadCommunesEvent(districtCode: _selectedDistrict!.code));
          }
        }
        if (state.blocState == StationDetailBlocState.SelectedCommuneState) {
          _selectedCommune = state.selectedCommune;
          stationDetailBloc.add(UpdateFullAddressEvent(
            address: _addressController.text,
            commune: _selectedCommune,
            district: _selectedDistrict,
            province: _selectedProvince,
          ));
        }

        if (state.blocState == StationDetailBlocState.LoadDistrictsState) {
          _isLoadingDistricts = state.isLoadingDistricts;
          _districtList = state.districtList ?? [];
          _communeList = state.communeList ?? [];
          _selectedCommune = state.selectedCommune;
          _selectedDistrict = state.selectedDistrict;
          stationDetailBloc.add(UpdateFullAddressEvent(
            address: _addressController.text,
            commune: null, // Reset
            district: null, // Reset
            province: _selectedProvince,
          ));
        }

        if (state.blocState == StationDetailBlocState.LoadCommunesState) {
          _isLoadingCommunes = state.isLoadingCommunes;
          _communeList = state.communeList ?? [];
          _selectedCommune = state.selectedCommune;
          stationDetailBloc.add(UpdateFullAddressEvent(
            address: _addressController.text,
            commune: null, // Reset
            district: _selectedDistrict,
            province: _selectedProvince,
          ));
        }

        if (state.blocState == StationDetailBlocState.StationUpdateFailState) {
          // isLoading = state.isLoading;
          stationDetailBloc.add(GenerateCaptchaEvent());
        }

        return Material(
          color: AppColors.mainBackground,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40.0),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 20.0,
                              spreadRadius: 0.5,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: _buildFormContent(context, state),
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
              // --- WIDGET LOADING TRONG STACK ---
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground.withOpacity(
                        0.8,
                      ), // Màu nền mờ
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGlow,
                        ),
                      ),
                    ),
                  ),
                ),
              // ------------------------------------
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormContent(BuildContext context, StationDetailState state) {
    // Tiêu đề thay đổi dựa trên chế độ View/Edit
    final String title =
        state.isEditMode ? "Cập nhật Station" : "Chi tiết Station";
    final bool isReadOnly =
        state.isReadOnly; // True = View Mode, False = Edit Mode

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: isReadOnly
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isReadOnly ? Colors.blue : Colors.orange)),
                  child: Text(
                    isReadOnly ? "Chế độ xem" : "Đang chỉnh sửa",
                    style: TextStyle(
                        color: isReadOnly ? Colors.blue : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const Divider(color: AppColors.inputBackground, height: 32),
            const SizedBox(height: 32),

            // 2. Images
            _buildImageUploader(context, state),
            const SizedBox(height: 32),

            // 3. Info Fields
            _buildTextFormField(
              label: "Tên Station",
              hint: "Nhập tên Station",
              controller: _stationNameController,
              readOnly: isReadOnly,
              validator: (val) =>
                  (val?.isEmpty ?? true) ? "Vui lòng nhập tên" : null,
            ),
            const SizedBox(height: 24),

            // [SỬA ĐỔI] Hàng chứa: Số điện thoại (70%) + Trạng thái (30%)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột Số điện thoại
                Expanded(
                  flex: 7,
                  child: _buildTextFormField(
                    label: "Số điện thoại",
                    hint: "09xx.xxx.xxx",
                    controller: _hotlineController,
                    readOnly: state.isReadOnly,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ],
                    validator: (val) =>
                        (val?.isEmpty ?? true) ? "Vui lòng nhập SĐT" : null,
                  ),
                ),
                const SizedBox(width: 24),

                // Cột Trạng thái (Status Badge)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label giả lập cho đồng bộ với input
                      Text(
                        "Trạng thái",
                        style: TextStyle(
                          color: AppColors.textWhite.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Box hiển thị trạng thái
                      Container(
                        height:
                            48, // Chiều cao khớp với Input chuẩn (isDense: true)
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _getStatusColor(state.statusCode)
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.statusName ?? "Chưa cập nhật",
                          style: TextStyle(
                            color: _getStatusColor(state.statusCode),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Address Dropdowns
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 650) {
                return Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: _buildProvinceField(context, state, isReadOnly)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildDistrictField(context, state, isReadOnly)),
                  ]),
                  const SizedBox(height: 24),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: _buildCommuneField(context, state, isReadOnly)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildAddressAutocompleteField(
                            context, state, isReadOnly)),
                  ]),
                ]);
              } else {
                return Column(children: [
                  _buildProvinceField(context, state, isReadOnly),
                  const SizedBox(height: 24),
                  _buildDistrictField(context, state, isReadOnly),
                  const SizedBox(height: 24),
                  _buildCommuneField(context, state, isReadOnly),
                  const SizedBox(height: 24),
                  _buildAddressAutocompleteField(context, state, isReadOnly),
                ]);
              }
            }),
            const SizedBox(height: 24),

            // 5. Full Address (Always Readonly)
            _buildTextFormField(
              label: "Địa chỉ đầy đủ",
              hint: "...",
              controller: _fullAddressController,
              readOnly: true,
            ),
            const SizedBox(height: 32),

            // 6. Captcha (Chỉ hiện khi đang Edit)
            if (state.isEditMode) ...[
              _buildCaptchaSection(context, state),
              const SizedBox(height: 40),
            ],

            // 7. Buttons
            _buildActionButtons(context, state),
          ],
        ),
      ),
    );
  }

  // ======================= WIDGETS LOGIC =======================

  Widget _buildImageUploader(BuildContext context, StationDetailState state) {
    final isReadOnly = state.isReadOnly;
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
                  child: Text("Không có hình ảnh",
                      style: TextStyle(color: Colors.grey.shade500)))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _base64Images.length,
                    itemBuilder: (ctx, index) {
                      final String imageSource = _base64Images[index];

                      // --- LOGIC QUAN TRỌNG: KIỂM TRA URL HAY BASE64 ---
                      final bool isUrl = imageSource.startsWith('http');

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isUrl
                                  // TRƯỜNG HỢP 1: LÀ URL (Từ API)
                                  ? Image.network(
                                      imageSource,
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 180,
                                          height: 180,
                                          color: Colors.grey,
                                          child: const Icon(Icons.broken_image),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
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
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  // TRƯỜNG HỢP 2: LÀ BASE64 (Ảnh mới chọn)
                                  : Image.memory(
                                      base64Decode(imageSource.contains(',')
                                          ? imageSource.split(',').last
                                          : imageSource),
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const SizedBox(
                                            width: 180,
                                            height: 180,
                                            child:
                                                Center(child: Text("Lỗi ảnh")));
                                      },
                                    ),
                            ),
                            // Chỉ hiện nút xóa ảnh khi đang Edit
                            if (!isReadOnly)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => context
                                      .read<StationDetailBloc>()
                                      .add(RemoveImageEvent(
                                          base64Images: _base64Images,
                                          imageIndex: index)),
                                  child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(Icons.close,
                                          size: 16, color: Colors.white)),
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
        // Chỉ hiện nút thêm ảnh khi đang Edit
        if (!isReadOnly)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () {
                if (!_isPickingImage) {
                  stationDetailBloc
                      .add(PickImagesEvent(isPickingImage: _isPickingImage));
                }
              },
              icon: state.isPickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate, color: Colors.white),
              label: Text(
                  state.isPickingImage ? "Đang xử lý..." : "Thêm/Thay đổi ảnh",
                  style: const TextStyle(color: Colors.white)),
            ),
          )
      ],
    );
  }

  Widget _buildProvinceField(
      BuildContext context, StationDetailState state, bool readOnly) {
    return _buildDropdownAPI(
      label: "Tỉnh/Thành phố",
      hint: "Tỉnh/TP",
      value: state.selectedProvince,
      items: state.provincesList
          .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
          .toList(),
      isLoading: state.isLoadingProvinces,
      readOnly: readOnly,
      onChanged: (val) {
        if (val == null) return;
        stationDetailBloc.add(SelectedProvinceEvent(newValue: val));
      },
    );
  }

  Widget _buildDistrictField(
      BuildContext context, StationDetailState state, bool readOnly) {
    final enabled = state.selectedProvince != null && !readOnly;
    return _buildDropdownAPI(
      label: "Quận/Huyện",
      hint: "Quận/Huyện",
      value: state.selectedDistrict,
      items: state.districtList
          .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
          .toList(),
      isLoading: state.isLoadingDistricts,
      readOnly: !enabled,
      onChanged: (val) {
        if (val == null) return;
        stationDetailBloc.add(SelectedDistrictEvent(newValue: val));
      },
    );
  }

  Widget _buildCommuneField(
      BuildContext context, StationDetailState state, bool readOnly) {
    final enabled = state.selectedDistrict != null && !readOnly;
    return _buildDropdownAPI(
      label: "Phường/Xã",
      hint: "Phường/Xã",
      value: state.selectedCommune,
      items: state.communeList
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      isLoading: state.isLoadingCommunes,
      readOnly: !enabled,
      onChanged: (val) {
        if (val == null) return;
        stationDetailBloc.add(SelectedCommuneEvent(newValue: val));
      },
    );
  }

  // Input Địa chỉ có Autocomplete (Chỉ active khi Edit)
  Widget _buildAddressAutocompleteField(
      BuildContext context, StationDetailState state, bool readOnly) {
    if (readOnly) {
      // View Mode: Chỉ hiện text tĩnh
      return _buildTextFormField(
          label: "Số nhà, đường",
          hint: "",
          controller: _addressController,
          readOnly: true);
    }
    // Edit Mode: Hiện Autocomplete
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Số nhà, đường",
          style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
      const SizedBox(height: 8),
      RawAutocomplete<String>(
        textEditingController: _addressController,
        focusNode: _addressFocusNode,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            context
                .read<StationDetailBloc>()
                .add(ClearAddressSuggestionsEvent());
            return const Iterable<String>.empty();
          }
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            context
                .read<StationDetailBloc>()
                .add(SearchAddressSuggestionEvent(textEditingValue.text));
          });
          return state.addressSuggestions;
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: "Nhập địa chỉ...",
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.inputBackground,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: state.isLoadingAddressSuggestions
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)))
                  : null,
            ),
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Vui lòng nhập địa chỉ" : null,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
              alignment: Alignment.topLeft,
              child: Material(
                  elevation: 4.0,
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      width: 300,
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (ctx, index) {
                            final option = options.elementAt(index);
                            return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option,
                                        style: const TextStyle(
                                            color: AppColors.textWhite))));
                          }))));
        },
      )
    ]);
  }

  Widget _buildCaptchaSection(BuildContext context, StationDetailState state) {
    return Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8)),
            child: Stack(children: [
              Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: state.captchaText
                          .split('')
                          .map((char) => Transform.rotate(
                              angle: (_random.nextDouble() * 0.4) - 0.2,
                              child: Text(char,
                                  style: GoogleFonts.permanentMarker(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _getRandomCaptchaColor(),
                                      decoration: TextDecoration.lineThrough))))
                          .toList())),
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () => context
                          .read<StationDetailBloc>()
                          .add(GenerateCaptchaEvent())))
            ]),
          ),
          SizedBox(
              width: 200,
              child: TextFormField(
                  controller: _captchaController,
                  readOnly: state.isCaptchaVerified,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                      hintText: "Nhập mã",
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: state.isVerifyingCaptcha
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Icon(
                                state.isCaptchaVerified
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                                color: state.isCaptchaVerified
                                    ? Colors.green
                                    : Colors.white),
                        onPressed: () {
                          if (!_isCaptchaVerified) {
                            stationDetailBloc.add(HandleVerifyCaptchaEvent(
                                captcha: _captchaController.text));
                          }
                        },
                      ))))
        ]);
  }

  Widget _buildActionButtons(BuildContext context, StationDetailState state) {
    final backButton = ElevatedButton(
        onPressed: () => stationDetailBloc.add(ShowStationListPageEvent()),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text("TRỞ VỀ",
            style: TextStyle(
                color: AppColors.bgCard, fontWeight: FontWeight.bold)));

    if (state.isReadOnly) {
      // View Mode: [CHỈNH SỬA] [TRỞ VỀ]
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: () => stationDetailBloc.add(ToggleEditModeEvent(true)),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGlow,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: const Text("CHỈNH SỬA",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        backButton
      ]);
    } else {
      // Edit Mode: [LƯU] [HỦY]
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: state.isCaptchaVerified
              ? () {
                  // if (_formKey.currentState!.validate())
                  // stationDetailBloc.add(SubmitStationUpdateEvent());
                }
              : null,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGlow,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: const Text("LƯU THAY ĐỔI",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            // Hủy bỏ -> Reload lại dữ liệu gốc (về chế độ View)
            stationDetailBloc
                .add(StationDetailInitialEvent(stationId: stationId));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: const Text("HỦY BỎ",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]);
    }
  }

  // --- Generic Fields (Helper) ---
  // --- 1. TEXT FORM FIELD (ĐÃ TỐI ƯU UI) ---
  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [THAY ĐỔI 1] Label dùng màu Xám (white70) thay vì Trắng tinh
        // Giúp phân biệt rõ đâu là tiêu đề, đâu là nội dung
        Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite.withOpacity(0.7), // Màu nhạt hơn
            fontSize: 14, // Nhỏ hơn 1 chút để tinh tế
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,

          // [THAY ĐỔI 2] Style chữ nội dung:
          // - Nếu đang nhập (Edit): Màu Trắng sáng, đậm hơn.
          // - Nếu chỉ xem (View): Màu hơi xám để dịu mắt.
          style: TextStyle(
            color: readOnly
                ? AppColors.textWhite.withOpacity(0.9)
                : AppColors.textWhite,
            fontWeight: readOnly ? FontWeight.normal : FontWeight.w600,
          ),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.5)),
            filled: true,

            // [THAY ĐỔI 3] Nền Input:
            // - Edit: Màu nền input chuẩn.
            // - View: Nền trong suốt hoặc rất tối để chìm đi, làm nổi bật nội dung.
            fillColor: readOnly
                ? Colors.transparent // Hoặc Colors.black12
                : AppColors.inputBackground,

            // [THAY ĐỔI 4] Viền (Border):
            // - View: Bỏ viền hoặc viền rất mờ -> Giảm cảm giác "rối" vì quá nhiều khung.
            // - Edit: Viền rõ ràng.
            border: readOnly
                ? const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white24)) // Chỉ gạch chân mờ
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.textHint),
                  ),

            enabledBorder: readOnly
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24))
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: AppColors.textHint.withOpacity(0.5)),
                  ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: AppColors.primaryGlow, width: 2),
            ),

            // Padding gọn gàng hơn
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          validator: validator,
        )
      ],
    );
  }

  // --- 2. DROPDOWN (ĐÃ TỐI ƯU UI) ---
  Widget _buildDropdownAPI<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    bool isLoading = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label màu dịu hơn
        Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        DropdownButtonFormField<T>(
          value: value,
          dropdownColor:
              AppColors.inputBackground, // Menu xổ xuống vẫn giữ màu nền

          // Logic hiển thị Selected Item (như bài trước, nhưng chỉnh màu)
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((DropdownMenuItem<T> item) {
              String text = "";
              if (item.child is Text) text = (item.child as Text).data ?? "";
              return Text(
                text,
                style: TextStyle(
                  color: readOnly
                      ? AppColors.textWhite.withOpacity(0.9)
                      : AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: readOnly ? FontWeight.normal : FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },

          style: const TextStyle(color: AppColors.textWhite),

          decoration: InputDecoration(
            filled: true,
            // View Mode: Nền trong suốt để bớt nặng nề
            fillColor:
                readOnly ? Colors.transparent : AppColors.inputBackground,

            hintText: isLoading ? "Đang tải..." : hint,
            hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.5)),

            // View Mode: Dùng gạch chân (Underline) thay vì khung (Outline)
            border: readOnly
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24))
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.textHint),
                  ),

            enabledBorder: readOnly
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24))
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: AppColors.textHint.withOpacity(0.5)),
                  ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: AppColors.primaryGlow, width: 2),
            ),

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),

          items: isLoading ? [] : items,
          onChanged: (isLoading || readOnly) ? null : onChanged,
          validator: (val) {
            if (readOnly) return null;
            return val == null ? "Vui lòng chọn $label" : null;
          },

          // Ẩn icon mũi tên khi ở chế độ xem để trông giống Text tĩnh hơn
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.grey))
              : (readOnly
                  ? const SizedBox.shrink()
                  : const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white70)),
        )
      ],
    );
  }

  Widget _buildFooter() => Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
              'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12))));
}
