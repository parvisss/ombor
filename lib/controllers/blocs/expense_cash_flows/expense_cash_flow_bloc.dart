import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class ExpenseCashFlowBloc
    extends Bloc<ExpenseCashFlowEvent, ExpenseCashFlowState> {
  final ResultHelper _resultHelper = ResultHelper();

  ExpenseCashFlowBloc() : super(ExpenseCashFlowInitial()) {
    on<GetExpenseCashFlowsEvent>((
      GetExpenseCashFlowsEvent event,
      Emitter<ExpenseCashFlowState> emit,
    ) async {
      emit(ExpenseCashFlowLoadingState());
      try {
        List<CashFlowModel> data = await _resultHelper.getExpenseCashFlows();
        emit(ExpenseCashFlowLoadedState(data));
      } catch (e) {
        emit(ExpenseCashFlowErrorState(e.toString()));
      }
    });
  }
}
