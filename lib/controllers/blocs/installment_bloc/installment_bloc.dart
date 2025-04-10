import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/blocs/installment_bloc/installment_event.dart';
import 'package:ombor/controllers/blocs/installment_bloc/installment_state.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';

class InstallmentBloc extends Bloc<InstallmentEvent, InstallmentState> {
  InstallmentBloc() : super(InstallmentInitialState()) {
    final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();

    //! Get Installments
    on<GetInstallmentsEvent>((event, emit) async {
      emit(InstallmentLoadingState());
      await Future.delayed(Duration(milliseconds: 300));
      try {
        final installments = await cashFlowDBHelper.getTotalInstallmentAmount();
        emit(InstallmentLoadedState(installmentBalance: installments));
      } catch (e) {
        emit(InstallmentErrorState("Failed to load installments"));
      }
    });
  }
}
