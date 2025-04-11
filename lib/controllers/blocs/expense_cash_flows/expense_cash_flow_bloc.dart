import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class ExpenseCashFlowBloc
    extends Bloc<ExpenseCashFlowEvent, ExpenseCashFlowState> {
  final ResultHelper _resultHelper = ResultHelper();
  final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();

  ExpenseCashFlowBloc() : super(ExpenseCashFlowInitial()) {
    on<GetExpenseCashFlowsEvent>((
      GetExpenseCashFlowsEvent event,
      Emitter<ExpenseCashFlowState> emit,
    ) async {
      emit(ExpenseCashFlowLoadingState());
      try {
        final List<CashFlowModel> result =
            await cashFlowDBHelper.getAllCashFlowsFromAllTables();
        if (result.isNotEmpty) {
          List<CashFlowModel> data = await _resultHelper.getExpenseCashFlows(
            allCashFlows: result,
            fromDate: AppGlobals.expenseIncomeStartDate.value,
            toDate: AppGlobals.expenseIncomeEndDate.value,
          );
          emit(ExpenseCashFlowLoadedState(data));
        } else {
          emit(ExpenseCashFlowLoadedState([]));
        }
      } catch (e) {
        emit(ExpenseCashFlowErrorState(e.toString()));
      }
    });
  }
}
