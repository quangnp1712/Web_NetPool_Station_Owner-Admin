import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/bloc/admin_detail_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/6_Account_Admin_Management/6.3_Account_Admin_Detail/shared_preferences/admin_detail_shared_pref.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

class AdminDetailPage extends StatefulWidget {
  const AdminDetailPage({super.key});

  @override
  State<AdminDetailPage> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<AdminDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminDetailBloc adminDetailBloc = AdminDetailBloc();

// accountId
  late final String accountId;

  // Controllers
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _identificationController;
  late final TextEditingController _captchaController;

  final Random _random = Random();
  final List<Color> _captchaColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple
  ];
  Color _getRandomCaptchaColor() =>
      _captchaColors[_random.nextInt(_captchaColors.length)];

  @override
  void initState() {
    super.initState();
    // acountID
    if (AdminDetailSharedPref.getAccountId() != "") {
      accountId = AdminDetailSharedPref.getAccountId();
    } else {
      accountId = "4";
    }
    // -----
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _identificationController = TextEditingController();
    _captchaController = TextEditingController();

    // LUÔN GỌI INIT ĐỂ LOAD CHI TIẾT
    adminDetailBloc.add(InitAdminDetailEvent(accountId: accountId));
  }

  @override
  void dispose() {
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
    return BlocConsumer<AdminDetailBloc, AdminDetailState>(
      bloc: adminDetailBloc,
      listener: (context, state) {
        if (state.status == AdminDetailStatus.success) {
          ShowSnackBar(state.message, true);
        }
        if (state.status == AdminDetailStatus.failure) {
          ShowSnackBar(state.message, false);
        }

        // Sync Data to Controllers (Chỉ khi vừa load xong hoặc reset)
      },
      builder: (context, state) {
        final isLoading = state.status == AdminDetailStatus.loading;
        if (_usernameController.text.isEmpty && state.username != null) {
          _usernameController.text = state.username ?? "";
          _emailController.text = state.email ?? "";
          _phoneController.text = state.phone ?? "";
          _identificationController.text = state.identification ?? "";
        }

        if (state.isClearCaptchaController) {
          _captchaController.clear();
        }
        if (state.blocState == AdminDetailBlocState.ResetCaptchaState) {
          adminDetailBloc.add(GenerateCaptchaEvent());
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
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGlow)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormContent(BuildContext context, AdminDetailState state) {
    // Tiêu đề chỉ còn 2 trạng thái
    final String title =
        state.isEditMode ? "Cập nhật Quản trị viên" : "Chi tiết Quản trị viên";

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Avatar
            _buildAvatarUploader(context, state),
            const SizedBox(height: 32),

            // 2. Header + Badge Mode
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
                      color: state.isReadOnly
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              state.isReadOnly ? Colors.blue : Colors.orange)),
                  child: Text(
                      state.isReadOnly ? "Chế độ xem" : "Đang chỉnh sửa",
                      style: TextStyle(
                          color: state.isReadOnly ? Colors.blue : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Divider(color: AppColors.inputBackground, height: 32),

            // 3. Fields: Username + Email
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 650) {
                  return Row(
                    children: [
                      Expanded(
                          child: _buildTextFormField(
                              label: "Tên tài khoản",
                              hint: "Nhập tên",
                              controller: _usernameController,
                              readOnly: state.isReadOnly)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildTextFormField(
                        label: "Email",
                        hint: "email@gmail.com",
                        controller: _emailController,
                        readOnly: state.isReadOnly,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                          FilteringTextInputFormatter.deny(
                              RegExp(r'[^a-zA-Z0-9@._-]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
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
                  );
                } else {
                  return Column(
                    children: [
                      _buildTextFormField(
                          label: "Tên tài khoản",
                          hint: "Nhập tên",
                          controller: _usernameController,
                          readOnly: state.isReadOnly),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        label: "Email",
                        hint: "email@gmail.com",
                        controller: _emailController,
                        readOnly: state.isReadOnly,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                          FilteringTextInputFormatter.deny(
                              RegExp(r'[^a-zA-Z0-9@._-]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return "Email không hợp lệ";
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // 4. Fields: Password + Phone
            Row(
              children: [
                if (state.isEditMode) ...[
                  Expanded(
                      child: _buildTextFormField(
                          label: "Mật khẩu mới (để trống nếu không đổi)",
                          hint: "Nhập mật khẩu",
                          controller: _passwordController,
                          obscureText: true,
                          readOnly: false)),
                  const SizedBox(width: 24),
                ],
                Expanded(
                    child: _buildTextFormField(
                        label: "Số điện thoại",
                        hint: "09xx...",
                        controller: _phoneController,
                        readOnly: state.isReadOnly,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ])),
              ],
            ),
            const SizedBox(height: 24),

            // 5. CCCD
            _buildTextFormField(
              label: "Số định danh (CMND/CCCD)",
              hint: "Nhập số",
              controller: _identificationController,
              readOnly: state.isReadOnly,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12)
              ],
              validator: (val) {
                // Thêm validator (từ file cũ)
                if (val == null || val.isEmpty) {
                  return null;
                }
                if (val.length != 9 && val.length != 12) {
                  return 'Phải là 9 số (CMND) hoặc 12 số (CCCD)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 6. [QUAN TRỌNG] Station + Status (Cùng hàng)
            _buildStationAndStatusSection(context, state),

            const SizedBox(height: 32),

            // 7. Captcha (Chỉ hiện khi Edit)
            if (state.isEditMode) ...[
              _buildCaptchaSection(context, state),
              const SizedBox(height: 40),
            ],

            // 8. Buttons
            _buildActionButtons(context, state),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: STATION & STATUS ---
  Widget _buildStationAndStatusSection(
      BuildContext context, AdminDetailState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột 1: Station Dropdown (7 phần)
        Expanded(
            flex: 6,
            child: _buildTextFormFieldStation(
              label: "Station quản lý",
              hint: "Station",
              controller: TextEditingController(text: state.selectedStationId),
              readOnly: state.isReadOnly,
            )

            // $ dropdown station
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text("Station quản lý",
            //         style: TextStyle(
            //             color: AppColors.textWhite.withOpacity(0.7),
            //             fontSize: 14,
            //             fontWeight: FontWeight.w500)),
            //     const SizedBox(height: 8),
            //     DropdownButtonFormField<String>(
            //       value: state.selectedStationId,
            //       dropdownColor: AppColors.inputBackground,
            //       style: const TextStyle(color: AppColors.textWhite),
            //       decoration: InputDecoration(
            //         filled: true,
            //         fillColor: state.isReadOnly
            //             ? Colors.transparent
            //             : AppColors.inputBackground,
            //         border: state.isReadOnly
            //             ? const UnderlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.white24))
            //             : OutlineInputBorder(
            //                 borderRadius: BorderRadius.circular(8),
            //                 borderSide:
            //                     const BorderSide(color: AppColors.textHint)),
            //         enabledBorder: state.isReadOnly
            //             ? const UnderlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.white24))
            //             : OutlineInputBorder(
            //                 borderRadius: BorderRadius.circular(8),
            //                 borderSide: BorderSide(
            //                     color: AppColors.textHint.withOpacity(0.5))),
            //         focusedBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8),
            //             borderSide: const BorderSide(
            //                 color: AppColors.primaryGlow, width: 2)),
            //         contentPadding:
            //             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            //         isDense: true,
            //       ),
            //       items: state.stationList
            //           .map((s) => DropdownMenuItem(
            //               value: s.stationId, child: Text(s.stationName ?? "")))
            //           .toList(),
            //       onChanged: state.isReadOnly
            //           ? null
            //           : (val) {
            //               adminDetailBloc.add(SelectedStationEvent(val));
            //             },
            //       icon: state.isReadOnly
            //           ? const SizedBox.shrink()
            //           : const Icon(Icons.keyboard_arrow_down,
            //               color: Colors.white70),
            //       // Fix màu text khi disabled
            //       selectedItemBuilder: (context) => state.stationList
            //           .map((s) => Text(s.stationName ?? "",
            //               style: TextStyle(
            //                   color: state.isReadOnly
            //                       ? AppColors.textWhite.withOpacity(0.9)
            //                       : Colors.white)))
            //           .toList(),
            //     ),
            //   ],
            // ),
            ),

        const SizedBox(width: 24),

        // 2. Status (3 phần) - Dropdown khi Edit, Badge khi View
        Expanded(
          flex: 4, // Tỷ lệ 4
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Trạng thái",
                  style: TextStyle(
                      color: AppColors.textWhite.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              if (state.isReadOnly)
                // VIEW MODE: Badge
                Container(
                  height: 48,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: _getStatusColor(state.statusCode)
                              .withOpacity(0.5),
                          width: 1)),
                  alignment: Alignment.centerLeft,
                  child: Text(state.statusName ?? "...",
                      style: TextStyle(
                          color: _getStatusColor(state.statusCode),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                )
              else
                // EDIT MODE: Row [Dropdown + UpdateButton]
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.statusCode,
                        dropdownColor: AppColors.inputBackground,
                        style: const TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: AppColors.textHint)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGlow, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'ENABLE', child: Text("Kích hoạt")),
                          DropdownMenuItem(
                              value: 'DISABLE', child: Text("Vô hiệu")),
                        ],
                        onChanged: (val) =>
                            adminDetailBloc.add(SelectedStatusEvent(val)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút cập nhật trạng thái riêng biệt
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isCaptchaVerified
                            ? () => adminDetailBloc.add(SubmitChangeStatusEvent(
                                status: state.statusCode))
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.menuOnHover,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: state.blocState ==
                                AdminDetailBlocState.ChangeStatusLoadingState
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_as_outlined,
                                color: Colors.white),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? code) {
    switch (code?.toUpperCase()) {
      case 'ACTIVE':
      case 'ENABLE':
        return Colors.green;
      case 'INACTIVE':
      case 'DISABLE':
        return Colors.redAccent;
      case 'PENDING':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  // --- OTHER WIDGETS (Avatar, Captcha, Buttons...) ---
  // (Giữ nguyên logic như phiên bản trước, chỉ khác là loại bỏ nút Create)

  Widget _buildActionButtons(BuildContext context, AdminDetailState state) {
    final backButton = ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text("TRỞ VỀ",
            style: TextStyle(
                color: AppColors.bgCard, fontWeight: FontWeight.bold)));

    if (state.isReadOnly) {
      // View Mode
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: () => adminDetailBloc.add(ToggleEditModeEvent(true)),
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
      // Edit Mode
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: state.isCaptchaVerified
              ? () => adminDetailBloc.add(SubmitUpdateAdminEvent(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  phone: _phoneController.text,
                  identification: _identificationController.text))
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
          onPressed: () => adminDetailBloc
              .add(InitAdminDetailEvent(accountId: accountId)), // Cancel
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

  Widget _buildAvatarUploader(BuildContext context, AdminDetailState state) {
    // Logic hiển thị ảnh (URL hoặc Base64)
    ImageProvider? bg;
    if (state.avatar != null && state.avatar!.isNotEmpty) {
      if (state.avatar!.startsWith('http')) {
        bg = NetworkImage(state.avatar!);
      } else {
        try {
          bg = MemoryImage(base64Decode(state.avatar!.split(',').last));
        } catch (_) {}
      }
    }
    return Row(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Căn đáy

          children: [
            CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.inputBackground,
                backgroundImage: bg,
                child: bg == null
                    ? const Icon(Icons.person,
                        size: 60, color: AppColors.textHint)
                    : null),
            if (!state.isReadOnly)
              TextButton.icon(
                onPressed: () => adminDetailBloc.add(PickAvatarEvent()),
                icon: state.isPickingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textHint,
                        ))
                    : const Icon(Icons.camera_alt, color: Colors.white70),
                label: Text(
                  state.isPickingImage ? "Đang tải..." : "Đổi ảnh",
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.containerBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side:
                        BorderSide(color: AppColors.textHint.withOpacity(0.5)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptchaSection(BuildContext context, AdminDetailState state) {
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
                      onPressed: () =>
                          adminDetailBloc.add(GenerateCaptchaEvent())))
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
                          onPressed: state.isCaptchaVerified
                              ? null
                              : () => adminDetailBloc.add(
                                  HandleVerifyCaptchaEvent(
                                      _captchaController.text))))))
        ]);
  }

  Widget _buildTextFormField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      String? Function(String?)? validator,
      bool readOnly = false,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      bool obscureText = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: TextStyle(
            color: readOnly
                ? AppColors.textWhite.withOpacity(0.9)
                : AppColors.textWhite,
            fontWeight: readOnly ? FontWeight.normal : FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.5)),
          filled: true,
          fillColor: readOnly ? Colors.transparent : AppColors.inputBackground,
          border: readOnly
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24))
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.textHint)),
          enabledBorder: readOnly
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24))
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.textHint.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primaryGlow, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
        validator: validator,
      )
    ]);
  }

  Widget _buildTextFormFieldStation(
      {required String label,
      required String hint,
      required TextEditingController controller,
      String? Function(String?)? validator,
      bool readOnly = false,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      bool obscureText = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: true,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: TextStyle(
            color: readOnly
                ? AppColors.textWhite.withOpacity(0.9)
                : AppColors.textWhite,
            fontWeight: readOnly ? FontWeight.normal : FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.5)),
          filled: true,
          fillColor: readOnly ? Colors.transparent : AppColors.inputBackground,
          border: readOnly
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24))
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.textHint)),
          enabledBorder: readOnly
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24))
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.textHint.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primaryGlow, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
        validator: validator,
      )
    ]);
  }

  Widget _buildFooter() => Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text('Copyright © 2025 NETPOOL. All rights reserved.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12))));
}
