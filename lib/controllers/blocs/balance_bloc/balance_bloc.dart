import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_event.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_state.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  BalanceBloc() : super(BalanceInitialState()) {
    final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();

    //! Get Installments
    on<GetTotalBalanceEvent>((event, emit) async {
      emit(BalanceLoadingState());
      await Future.delayed(Duration(milliseconds: 300));
      try {
        final balance = await cashFlowDBHelper.getTotalCashFlowAmount();
        emit(BalanceLoadedState(balance));
      } catch (e) {
        emit(BalanceErrorState(e.toString()));
      }
    });
  }
}
