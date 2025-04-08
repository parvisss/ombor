import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_event.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_state.dart';
import 'package:ombor/models/helpers/category_helper.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final CategoryHelper categoryHelper = CategoryHelper();

  BalanceBloc() : super(BalanceInitialState()) {
    //! get total balance
    on<GetTotalBalanceEvent>((event, emit) async {
      emit(BalanceLoadingState());
      try {
        final totalBalance = await categoryHelper.getTotalBalance();
        emit(BalanceLoadedState(totalBalance));
      } catch (e) {
        emit(BalanceErrorState("Failed to calculate total balance"));
      }
    });
  }
}
