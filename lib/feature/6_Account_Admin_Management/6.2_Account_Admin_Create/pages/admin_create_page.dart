// ignore_for_file: type_literal_in_constant_pattern

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_text_styles.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/model/authentication_stations_model.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.2_Account_Admin_Create/bloc/admin_create_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

//! Admin Create - Tạo Station Admin !//

class AdminCreatePage extends StatefulWidget {
  const AdminCreatePage({super.key});

  @override
  State<AdminCreatePage> createState() => _AdminCreatePageState();
}

class _AdminCreatePageState extends State<AdminCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final AdminCreateBloc adminCreateBloc = AdminCreateBloc();

  // Controllers cho form chính
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identificationController = TextEditingController();

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
  // --- THÊM: State cho Station Dropdown ---
  int? _selectedStationId;
  // (Bạn sẽ load danh sách này từ BLoC/API)
  List<AuthStationsModel> _stationList = [];
  // ---------------------------------------

  // Trạng thái loading
  bool isLoading = true;

  // --- THÊM: State cho Upload Ảnh ---
  String? _base64Avatar; // Dạng: "data:image/png;base64,..."
  bool _isPickingImage = false;
  // --------------------------------

  @override
  void initState() {
    super.initState();
    adminCreateBloc.add(AdminCreateInitialEvent());
  }

  @override
  void dispose() {
    // --- THÊM: Dispose controllers ---
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _identificationController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Đây là layout gốc của AccountListPage
    return BlocConsumer<AdminCreateBloc, AdminCreateState>(
      bloc: adminCreateBloc,
      listener: (context, state) {
        if (state.status == AdminCreateStatus.failure) {
          ShowSnackBar(state.message, false);
        }

        if (state.status == AdminCreateStatus.success) {
          ShowSnackBar(state.message, true);
        }

        if (state.blocState == AdminCreateBlocState.AdminCreateSuccessState) {
          adminCreateBloc.add(ResetFormEvent());
        }
      },
      builder: (context, state) {
        isLoading = state.status == AdminCreateStatus.loading;
        _stationList = state.stations;
        _captchaText = state.captchaText;
        _isCaptchaVerified = state.isCaptchaVerified;
        _isVerifyingCaptcha = state.isVerifyingCaptcha;
        _selectedStationId = state.selectedAdminId;
        _isPickingImage = state.isPickingImage;
        _base64Avatar = state.avatarBase64;

        //
        if (state.isClearCaptchaController) {
          _captchaController.clear();
        }

        if (state.blocState == AdminCreateBlocState.VerifyCaptchaSuccessState) {
          _captchaController.value =
              TextEditingValue(text: state.captchaText.toString());
        }

        if (state.blocState == AdminCreateBlocState.ResetFormState) {
          //  Reset controllers mới
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _phoneController.clear();
          _identificationController.clear();
          _selectedStationId = null;
          _base64Avatar = null;
          _captchaController.clear();

          adminCreateBloc.add(GenerateCaptchaEvent());
        }
        if (state.blocState == AdminCreateBlocState.AdminCreateFailState) {
          adminCreateBloc.add(GenerateCaptchaEvent());
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
            // 1. Avatar Uploader
            _buildAvatarUploader(),
            const SizedBox(height: 32),

            // 2. Tiêu đề "Thông tin tài khoản"
            const Text(
              "Thông tin tài khoản",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: AppColors.inputBackground, height: 32),

            // 3. Lưới Form (2 cột)
            // Dùng LayoutBuilder để quyết định hiển thị 1 hay 2 cột
            LayoutBuilder(
              builder: (context, constraints) {
                // Nếu màn hình đủ rộng (ví dụ: > 600px), dùng 2 cột
                if (constraints.maxWidth > 650) {
                  return Column(
                    children: [
                      // ---  Hàng 1 (Tên, Email) ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildTextFormField(
                            label: "Tên tài khoản",
                            hint: "Nhập tên tài khoản",
                            controller: _usernameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                            ],
                            validator: (val) => (val?.isEmpty ?? true)
                                ? "Vui lòng nhập tên"
                                : null,
                          )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _buildTextFormField(
                            label: "Email",
                            hint: "netpool@gmail.com",
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[^a-zA-Z0-9@._-]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập email";
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return "Email không hợp lệ";
                              }
                              return null;
                            },
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // ---  Hàng 2 (Password, SĐT) ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildTextFormField(
                            label: "Mật khẩu",
                            hint: "Nhập mật khẩu",
                            controller: _passwordController,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                            ],
                            validator: (val) => (val?.isEmpty ?? true)
                                ? "Vui lòng nhập mật khẩu"
                                : null,
                          )),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _buildTextFormField(
                            label: "Số điện thoại",
                            hint: "09xx.xxx.xxx",
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.singleLineFormatter,
                            ],
                            validator: (val) => (val?.isEmpty ?? true)
                                ? "Vui lòng nhập SĐT"
                                : null,
                          )),
                        ],
                      ),
                      // (Bỏ hàng 3 - Giới tính, Ngày sinh)
                    ],
                  );
                } else {
                  // Màn hình hẹp, dùng 1 cột
                  return Column(
                    children: [
                      _buildTextFormField(
                        label: "Tên tài khoản",
                        hint: "Nhập tên tài khoản",
                        controller: _usernameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                        validator: (val) =>
                            (val?.isEmpty ?? true) ? "Vui lòng nhập tên" : null,
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        label: "Email",
                        hint: "netpool@gmail.com",
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                          FilteringTextInputFormatter.deny(
                              RegExp(r'[^a-zA-Z0-9@._-]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập email";
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return "Email không hợp lệ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        label: "Mật khẩu",
                        hint: "Nhập mật khẩu",
                        controller: _passwordController,
                        obscureText: true, // Thêm
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                        validator: (val) => (val?.isEmpty ?? true)
                            ? "Vui lòng nhập mật khẩu"
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        label: "Số điện thoại",
                        hint: "09xx.xxx.xxx",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (val) =>
                            (val?.isEmpty ?? true) ? "Vui lòng nhập SĐT" : null,
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // 4.  CCCD (Thay thế Địa chỉ)
            _buildTextFormField(
                label: "Số định danh cá nhân (CMND/CCCD)",
                hint: "Nhập số định danh",
                controller: _identificationController,
                keyboardType: TextInputType.number, // Thêm
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                  FilteringTextInputFormatter.digitsOnly, // Thêm
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (val) {
                  // Thêm validator (từ file cũ)
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập Số định danh';
                  }
                  if (val.length != 9 && val.length != 12) {
                    return 'Phải là 9 số (CMND) hoặc 12 số (CCCD)';
                  }
                  return null;
                }),

            const SizedBox(height: 24), // SỬA: Giảm khoảng cách

            // --- THÊM: Dropdown Station ---
            _buildStationDropdown(),
            // -----------------------------

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

// --- THÊM: WIDGET CON MỚI: Station Dropdown ---
  Widget _buildStationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tên Station", // Label
          style: TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
        const SizedBox(height: 8),
        // Dùng DropdownButtonFormField để có style và validation
        DropdownButtonFormField<int>(
          value: _selectedStationId,
          // icon: const Icon(Icons.arrow_drop_down, color: AppColors.textWhite),
          style: const TextStyle(color: AppColors.textWhite),
          dropdownColor: AppColors.inputBackground, // Nền của menu
          hint: Text(
            "Chọn Station ",
            style:
                const TextStyle(color: AppColors.textHint), // Đảm bảo màu đúng
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
          items: _stationList.map((AuthStationsModel station) {
            return DropdownMenuItem<int>(
              value: int.tryParse(station.stationId ?? ""),
              child: Text(station.stationName ?? ""),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue == null) return;

            adminCreateBloc.add(SelectedStationIdEvent(newValue: newValue));
          },
          validator: (val) {
            // Validator cho T?
            if (val == null) return "Vui lòng chọn Station";
            return null;
          },
          // (Tùy chọn: Thêm validator)
          // validator: (value) => value == null ? 'Vui lòng chọn Station' : null,
        ),
      ],
    );
  }
  // ---------------------------------------------

  // --- SỬA: WIDGET CON: Avatar ---
  Widget _buildAvatarUploader() {
    // Giải mã ảnh Base64 (nếu có)
    ImageProvider? backgroundImage;
    if (_base64Avatar != null) {
      try {
        final String base64String = _base64Avatar!.split(',').last;
        backgroundImage = MemoryImage(base64Decode(base64String));
      } catch (e) {
        print("Lỗi ảnh: $e");
      }
    }

    // SỬA: Dùng Row và căn chỉnh các thành phần bên trong
    return Row(
      children: [
        // Cụm Avatar và Nút (không dùng Stack để tránh lỗi hit-test)
        Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Căn đáy
          children: [
            // Avatar Circle
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.inputBackground,
              backgroundImage: backgroundImage,
              child: backgroundImage == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textHint,
                    )
                  : null,
            ),

            // Nút "Tải lên" (Nằm bên cạnh, không phải đè lên)
            TextButton.icon(
              onPressed: () {
                if (!_isPickingImage) {
                  adminCreateBloc
                      .add(PickAvatarEvent(isPickingImage: _isPickingImage));
                }
              },
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.textHint))
                  : const Icon(Icons.photo_camera,
                      color: AppColors.textHint, size: 16),
              label: Text(
                _isPickingImage
                    ? "Đang tải..."
                    : (_base64Avatar == null
                        ? "Tải lên ảnh đại diện"
                        : "Thay đổi ảnh"),
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.containerBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: AppColors.textHint.withOpacity(0.5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        )
      ],
    );
  }

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
              onPressed: () => adminCreateBloc
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
                      adminCreateBloc.add(HandleVerifyCaptchaEvent(
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
                setState(() {
                  _isCaptchaVerified = false;
                });
                adminCreateBloc.add(SubmitAdminCreateEvent(
                    email: _emailController.text,
                    password: _passwordController.text,
                    identification: _identificationController.text,
                    phone: _phoneController.text,
                    username: _usernameController.text,
                    stationId: _selectedStationId.toString(),
                    avatar: _base64Avatar));
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
            "TẠO TÀI KHOẢN NHÂN VIÊN",
            style: TextStyle(
                color: Colors.white, fontFamily: AppFonts.bold, fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),

        // Nút TẠO LẠI
        ElevatedButton(
          onPressed: () => adminCreateBloc.add(ResetFormEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ), // SỬA
          child: const Text(
            "TẠO LẠI",
            style: TextStyle(
                color: AppColors.textBlack,
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
