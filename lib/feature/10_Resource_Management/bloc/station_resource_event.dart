part of 'station_resource_bloc.dart';

sealed class StationResourceEvent extends Equatable {
  const StationResourceEvent();
  @override
  List<Object?> get props => [];
}

class InitResourcePageEvent extends StationResourceEvent {}

class SelectSpaceEvent extends StationResourceEvent {
  final StationSpaceModel? space;
  const SelectSpaceEvent(this.space);
}

class SelectAreaEvent extends StationResourceEvent {
  final AreaModel? area;
  const SelectAreaEvent(this.area);
}

class SelectStatusEvent extends StationResourceEvent {
  final String? status;
  const SelectStatusEvent(this.status);
}

class SearchResourceEvent extends StationResourceEvent {
  final String keyword;
  const SearchResourceEvent(this.keyword);
}

class ChangePageEvent extends StationResourceEvent {
  final int newPage;
  const ChangePageEvent(this.newPage);
}

class ResourceLoadDataEvent extends StationResourceEvent {
  final String? search;
  final int? current;
  final String? areaId;
  final String? statusCodes;
  const ResourceLoadDataEvent(
      {this.search, this.current, this.areaId, this.statusCodes});
}

class CreateResourcesEvent extends StationResourceEvent {
  final List<StationResourceModel> resources;
  const CreateResourcesEvent(this.resources);
}

class UpdateResourceEvent extends StationResourceEvent {
  final StationResourceModel resource;
  const UpdateResourceEvent(this.resource);
}

class ToggleResourceStatusEvent extends StationResourceEvent {
  final StationResourceModel resource;
  const ToggleResourceStatusEvent(this.resource);
}
