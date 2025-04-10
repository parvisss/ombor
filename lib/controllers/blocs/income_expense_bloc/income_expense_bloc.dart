import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_event.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class IncomeExpenseBloc extends Bloc<IncomeExpenseEvent, IncomeExpenseState> {
  final ResultHelper resultHelper;
  final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();

  IncomeExpenseBloc()
    : resultHelper = ResultHelper(),
      super(IncomeExpenseStateInitialState()) {
    //! Get Results
    on<GetIncomeExpenseEventEvent>((event, emit) async {
      emit(IncomeExpenseStatetLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        final List<CashFlowModel> result =
            await cashFlowDBHelper.getAllCashFlowsFromAllTables();
        if (result.isNotEmpty) {
          final results = await resultHelper.getCombinedCashFlows(
            allCashFlows: result,
            fromDate: AppGlobals.expenseIncomeStartDate.value,
            toDate: AppGlobals.expenseIncomeEndDate.value,
          ); // sizga mos parametr
          emit(IncomeExpenseStateLoadedState(results));
        } else {
          emit(IncomeExpenseStateLoadedState([]));
        }
      } catch (e) {
        emit(IncomeExpenseStateErrorState(e.toString()));
      }
    });
  }
}
