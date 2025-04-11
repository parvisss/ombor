import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class IncomeCashFlowBloc
    extends Bloc<IncomeCashFlowEvent, IncomeCashFlowState> {
  final ResultHelper _resultHelper = ResultHelper();
  final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();

  IncomeCashFlowBloc() : super(IncomeCashFlowInitial()) {
    on<GetIncomeCashFlowsEvent>((
      GetIncomeCashFlowsEvent event,
      Emitter<IncomeCashFlowState> emit,
    ) async {
      emit(IncomeCashFlowLoadingState());
      try {
        final List<CashFlowModel> result =
            await cashFlowDBHelper.getAllCashFlowsFromAllTables();
        if (result.isNotEmpty) {
          List<CashFlowModel> data = await _resultHelper.getIncomeCashFlows(
            allCashFlows: result,
            fromDate: AppGlobals.expenseIncomeStartDate.value,
            toDate: AppGlobals.expenseIncomeEndDate.value,
          );
          emit(IncomeCashFlowLoadedState(data));
        } else {
          emit(IncomeCashFlowLoadedState([]));
        }
      } catch (e) {
        emit(IncomeCashFlowErrorState(e.toString()));
      }
    });
  }
}
