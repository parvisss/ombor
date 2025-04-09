import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_event.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_state.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class IncomeExpenseBloc extends Bloc<IncomeExpenseEvent, IncomeExpenseState> {
  final ResultHelper resultHelper;

  IncomeExpenseBloc()
    : resultHelper = ResultHelper(),
      super(IncomeExpenseStateInitialState()) {
    //! Get Results
    on<GetIncomeExpenseEventEvent>((event, emit) async {
      emit(IncomeExpenseStatetLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        final results = await resultHelper.getCashFlows(
          fromDate: AppGlobals.expenseIncomeStartDate.value,
          toDate: AppGlobals.expenseIncomeEndDate.value,
        ); // sizga mos parametr
        emit(IncomeExpenseStateLoadedState(results));
      } catch (e) {
        emit(IncomeExpenseStateErrorState(e.toString()));
      }
    });
  }
}
