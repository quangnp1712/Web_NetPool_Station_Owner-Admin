// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.3_Autocomplete/models/autocomplete_model.dart';

import 'package:web_netpool_station_owner_admin/feature/5_Station_Management/5.4_Station_Detail_Update/bloc/station_detail_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';
import 'package:web_netpool_station_owner_admin/feature/data/city_controller/city_model.dart';

class StationEditDialog extends StatefulWidget {
  StationDetailBloc bloc;
  StationEditDialog({
    super.key,
    required this.bloc,
  });

  @override
  State<StationEditDialog> createState() => _StationEditDialogState();
}

class _StationEditDialogState extends State<StationEditDialog> {
  final _stationNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _hotlineController = TextEditingController();
  final _captchaController = TextEditingController();
  final _fullAddressController = TextEditingController(); // Readonly
  final ScrollController _imageScrollController = ScrollController();

  final Random _random = Random();
  final List<Color> _captchaColors = [
    Colors.black,
    const Color.fromARGB(255, 255, 58, 58),
    const Color.fromARGB(255, 35, 123, 254),
    const Color.fromARGB(255, 43, 246, 53),
    const Color.fromARGB(255, 255, 103, 53),
    const Color.fromARGB(255, 204, 85, 255),
  ];

  Color _getRandomCaptchaColor() {
    return _captchaColors[_random.nextInt(_captchaColors.length)];
  }

  Timer? _debounce;
  final FocusNode _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = widget.bloc.state;
    _stationNameController.text = state.stationName;
    _addressController.text = state.address;
    _hotlineController.text = state.phone;
    _fullAddressController.text = state.fullAddressController;
    _imageScrollController.dispose(); // Dispose scroll controller

    // Load Captcha khi mở dialog
    widget.bloc.add(LoadStationEditDialogEvent());
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

