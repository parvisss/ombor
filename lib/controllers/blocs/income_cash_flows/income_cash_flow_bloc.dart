import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class IncomeCashFlowBloc
    extends Bloc<IncomeCashFlowEvent, IncomeCashFlowState> {
  final ResultHelper _resultHelper = ResultHelper();

  IncomeCashFlowBloc() : super(IncomeCashFlowInitial()) {
    on<GetIncomeCashFlowsEvent>((
      GetIncomeCashFlowsEvent event,
      Emitter<IncomeCashFlowState> emit,
    ) async {
      emit(IncomeCashFlowLoadingState());
      try {
        List<CashFlowModel> data = await _resultHelper.getIncomeCashFlows();
        emit(IncomeCashFlowLoadedState(data));
      } catch (e) {
        emit(IncomeCashFlowErrorState(e.toString()));
      }
    });
  }
}
