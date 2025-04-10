import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_state.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';

class CashFlowBloc extends Bloc<CashFlowEvent, CashFlowState> {
  final CashFlowDBHelper cashFlowHelper;

  CashFlowBloc()
    : cashFlowHelper = CashFlowDBHelper(),
      super(CashFlowInitialState()) {
    //! Add Cash Flow
    on<AddCashFlowEvent>((event, emit) async {
      emit(CashFlowLoadingState());
      try {
        await cashFlowHelper.insertCashFlow(
          event.cashFlow.categoryId,
          event.cashFlow,
        );
        emit(CashFlowAddedState(event.cashFlow));
      } catch (e) {
        emit(CashFlowErrorState("Failed to add cash flow"));
      }
    });

    //! Get Cash Flows
    on<GetCashFlowsEvent>((event, emit) async {
      emit(CashFlowLoadingState());
      try {
        final cashFlows = await cashFlowHelper.getCashFlows(event.id);
        emit(CashFlowLoadedState(cashFlows));
      } catch (e) {
        emit(CashFlowErrorState("Failed to fetch cash flows"));
      }
    });

    //! Update Cash Flow
    on<UpdateCashFlowEvent>((event, emit) async {
      emit(CashFlowLoadingState());
      try {
        await cashFlowHelper.updateCashFlow(
          event.cashFlow.categoryId,
          event.cashFlow,
        );

        emit(CashFlowUpdatedState(event.cashFlow));
      } catch (e) {
        emit(CashFlowErrorState("Failed to update cash flow"));
      }
    });

    //! Delete Cash Flow
    on<DeleteCashFlowEvent>((event, emit) async {
      emit(CashFlowLoadingState());
      try {
        await cashFlowHelper.deleteTables(event.ids);
        emit(CashFlowDeletedState(event.ids));
      } catch (e) {
        emit(CashFlowErrorState("Failed to delete cash flow"));
      }
    });
  }
}