    super.dispose();
  }

  // --- Helper để tách chuỗi Full Address lấy phần tên đường ---
  String _parseAddressFromFullString(String? fullAddress) {
    if (fullAddress == null || fullAddress.isEmpty) return '';
    List<String> parts = fullAddress.split(',');
    // Yêu cầu: Bỏ 3 dấu phẩy (tức là 3 phần tử cuối: Xã, Huyện, Tỉnh)
    if (parts.length > 3) {
      return parts.sublist(0, parts.length - 3).join(',').trim();
    }
    // Nếu chuỗi ngắn quá (chưa đủ thông tin), trả về nguyên chuỗi
    return fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border)),
      child: BlocConsumer<StationDetailBloc, StationDetailState>(
        bloc: widget.bloc,
        listener: (context, state) {
          // Cập nhật Full Address khi dropdown đổi
          _fullAddressController.text = state.fullAddressController;
          if (state.isClearCaptchaController) {
            _captchaController.clear();
          }
          if (state.blocState ==
              StationDetailBlocState.StationUpdateSuccessState) {
            Navigator.pop(context);
          }
          if (state.stationDetailStatus == StationDetailStatus.failure &&
              state.message != "") {
            ShowSnackBar(state.message, false);
          }
          if (state.stationDetailStatus == StationDetailStatus.success &&
              state.message != "") {
            ShowSnackBar(state.message, true);
          }
        },
        builder: (context, state) {
          _stationNameController.text = state.stationName;
          _addressController.text = state.address;
          _hotlineController.text = state.phone;
          _fullAddressController.text = state.fullAddressController;
          if (state.blocState == StationDetailBlocState.SelectedProvinceState) {
            if (state.selectedProvince != null) {
              widget.bloc.add(LoadDistrictsEvent(
                  provinceCode: state.selectedProvince!.code));
            }
          }
          if (state.blocState == StationDetailBlocState.SelectedDistrictState) {
            if (state.selectedDistrict != null) {
              widget.bloc.add(LoadCommunesEvent(
                  districtCode: state.selectedDistrict!.code));
            }
          }
          if (state.blocState == StationDetailBlocState.SelectedCommuneState) {
            widget.bloc.add(UpdateFullAddressEvent(
              address: _addressController.text,
              commune: state.selectedCommune,
              district: state.selectedDistrict,
              province: state.selectedProvince,
            ));
          }

          if (state.blocState == StationDetailBlocState.LoadDistrictsState) {
            widget.bloc.add(UpdateFullAddressEvent(
              address: _addressController.text,
              commune: null, // Reset
              district: null, // Reset
              province: state.selectedProvince,
            ));
          }

          if (state.blocState == StationDetailBlocState.LoadCommunesState) {
            widget.bloc.add(UpdateFullAddressEvent(
              address: _addressController.text,
              commune: null, // Reset
              district: state.selectedDistrict,
              province: state.selectedProvince,
            ));
          }

          return Container(
            width: 900,
            height: 700, // Tăng chiều cao để chứa form dài
            child: Stack(
              children: [
                Column(
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
                              icon: const Icon(Icons.close,
                                  color: AppColors.textHint)),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),

                    // Body (Scrollable)
                    Expanded(
                        child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Image Uploader (Logic cũ)
                          _buildImageUploader(context, state),
                          const SizedBox(height: 32),

                          // 2. Thông tin cơ bản
                          Row(
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

                          // 3. Dropdowns (Logic cũ)
                          Row(
                            children: [
                              Expanded(
                                  child: _buildDropdownAPI<ProvinceModel>(
                                label: "Tỉnh/Thành",
                                hint: "Chọn Tỉnh",
                                value: state.selectedProvince,
                                items: state.provincesList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (v) => widget.bloc
                                    .add(SelectedProvinceEvent(newValue: v!)),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildDropdownAPI<DistrictModel>(
                                label: "Quận/Huyện",
                                hint: "Chọn Quận",
                                value: state.selectedDistrict,
                                isLoading: state.isLoadingDistricts,
                                items: state.districtList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (v) => widget.bloc
                                    .add(SelectedDistrictEvent(newValue: v!)),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildDropdownAPI<CommuneModel>(
                                label: "Phường/Xã",
                                hint: "Chọn Phường",
                                value: state.selectedCommune,
                                isLoading: state.isLoadingCommunes,
                                items: state.communeList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e.name)))
                                    .toList(),
                                onChanged: (v) => widget.bloc
                                    .add(SelectedCommuneEvent(newValue: v!)),
                              )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAddressAutocompleteField(context, state),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                              label: "Địa chỉ đầy đủ (Preview)",
                              controller: _fullAddressController,
                              hint: "...",
                              readOnly: true),

                          const SizedBox(height: 32),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),

                          // 4. Captcha (Logic cũ)
                          _buildCaptchaSection(context, state),
                        ],
                      ),
                    )),

                    // Footer Actions
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
                          BlocBuilder<StationDetailBloc, StationDetailState>(
                            builder: (context, state) {
                              return ElevatedButton.icon(
                                onPressed: state.isCaptchaVerified
                                    ? () {
                                        widget.bloc.add(
                                          StationUpdateEvent(
                                              stationName:
                                                  _stationNameController.text,
                                              address:
                                                  _fullAddressController.text,
                                              province: state
                                                      .selectedProvince?.name ??
                                                  "",
                                              commune:
                                                  state.selectedCommune?.name ??
                                                      "",
                                              district: state
                                                      .selectedDistrict?.name ??
                                                  "",
                                              hotline: _hotlineController.text,
                                              media: state.base64Images,
                                              placeId: state.placeId ?? ""),
                                        );
                                      }
                                    : null, // Disable if captcha not verified
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Loading Overlay for Event: StationUpdateEvent
                if (state.stationDetailStatus ==
                    StationDetailStatus.loadingDialog)
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
          );
        },
      ),
    );
  }

  // --- REUSED WIDGETS FROM OLD CODE ---

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

  // --- ADDRESS AUTOCOMPLETE WIDGET ---
  Widget _buildAddressAutocompleteField(
      BuildContext context, StationDetailState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Địa chỉ chi tiết (Số nhà, đường)",
          style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      RawAutocomplete<AutocompleteModel>(
        // Changed to AutocompleteModel
        textEditingController: _addressController,
        focusNode: _addressFocusNode,
        //  hiển thị vào ô input khi người dùng chọn
        displayStringForOption: (AutocompleteModel option) =>
            _parseAddressFromFullString(option.address),

        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            widget.bloc.add(ClearAddressSuggestionsEvent());
            return const Iterable<AutocompleteModel>.empty();
          }
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 100), () {
            widget.bloc.add(SearchAddressSuggestionEvent(
              textEditingValue.text,
            ));
          });
          return state.addressSuggestions;
        },
        onSelected: (AutocompleteModel selection) {
          // Handle selection, fill address text with SHORT address
          String shortAddr = _parseAddressFromFullString(selection.address);
          _addressController.text = shortAddr;

          widget.bloc.add(UpdateFullAddressEvent(
            address: shortAddr,
            province: state.selectedProvince,
            district: state.selectedDistrict,
            commune: state.selectedCommune,
            placeId: selection.placeId,
          ));
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
              widget.bloc.add(UpdateFullAddressEvent(
                address: val,
                province: state.selectedProvince,
                district: state.selectedDistrict,
                commune: state.selectedCommune,
                placeId: null, // Reset placeId
              ));
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
                // Loading indicator
                suffixIcon: state.isLoadingAddressSuggestions
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
                        // Ở đây vẫn hiển thị FULL address để người dùng chọn
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

  Widget _buildDropdownAPI<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    bool isLoading = false,
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
              hint: Text(isLoading ? "Đang tải..." : hint,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textHint)),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textHint),
              items: isLoading ? [] : items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptchaSection(BuildContext context, StationDetailState state) {
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
              // Cập nhật: Sử dụng _getRandomCaptchaColor
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.captchaText.split('').map((char) {
                    return Transform.rotate(
                      angle: (_random.nextDouble() * 0.4) -
                          0.2, // Xoay ngẫu nhiên từ -0.2 đến 0.2 rad
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
                      onPressed: () =>
                          widget.bloc.add(GenerateCaptchaEvent()))),
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
                icon: state.isVerifyingCaptcha
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(
                        state.isCaptchaVerified
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                        color: state.isCaptchaVerified
                            ? AppColors.activeStatus
                            : AppColors.textWhite),
                onPressed: () {
                  if (!_captchaController.text.isEmpty) {
                    widget.bloc.add(HandleVerifyCaptchaEvent(
                        captcha: _captchaController.text));
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploader(BuildContext context, StationDetailState state) {
    final isReadOnly = !state.isEditMode;
    final _base64Images = state.base64Images;
    final _isPickingImage = state.isPickingImage;

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
              ? isReadOnly
                  ? Center(
                      child: Text("Không có hình ảnh",
                          style: TextStyle(color: Colors.grey.shade500)))
                  : Center(
                      child: TextButton.icon(
                        onPressed: () {
                          if (!_isPickingImage) {
                            widget.bloc.add(PickImagesEvent(
                                isPickingImage: _isPickingImage));
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
                          backgroundColor:
                              AppColors.btnSecondary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    )
              // 2. Lưới ảnh (nếu có ảnh)
              : _buildImageGridView(context, state),
        ),
        if (!isReadOnly && _base64Images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () {
                if (!state.isPickingImage) {
                  widget.bloc.add(
                      PickImagesEvent(isPickingImage: state.isPickingImage));
                }
              },
              icon: state.isPickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.white),
              label: Text(
                  state.isPickingImage ? "Đang xử lý..." : "Thêm/Thay đổi ảnh",
                  style: const TextStyle(color: Colors.white)),
            ),
          )
      ],
    );
  }

  Widget _buildImageGridView(BuildContext context, StationDetailState state) {
    final isReadOnly = !state.isEditMode;
    final _base64Images = state.base64Images;

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
          thumbVisibility: true, // Luôn hiển thị thanh cuộn
          controller: _imageScrollController, // Sử dụng controller từ state
          child: ListView.builder(
            controller: _imageScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _base64Images.length,
            itemBuilder: (context, index) {
              String imageSource = _base64Images[index];
              bool isUrl = imageSource.startsWith('http'); // Kiểm tra URL

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isUrl
                          // Trường hợp 1: URL (Ảnh từ API)
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
                          // Trường hợp 2: Base64 (Ảnh mới chọn)
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
                    // Nút xóa ảnh
                    if (!isReadOnly)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => widget.bloc.add(RemoveImageEvent(
                              base64Images: _base64Images, imageIndex: index)),
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
    );
  }
}
