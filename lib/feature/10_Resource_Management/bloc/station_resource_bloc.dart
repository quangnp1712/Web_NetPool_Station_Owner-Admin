import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/model/resoucre_spec_model.dart';
import 'package:web_netpool_station_owner_admin/feature/10_Resource_Management/repository/resouce_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/model/station_space_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/8_Space_Management/repository/space_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/model/area_list_response_model.dart';
import 'package:web_netpool_station_owner_admin/feature/9_Area_Management/repository/area_list_repository.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page_top_menu/controller/user_session_controller.dart';
import 'package:web_netpool_station_owner_admin/feature/data/meta/model/meta_model.dart';

part 'station_resource_event.dart';
part 'station_resource_state.dart';

class StationResourceBloc
    extends Bloc<StationResourceEvent, StationResourceState> {
  StationResourceBloc() : super(StationResourceState()) {
    on<InitResourcePageEvent>(_onInit);
    on<ResourceLoadDataEvent>(_onLoadData);
    on<SelectSpaceEvent>(_onSelectSpace);
    on<SelectAreaEvent>(_onSelectArea);
    on<SelectStatusEvent>(_onSelectStatus);
    on<SearchResourceEvent>(_onSearch);
    on<ChangePageEvent>(_onChangePage);
    on<CreateResourcesEvent>(_onCreateResources);
    on<UpdateResourceEvent>(_onUpdateResource);
    on<ToggleResourceStatusEvent>(_onToggleStatus);
  }

//! _onInit
  FutureOr<void> _onInit(
      InitResourcePageEvent event, Emitter<StationResourceState> emit) async {
    emit(state.copyWith(status: ResourceStatus.loading));
    try {
      //! 1 API STATION SPACE
      List<StationSpaceModel> stationSpaces = [];
      final session = Get.find<UserSessionController>();
      final stationId = session.activeStationId.value;
      var resultsSpace =
          await StationSpaceRepository().getStationSpace(stationId.toString());
      var responseMessageSpace = resultsSpace['message'];
      var responseStatusSpace = resultsSpace['status'];
      var responseSuccessSpace = resultsSpace['success'];
      var responseBodySpace = resultsSpace['body'];
      if (responseSuccessSpace || responseStatusSpace == 200) {
        StationSpaceListModelResponse resultsBodySpace =
            StationSpaceListModelResponse.fromJson(responseBodySpace);
        if (resultsBodySpace.data != null) {
          if (resultsBodySpace.data!.isNotEmpty) {
            try {
              stationSpaces = resultsBodySpace.data!;
            } catch (e) {
              stationSpaces = [];
            }
          }
        }
      }
      // Mặc định chọn NET
      final defaultSpace =
          stationSpaces.isNotEmpty ? stationSpaces.first : null;
      if (stationSpaces.isEmpty) {
        emit(state.copyWith(status: ResourceStatus.success, spaceOptions: []));
        return;
      }
      //! 2 API STATION AREA
      List<AreaModel> areas = [];
      var resultsArea = await AreaListRepository().getArea(
        "",
        stationId.toString(),
        stationSpaces.first.spaceId.toString(),
        "",
        "0",
        "10",
      );
      var responseMessageArea = resultsArea['message'];
      var responseStatusArea = resultsArea['status'];
      var responseSuccessArea = resultsArea['success'];
      var responseBodyArea = resultsArea['body'];
      if (responseSuccessArea || responseStatusArea == 200) {
        AreaListModelResponse resultsBodyArea =
            AreaListModelResponse.fromJson(responseBodyArea);
        if (resultsBodyArea.data != null) {
          if (resultsBodyArea.data!.isNotEmpty) {
            try {
              areas = resultsBodyArea.data!;
              for (var area in areas) {
                area.spaceName = stationSpaces.first.spaceName;
              }
            } catch (e) {
              areas = [];
            }
          }
        }
      }

      final defaultArea = areas.isNotEmpty ? areas.first : null;

      emit(state.copyWith(
        spaceOptions: stationSpaces,
        selectedSpace: defaultSpace,
        areaOptions: areas,
        selectedArea: defaultArea,

        //! 3. Load Resources
        blocState: ResourceBlocState.ResourceLoadDataState,
        meta: state.meta.copyWith(current: 1),
      ));
    } catch (e) {
      DebugLogger.printLog("Lỗi: $e");
    }
  }

//! get/find all resoucre
  FutureOr<void> _onLoadData(
      ResourceLoadDataEvent event, Emitter<StationResourceState> emit) async {
    emit(state.copyWith(status: ResourceStatus.loading));
    int current;
    try {
      int current = (event.current ?? state.meta.current ?? 1) - 1;
      current = current <= 0 ? 0 : current;
      final pageSize = "10";
      String search = event.search ?? state.searchTerm;
      final areaId = event.areaId ?? state.selectedArea?.areaId.toString();
      String statusCodes = event.statusCodes ?? state.selectedStatus ?? "";

      if (state.selectedArea == null || state.areaOptions.isEmpty) {
        emit(state.copyWith(
          status: ResourceStatus.success,
          resourceList: [],
          meta: MetaModel(total: 0, current: 1),
        ));
        return;
      }

      //! Call Api Resource List - Find All
      List<StationResourceModel> resources = [];
      MetaModel metaModel =
          MetaModel(current: event.current, pageSize: 10, total: 0);

      var results = await ResouceRepository().getResouce(
          search, areaId, statusCodes, current.toString(), pageSize);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      ResoucreListModelResponse resultsBodyResource =
          ResoucreListModelResponse.fromJson(responseBody);
      if (resultsBodyResource.data != null) {
        if (resultsBodyResource.data!.isNotEmpty) {
          metaModel = resultsBodyResource.meta!;
          try {
            resources = resultsBodyResource.data!;
            for (var resouce in resources) {
              resouce.spec = ResourceSpecModel(
                // NET
                pcCpu: "Core i5-12400F",
                pcRam: "16GB DDR4",
                pcGpuModel: "RTX 3060 12GB",
                pcMonitor: "MSI 27inch 165Hz",
                pcKeyboard: "Logitech G610",
                pcMouse: "Logitech G102",
                pcHeadphone: "HyperX Cloud II",
                //PS
                csConsoleModel: "PS5 Standard",
                csTvModel: "Sony Bravia 4K 55 inch",
                csControllerType: "DualSense White",
                csControllerCount: 2,
                //BIDA
                btTableDetail: "KKKing Empire Series 2",
                btCueDetail: "Cơ CLB Carbon (4 gậy)",
                btBallDetail: "Dynaspheres Palladium",
              );
            }
          } catch (e) {
            resources = [];
          }
        }
      }
      emit(state.copyWith(
        resourceList: resources,
        meta: metaModel,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ResourceStatus.failure, message: "Lỗi tải dữ liệu"));
      DebugLogger.printLog("Lỗi tải dữ liệu: $e");
    }
  }

  FutureOr<void> _onSelectSpace(
      SelectSpaceEvent event, Emitter<StationResourceState> emit) async {
    if (event.space == state.selectedSpace) return;
    emit(state.copyWith(status: ResourceStatus.loading));
    try {
      //! Call Api Area List - Find All
      List<AreaModel> areas = [];
      var resultsArea = await AreaListRepository().getArea(
        "",
        event.space!.stationId.toString(),
        event.space!.spaceId.toString(),
        "",
        "0",
        "10",
      );
      var responseMessageArea = resultsArea['message'];
      var responseStatusArea = resultsArea['status'];
      var responseSuccessArea = resultsArea['success'];
      var responseBodyArea = resultsArea['body'];
      if (responseSuccessArea || responseStatusArea == 200) {
        AreaListModelResponse resultsBodyArea =
            AreaListModelResponse.fromJson(responseBodyArea);
        if (resultsBodyArea.data != null) {
          if (resultsBodyArea.data!.isNotEmpty) {
            try {
              areas = resultsBodyArea.data!;
              for (var area in areas) {
                area.spaceName = event.space?.spaceName;
              }
            } catch (e) {
              areas = [];
            }
          }
        }
      }
      final defaultArea = areas.isNotEmpty ? areas.first : null;

      emit(state.copyWith(
        selectedSpace: event.space,
        areaOptions: areas,
        selectedArea: defaultArea,
        searchTerm: '', // Reset filters
        forceNullStatus: true,

        //! 3. Load Resources
        blocState: ResourceBlocState.ResourceLoadDataState,
        meta: state.meta.copyWith(current: 1),
      ));

      // add(ResourceLoadDataEvent(
      //     current: 1, areaId: defaultArea?.areaId.toString()));
    } catch (e) {
      emit(state.copyWith(
          status: ResourceStatus.failure, message: "Lỗi chọn Space: $e"));
    }
  }

  FutureOr<void> _onSelectArea(
      SelectAreaEvent event, Emitter<StationResourceState> emit) async {
    if (event.area == state.selectedArea) return;

    emit(state.copyWith(
      selectedArea: event.area,
      searchTerm: '',
      forceNullStatus: true,
      //! 3. Load Resources
      blocState: ResourceBlocState.ResourceLoadDataState,
      meta: state.meta.copyWith(current: 1),
    ));

    add(ResourceLoadDataEvent(
        current: 1, areaId: event.area?.areaId.toString()));
  }

  FutureOr<void> _onSelectStatus(
      SelectStatusEvent event, Emitter<StationResourceState> emit) {
    emit(state.copyWith(
      selectedStatus: event.status,
      forceNullStatus: event.status == null,
      //! 3. Load Resources
      blocState: ResourceBlocState.ResourceLoadDataState,
      meta: state.meta.copyWith(current: 1),
    ));
  }

  FutureOr<void> _onSearch(
      SearchResourceEvent event, Emitter<StationResourceState> emit) {
    emit(state.copyWith(
      searchTerm: event.keyword,
      //! 3. Load Resources
      blocState: ResourceBlocState.ResourceLoadDataState,
      meta: state.meta.copyWith(current: 1),
    ));
  }

  FutureOr<void> _onChangePage(
      ChangePageEvent event, Emitter<StationResourceState> emit) {
    emit(state.copyWith(
      //! 3. Load Resources
      blocState: ResourceBlocState.ResourceLoadDataState,
      meta: state.meta.copyWith(current: event.newPage),
    ));
  }

//! _onCreateResources
  FutureOr<void> _onCreateResources(
      CreateResourcesEvent event, Emitter<StationResourceState> emit) async {
    // 1. Emit trạng thái Loading
    emit(state.copyWith(status: ResourceStatus.loading));

    int successCount = 0;
    int failCount = 0;
    List<String> duplicateCodes = []; // Danh sách các mã bị trùng
    List<String> otherErrors = []; // Danh sách lỗi khác

    for (var resource in event.resources) {
      try {
        // Prepare Body (Map đúng với API yêu cầu)
        // Lưu ý: TypeCode/TypeName đang fix cứng hoặc lấy từ model nếu có
        StationResourceModel body = StationResourceModel(
          areaId: resource.areaId,
          resourceCode: resource.resourceCode,
          resourceName: resource.resourceName,
          typeCode: resource.resourceCode,
          typeName: resource.resourceName,
        );

        // Call API
        var results = await ResouceRepository().createResouce(body);
        var responseMessage = results['message'];
        var responseStatus = results['status'];
        var responseSuccess = results['success'];
        var responseBody = results['body'];

        // 3. Kiểm tra kết quả từng item
        if (responseSuccess == true || responseStatus == 200) {
          successCount++;
        } else if (responseStatus == 409) {
          // Lỗi 409: Trùng mã
          failCount++;
          duplicateCodes.add(resource.resourceName.toString());
        } else {
          // Lỗi khác
          failCount++;
          otherErrors.add("${resource.resourceCode} - $responseMessage");
        }
      } catch (e) {
        failCount++;
        otherErrors.add("${resource.resourceCode} (Lỗi kết nối)");
        DebugLogger.printLog("Create Error: $e");
      }
    }

    // 4. Xử lý thông báo kết quả
    String finalMessage = "";
    ResourceStatus finalStatus = ResourceStatus.success;

    if (failCount == 0) {
      // Trường hợp 1: Thành công tất cả
      finalMessage = "Tạo thành công toàn bộ $successCount tài nguyên.";
      finalStatus = ResourceStatus.success;
    } else {
      // Trường hợp 2: Có lỗi (hoặc thất bại toàn bộ)
      finalStatus = ResourceStatus.failure; // Để hiện màu đỏ hoặc warning

      finalMessage = "Hoàn tất: $successCount thành công, $failCount thất bại.";

      if (duplicateCodes.isNotEmpty) {
        finalMessage +=
            "\nCác Tài nguyên bị trùng mã/tên:\n ${duplicateCodes.join('\n ')}";
      }

      // Nếu muốn hiện thêm lỗi khác (tùy chọn)
      if (otherErrors.isNotEmpty) {
        finalMessage += "\nLỗi khác: ${otherErrors.length} mục";
      }
    }

    // 5. Emit state kết quả
    emit(state.copyWith(
      status: finalStatus,
      message: finalMessage,
      // 6. Luôn tải lại danh sách để hiện những cái đã tạo thành công
      blocState: ResourceBlocState.ResourceLoadDataState,
      meta: state.meta.copyWith(current: 1),
    ));
  }

//! _onUpdateResource
  FutureOr<void> _onUpdateResource(
      UpdateResourceEvent event, Emitter<StationResourceState> emit) async {
    emit(state.copyWith(status: ResourceStatus.loading));

    try {
      // ResouceModel
      final newResource = StationResourceModel(
        areaId: event.resource.areaId,
        resourceCode: event.resource.resourceCode,
        resourceName: event.resource.resourceName,
        typeCode: event.resource.resourceCode,
        typeName: event.resource.resourceName,
      );

      // Call api
      var results = await ResouceRepository().updateResouce(
          event.resource.stationResourceId.toString(), newResource);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      // response
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: ResourceStatus.success,
          message: "Cập nhật khu vực ${event.resource.resourceName} thành công",
          // 2. Tải lại Data (Giữ nguyên filter và trang)
          blocState: ResourceBlocState.ResourceLoadDataState,
        ));
      } else {
        DebugLogger.printLog("$responseStatus - $responseMessage");
      }
    } catch (e) {
      emit(state.copyWith(
          status: ResourceStatus.failure, message: "Cập nhật thất bại: $e"));
    }
  }

//! _onToggleStatus
  FutureOr<void> _onToggleStatus(ToggleResourceStatusEvent event,
      Emitter<StationResourceState> emit) async {
    emit(state.copyWith(status: ResourceStatus.loading));
    try {
      // Xác định trạng thái mới (Toggle logic)
      String currentStatus = event.resource.statusCode ?? "";
      String newStatus = (currentStatus == "ENABLE") ? "disable" : "enable";

      // api
      var results = await ResouceRepository().changeStatusResouce(
          event.resource.stationResourceId.toString(), newStatus);
      var responseMessage = results['message'];
      var responseStatus = results['status'];
      var responseSuccess = results['success'];
      var responseBody = results['body'];

      // response
      if (responseSuccess || responseStatus == 200) {
        emit(state.copyWith(
          status: ResourceStatus.success,
          message: "Đổi trạng thái thành công",
          //! 3. Load Resources
          blocState: ResourceBlocState.ResourceLoadDataState,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ResourceStatus.failure, message: "Lỗi đổi trạng thái: $e"));
    }
  }
}
