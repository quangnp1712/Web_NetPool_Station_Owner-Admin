// ignore_for_file: type_literal_in_constant_pattern

import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_text_styles.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.2_Staion_Create/bloc/station_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/city_controller/city_model.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

//! Station Create - Tạo Station Station !//

class StationCreatePage extends StatefulWidget {
  const StationCreatePage({super.key});

  @override
  State<StationCreatePage> createState() => _StationCreatePageState();
}

class _StationCreatePageState extends State<StationCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final StationCreateBloc stationCreateBloc = StationCreateBloc();

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

  @override
  void initState() {
    super.initState();
    stationCreateBloc.add(StationCreateInitialEvent());
    _addressController.addListener(() {
      // 2. Gửi sự kiện UpdateFullAddressEvent
      stationCreateBloc.add(UpdateFullAddressEvent(
        address: _addressController.text,
        commune: _selectedCommune,
        district: _selectedDistrict,
        province: _selectedProvince,
      ));
    });
  }

  @override
  void dispose() {
    // --- THÊM: Dispose controllers ---
    _stationNameController.dispose();
    _addressController.dispose();
    _hotlineController.dispose();
    _captchaController.dispose();
    stationCreateBloc.close();
    _fullAddressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Đây là layout gốc của AccountListPage
    return BlocConsumer<StationCreateBloc, StationCreateState>(
      bloc: stationCreateBloc,
      listenWhen: (previous, current) => current is StationCreateActionState,
      buildWhen: (previous, current) => current is! StationCreateActionState,
      listener: (context, state) {
        switch (state.runtimeType) {
          case StationCreateSuccessState:
            Get.find<UserSessionController>().loadData();
            stationCreateBloc.add(ResetFormEvent());
            isLoading = false;
            break;
          case ShowSnackBarActionState:
            final snackBarState = state as ShowSnackBarActionState;
            ShowSnackBar(snackBarState.message, snackBarState.success);
            isLoading = false;
            break;
        }
      },
      builder: (context, state) {
        // Lấy isLoading TỪ THUỘC TÍNH (PROPERTY)
        isLoading = state.isLoading;

        if (state is StationCreateInitialState) {
          _captchaText = state.captchaText;
          _isCaptchaVerified = state.isCaptchaVerified;
          _isVerifyingCaptcha = state.isVerifyingCaptcha;
          _isLoadingProvinces = state.isLoadingProvinces;
          _provinceList = state.provincesList ?? [];
          if (state.isClearCaptchaController) {
            _captchaController.clear();
          }
        }

        if (state is GenerateCaptchaState) {
          _captchaText = state.captchaText;
          _isCaptchaVerified = state.isCaptchaVerified;
          _isVerifyingCaptcha = state.isVerifyingCaptcha;
          if (state.isClearCaptchaController) {
            _captchaController.clear();
          }
        }
        if (state is LoadingCaptchaState) {
          if (state.isVerifyingCaptcha) {
            _isVerifyingCaptcha = state.isVerifyingCaptcha;
          }
        }
        if (state is HandleVerifyCaptchaState) {
          if (state.isVerifyingCaptcha != null) {
            _isVerifyingCaptcha = state.isVerifyingCaptcha!;
          }
          if (state.isCaptchaVerified != null) {
            _isCaptchaVerified = state.isCaptchaVerified!;
          }
        }
        if (state is ResetFormState) {
          _formKey.currentState?.reset();

          //  Reset controllers mới
          _stationNameController.clear();
          _addressController.clear();
          _hotlineController.clear();
          _fullAddressController.clear();

          // dropdown
          _selectedProvince = null;
          _selectedDistrict = null;
          _selectedCommune = null;
          _districtList = [];
          _communeList = [];

          // file
          _base64Images = [];

          stationCreateBloc.add(GenerateCaptchaEvent());
        }
        if (state is SelectedStationIdState) {
          // _selectedStationId = state.newValue;
        }
        if (state is IsPickingImageState) {
          _isPickingImage = state.isPickingImage;
        }
        if (state is PickingImagesState) {
          _isPickingImage = state.isPickingImage;
          _base64Images.addAll(state.base64Images);
        }
        if (state is RemoveImageState) {
          _base64Images = [];
          _base64Images = state.base64Images;
        }
        if (state is SelectedProvinceState) {
          _selectedProvince = state.newValue;
          if (_selectedProvince != null) {
            stationCreateBloc
                .add(LoadDistrictsEvent(provinceCode: _selectedProvince!.code));
          }
        }
        if (state is SelectedDistrictState) {
          _selectedDistrict = state.newValue;
          if (_selectedDistrict != null) {
            stationCreateBloc
                .add(LoadCommunesEvent(districtCode: _selectedDistrict!.code));
          }
        }
        if (state is SelectedCommuneState) {
          _selectedCommune = state.newValue;
          stationCreateBloc.add(UpdateFullAddressEvent(
            address: _addressController.text,
            commune: _selectedCommune,
            district: _selectedDistrict,
            province: _selectedProvince,
          ));
        }
        if (state is UpdateFullAddressState) {
          _fullAddressController.text = state.fullAddressController;
        }
        if (state is LoadProvincesState) {
          _isLoadingProvinces = state.isLoadingProvinces;
          _provinceList = state.provincesList ?? [];
        }
        if (state is LoadDistrictsState) {
          _isLoadingDistricts = state.isLoadingDistricts;
          _districtList = state.districtList ?? [];
          _communeList = state.communeList ?? [];
          _selectedCommune = state.selectedCommuneCode;
          _selectedDistrict = state.selectedDistrictCode;
          stationCreateBloc.add(UpdateFullAddressEvent(
            address: _addressController.text,
            commune: null, // Reset
            district: null, // Reset
            province: _selectedProvince,
          ));
        }
        if (state is LoadCommunesState) {
          _isLoadingCommunes = state.isLoadingCommunes;
          _communeList = state.communeList ?? [];
          _selectedCommune = state.selectedCommuneCode;
          stationCreateBloc.add(UpdateFullAddressEvent(
            address: _addressController.text,
            commune: null, // Reset
            district: _selectedDistrict,
            province: _selectedProvince,
          ));
        }
        if (state is StationCreate_LoadingState) {
          isLoading = state.isLoading;
        }
        if (state is StationCreateFailState) {
          // isLoading = state.isLoading;
          stationCreateBloc.add(GenerateCaptchaEvent());
        }

        return Material(
          color: AppColors.mainBackground, // Màu nền tối bên ngoài
          child: Stack(
            fit: StackFit.expand,
            children: [
              ListView(
                //  Cho phép cuộn nếu form quá dài trên màn hình nhỏ
                // physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0.0),
                children: [
                  Container(
                    // Thêm padding cho toàn bộ body
                    padding: const EdgeInsets.all(40.0),
                    alignment: Alignment.center,
                    child: Container(
                      // Đây là Container chính với hiệu ứng glow
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGlow,
                            blurRadius: 20.0,
                            spreadRadius: 0.5,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      //  Thay Column cũ bằng Form mới
                      child: _buildCreateForm(),
                    ),
                  ),
                  // 3. Footer (Copyright)
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

  // --- WIDGET MỚI: FORM TẠO TÀI KHOẢN ---
  Widget _buildCreateForm() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey, //  Gán key
        //  Thêm autovalidateMode
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề "Thông tin Station"
            const Text(
              "Thông tin Station",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: AppColors.inputBackground, height: 32),
            const SizedBox(height: 32),

            // 2. Hình ảnh Uploader
            _buildImageUploader(),
            const SizedBox(height: 32),

            // 3. Tên Station (Full width)
            _buildTextFormField(
              label: "Tên Station",
              hint: "Way Station - 483 Thống Nhất",
              controller: _stationNameController,
              validator: (val) =>
                  (val?.isEmpty ?? true) ? "Vui lòng nhập Tên Station" : null,
            ),
            const SizedBox(height: 24),

            // 4. SỐ ĐIỆN THOẠI (Full width)
            _buildTextFormField(
              label: "Số điện thoại",
              hint: "09xx.xxx.xxx",
              controller: _hotlineController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              validator: (val) =>
                  (val?.isEmpty ?? true) ? "Vui lòng nhập SĐT" : null,
            ),
            const SizedBox(height: 24),

            // 5. Lưới Form (2 cột)
            LayoutBuilder(
              builder: (context, constraints) {
                // Nếu màn hình đủ rộng (ví dụ: > 650px), dùng 2 cột
                if (constraints.maxWidth > 650) {
                  return Column(
                    children: [
                      // Hàng 1 Tỉnh/TP và Phường/Xã
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildDropdownAPI<ProvinceModel>(
                            label: "Tỉnh/Thành phố",
                            hint: "Chọn Tỉnh/Thành phố",
                            value: _selectedProvince,
                            items: _provinceList
                                .map((p) => DropdownMenuItem(
                                    value: p, child: Text(p.name)))
                                .toList(),
                            isLoading: _isLoadingProvinces,
                            onChanged: (val) {
                              if (val == null) return;
                              stationCreateBloc
                                  .add(SelectedProvinceEvent(newValue: val));
                            },
                          )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _buildDropdownAPI<DistrictModel>(
                            label: "Quận/huyện",
                            hint: "Chọn Quận/Huyện",
                            value: _selectedDistrict,
                            items: _districtList
                                .map((d) => DropdownMenuItem(
                                    value: d, child: Text(d.name)))
                                .toList(),
                            isLoading: _isLoadingDistricts,
                            // Vô hiệu hóa nếu chưa chọn Tỉnh/TP
                            onChanged: _selectedProvince == null
                                ? null
                                : (val) {
                                    if (val == null) return;
                                    stationCreateBloc.add(
                                        SelectedDistrictEvent(newValue: val));
                                  },
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Hàng 2 Phường/Xã | Địa chỉ chi tiết
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildDropdownAPI<CommuneModel>(
                            label: "Phường/Xã/Thị trấn",
                            hint: "Chọn Phường/Xã",
                            value: _selectedCommune,
                            items: _communeList
                                .map((w) => DropdownMenuItem(
                                    value: w, child: Text(w.name)))
                                .toList(),
                            isLoading: _isLoadingCommunes,
                            // Vô hiệu hóa nếu chưa chọn Quận/Huyện
                            onChanged: _selectedDistrict == null
                                ? null
                                : (val) {
                                    if (val == null) return;
                                    stationCreateBloc.add(
                                        SelectedCommuneEvent(newValue: val));
                                  },
                          )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _buildTextFormField(
                            label: "Địa chỉ chi tiết (Số nhà, đường)",
                            hint: "483 Thống Nhất",
                            controller: _addressController,
                            // (Listener trong initState đã xử lý onChanged)
                            validator: (val) => (val?.isEmpty ?? true)
                                ? "Vui lòng nhập địa chỉ"
                                : null,
                          )),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Màn hình hẹp, dùng 1 cột
                  return Column(
                    children: [
                      _buildDropdownAPI<ProvinceModel>(
                        label: "Tỉnh/Thành phố",
                        hint: "Chọn Tỉnh/Thành phố",
                        value: _selectedProvince,
                        items: _provinceList
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p.name)))
                            .toList(),
                        isLoading: _isLoadingProvinces,
                        onChanged: (val) {
                          if (val == null) return;
                          stationCreateBloc
                              .add(SelectedProvinceEvent(newValue: val));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDropdownAPI<DistrictModel>(
                        label: "Quận/huyện",
                        hint: "Chọn Quận/Huyện",
                        value: _selectedDistrict,
                        items: _districtList
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d.name)))
                            .toList(),
                        isLoading: _isLoadingDistricts,
                        onChanged: _selectedProvince == null
                            ? null
                            : (val) {
                                if (val == null) return;
                                stationCreateBloc
                                    .add(SelectedDistrictEvent(newValue: val));
                              },
                      ),
                      const SizedBox(height: 24),
                      _buildDropdownAPI<CommuneModel>(
                        label: "Phường/Xã/Thị trấn",
                        hint: "Chọn Phường/Xã",
                        value: _selectedCommune,
                        items: _communeList
                            .map((w) =>
                                DropdownMenuItem(value: w, child: Text(w.name)))
                            .toList(),
                        isLoading: _isLoadingCommunes,
                        onChanged: _selectedDistrict == null
                            ? null
                            : (val) {
                                if (val == null) return;
                                stationCreateBloc
                                    .add(SelectedCommuneEvent(newValue: val));
                              },
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        label: "Địa chỉ chi tiết (Số nhà, đường)",
                        hint: "483 Thống Nhất",
                        controller: _addressController,
                        // (Listener trong initState đã xử lý onChanged)
                        validator: (val) => (val?.isEmpty ?? true)
                            ? "Vui lòng nhập địa chỉ"
                            : null,
                      )
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // 6. THÊM: Địa chỉ đầy đủ (Read-only)
            _buildTextFormField(
              label: "Địa chỉ",
              hint: "Địa chỉ đầy đủ sẽ tự động hiển thị ở đây...",
              controller: _fullAddressController, // Dùng controller mới
              readOnly: true, // Không cho sửa
            ),
            const SizedBox(height: 32),
            // 5. Captcha
            _buildCaptchaSection(),
            const SizedBox(height: 40),

            // 6. Buttons
            _buildActionButtons(),
            const SizedBox(height: 16), // Thêm padding dưới
          ],
        ),
      ),
    );
  }

  // --- SỬA: WIDGET CON: Hình ảnh ---
  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hình ảnh",
          style: TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.textHint, width: 1.0),
          ),
          child: _base64Images.isEmpty
              // 1. Nút "Tải lên" (nếu rỗng)
              ? Center(
                  child: TextButton.icon(
                    onPressed: () {
                      if (!_isPickingImage) {
                        stationCreateBloc.add(
                            PickImagesEvent(isPickingImage: _isPickingImage));
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
              // 2. Lưới ảnh (nếu có ảnh)
              : _buildImageGridView(),
        ),
        // 3. Nút "Thêm ảnh" (nếu có ảnh)
        if (_base64Images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () {
                if (!_isPickingImage) {
                  stationCreateBloc
                      .add(PickImagesEvent(isPickingImage: _isPickingImage));
                }
              },
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.textWhite, size: 16),
              label: const Text(
                "Thêm ảnh khác",
                style: TextStyle(color: AppColors.textWhite, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // --- THÊM: Widget GridView cho ảnh ---
  Widget _buildImageGridView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // SỬA: Bọc trong ScrollConfiguration để bật tính năng
      // cuộn bằng cách "kéo" (drag) trên web
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          // Kích hoạt tính năng kéo bằng chuột, cảm ứng, v.v.
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
          },
        ),
        child: Scrollbar(
          thumbVisibility: true, // Luôn hiển thị thanh cuộn
          controller: ScrollController(), // Thêm controller cho scrollbar
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Cuộn ngang
            itemCount: _base64Images.length,
            itemBuilder: (context, index) {
              // Lấy chuỗi base64 (ví dụ: "data:image/png;base64,iVBOR...")
              final String dataUri = _base64Images[index];
              // Tách phần data (sau dấu phẩy)
              final String base64String = dataUri.split(',').last;
              // Decode
              final imageBytes = base64Decode(base64String);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ảnh
                    Container(
                      width: 180,
                      height: 180,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Nút Xóa (Góc trên bên phải)
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 16,
                          splashRadius: 16,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            stationCreateBloc.add(RemoveImageEvent(
                                base64Images: _base64Images,
                                imageIndex: index));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  // ---------------------------------

  // ---  WIDGET CON: Text Field (Tùy chỉnh) ---
  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // SỬA
          readOnly: readOnly, // SỬA
          style: const TextStyle(color: AppColors.textWhite),
          keyboardType: keyboardType, // THÊM
          inputFormatters: inputFormatters, // THÊM
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint, // SỬA
            hintStyle: const TextStyle(color: AppColors.textHint), // SỬA
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: AppColors.primaryGlow, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            // Thêm style cho lỗi (validator)
            errorStyle: TextStyle(color: Colors.redAccent[200]),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
          validator: validator, // SỬA
        ),
      ],
    );
  }

  // --- WIDGET CON: Dropdown (Tùy chỉnh) ---
  Widget _buildDropdownAPI<T>({
    required String label,
    required String hint,
    required T? value, // Sửa: Dùng int? (cho code)
    required List<DropdownMenuItem<T>>
        items, // Sửa: Dùng List<DropdownMenuItem<int>>
    required void Function(T?)? onChanged,
    bool isLoading = false,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          style: const TextStyle(color: AppColors.textWhite),
          dropdownColor: AppColors.inputBackground, // Nền của menu

          hint: Text(
            isLoading ? "Đang tải..." : hint, // Hiển thị loading
            style: const TextStyle(color: AppColors.textHint),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.textHint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: AppColors.primaryGlow, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),

          // Hiển thị loading hoặc danh sách
          items: isLoading ? [] : items,

          onChanged:
              onChanged, // Vô hiệu hóa (null) nếu isLoading hoặc chưa chọn
          validator: (val) {
            // Validator cho T?
            if (val == null) return "Vui lòng chọn $label";
            return null;
          },
        ),
      ],
    );
  }

  // --- THÊM: WIDGET CON MỚI: Hình ảnh Captcha Động ---
  Widget _buildLocalCaptchaImage() {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Màu nền ảnh captcha
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.textHint),
      ),
      child: Stack(
        children: [
          // Text Captcha
          Center(
            //  Dùng Row để render từng ký tự
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _captchaText.split('').map((char) {
                // Tạo 1 góc xoay ngẫu nhiên
                final double rotation =
                    (_random.nextDouble() * 0.4) - 0.2; // Xoay +/- 0.2 rad
                return Transform.rotate(
                  angle: rotation,
                  child: Text(
                    char,
                    style: GoogleFonts.permanentMarker(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      //  Lấy màu ngẫu nhiên cho từng ký tự
                      color: _getRandomCaptchaColor(),
                      decoration: TextDecoration.lineThrough, // Gạch ngang
                      decorationColor: Colors.black.withOpacity(0.5),
                      decorationThickness: 2.0,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Nút Refresh
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.blueAccent),
              onPressed: () => stationCreateBloc
                  .add(GenerateCaptchaEvent()), //  Gọi hàm tạo captcha mới
            ),
          ),
        ],
      ),
    );
  }
  // --------------------------------------------------

  // ---  WIDGET CON: Captcha ---
  Widget _buildCaptchaSection() {
    return Wrap(
      // Dùng Wrap để responsive
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        //  Gọi Widget Captcha động
        _buildLocalCaptchaImage(),

        // Ô nhập Captcha
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập mã xác thực",
              style: TextStyle(color: AppColors.textWhite, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: TextFormField(
                    controller: _captchaController, // SỬA
                    readOnly: _isCaptchaVerified, //  Khóa khi đã xác thực
                    style: TextStyle(
                        color: _isCaptchaVerified
                            ? AppColors.textHint
                            : AppColors.textWhite),
                    decoration: InputDecoration(
                      hintText: "Mã xác thực",
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      //  Đổi màu nền khi bị khóa
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.textHint),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.textHint),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  //  Logic cho nút Xác thực
                  onPressed: () {
                    if (!_isCaptchaVerified) {
                      stationCreateBloc.add(HandleVerifyCaptchaEvent(
                          captcha: _captchaController.text));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    //  Đổi màu khi đã xác thực
                    backgroundColor: _isCaptchaVerified
                        ? AppColors.activeStatus
                        : AppColors.btnSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: _isVerifyingCaptcha
                      // Hiển thị loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      // Hiển thị Text
                      : Text(_isCaptchaVerified ? "Đã xác thực" : "Xác thực",
                          style: TextStyle(
                              color: _isCaptchaVerified
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                              fontFamily: AppFonts.bold)),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  // ---  WIDGET CON: Nút bấm ---
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Nút TẠO TÀI KHOẢN
        ElevatedButton(
          //  Chỉ bật nút khi đã xác thực captcha
          onPressed: () {
            if (_isCaptchaVerified) {
              if (_formKey.currentState!.validate()) {
                stationCreateBloc.add(SubmitStationCreateEvent(
                    stationName: _stationNameController.text,
                    address: _fullAddressController.text,
                    hotline: _hotlineController.text,
                    province: _selectedProvince!.name,
                    district: _selectedDistrict!.name,
                    commune: _selectedCommune!.name,
                    media: _base64Images));
              }
            }
          },
          style: ElevatedButton.styleFrom(
            //  Đổi màu nền nếu nút bị vô hiệu hóa
            backgroundColor: _isCaptchaVerified
                ? AppColors.primaryGlow
                : AppColors.btnSecondary,
            disabledBackgroundColor: AppColors.btnSecondary
                .withOpacity(0.5), // Màu khi bị vô hiệu hóa
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
          child: const Text(
            "TẠO STATION",
            style: TextStyle(
                color: Colors.white, fontFamily: AppFonts.bold, fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),

        // Nút KHÔI PHỤC
        ElevatedButton(
          onPressed: () => stationCreateBloc.add(ResetFormEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ), // SỬA
          child: const Text(
            "KHÔI PHỤC",
            style: TextStyle(
                color: AppColors.textBlack,
                fontFamily: AppFonts.bold,
                fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),

        // THÊM: Nút TRỞ VỀ
        ElevatedButton(
          onPressed: () {
            Get.back(); // Quay về trang trước đó
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
          child: const Text(
            "TRỞ VỀ",
            style: TextStyle(
                color: AppColors.bgCard,
                fontFamily: AppFonts.bold,
                fontSize: 16),
          ),
        ),
      ],
    );
  }

  // --- WIDGET CON: FOOTER ---
  Widget _buildFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ),
    );
  }
}
