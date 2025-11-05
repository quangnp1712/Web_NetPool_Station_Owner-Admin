part of 'admin_list_bloc.dart';

sealed class AdminListState extends Equatable {
  const AdminListState();

  @override
  List<Object> get props => [];
}

final class AdminListInitial extends AdminListState {}

abstract class AdminListActionState extends AdminListState {}

class AdminList_ChangeState extends AdminListActionState {}

class AdminList_LoadingState extends AdminListActionState {
  final bool isLoading;

  AdminList_LoadingState({required this.isLoading});
}

class AdminListSuccessState extends AdminListState {
  List<AdminListModel> AdminList;
  List<String> statusNames;
  AdminListMetaModel meta;
  AdminListSuccessState(
      {required this.AdminList, required this.statusNames, required this.meta});
}

class AdminListEmptyState extends AdminListState {}

class ShowSnackBarActionState extends AdminListActionState {
  final String message;
  final bool success;

  ShowSnackBarActionState({required this.success, required this.message});
}
