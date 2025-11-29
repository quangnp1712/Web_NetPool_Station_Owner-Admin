// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'space_bloc.dart';

sealed class SpaceEvent {
  const SpaceEvent();
}

class InitSpaceManageEvent extends SpaceEvent {
  final int stationId;
  InitSpaceManageEvent(this.stationId);
}

class ToggleHeaderEvent extends SpaceEvent {}

class LoadMasterListEvent extends SpaceEvent {}

class CreateStationSpaceEvent extends SpaceEvent {
  final StationSpaceModel newSpace;
  CreateStationSpaceEvent(this.newSpace);
}

class UpdateStationSpaceEvent extends SpaceEvent {
  final StationSpaceModel updatedSpace;
  UpdateStationSpaceEvent(
    this.updatedSpace,
  );
}

class DeleteStationSpaceEvent extends SpaceEvent {
  final int stationSpaceId;
  DeleteStationSpaceEvent(
    this.stationSpaceId,
  );
}

class ChangeStatusEvent extends SpaceEvent {
  final int stationSpaceId;
  final int spaceId;
  final int stationId;
  final String status;
  ChangeStatusEvent(
    this.stationSpaceId,
    this.spaceId,
    this.stationId,
    this.status,
  );
}
