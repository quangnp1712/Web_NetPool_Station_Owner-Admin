import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'account_create_event.dart';
part 'account_create_state.dart';

class AccountCreateBloc extends Bloc<AccountCreateEvent, AccountCreateState> {
  AccountCreateBloc() : super(AccountCreateInitial()) {
    on<AccountCreateEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
