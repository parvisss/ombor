import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_event.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final ResultHelper resultHelper;

  ResultBloc() : resultHelper = ResultHelper(), super(ResultInitialState()) {
    final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();

    //! Get Results
    on<GetResultEvent>((event, emit) async {
      emit(ResultLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        final List<CashFlowModel> result =
            await cashFlowDBHelper.getAllCashFlowsFromAllTables();
        if (result.isNotEmpty) {
          final results = await resultHelper.getCombinedCashFlows(
            allCashFlows: result,
            fromDate: AppGlobals.resultStartDate.value,
            toDate: AppGlobals.resultEndDate.value,
            isExpenceIncluded: AppGlobals.resultIsIncludeExpence.value,
            isIncomeIncluded: AppGlobals.resultIsIncludeIncome.value,
            isInstallmentIncluded: AppGlobals.resultIsIncludeInstallment.value,
          ); // sizga mos parametr
          emit(ResultLoadedState(results));
        } else {
          emit(ResultLoadedState([]));
        }
      } catch (e) {
        emit(ResultErrorState(e.toString()));
      }
    });
  }
}
