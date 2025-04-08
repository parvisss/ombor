import 'package:ombor/models/cash_flow_model.dart';

abstract class CashFlowState {}

class CashFlowInitialState extends CashFlowState {}

class CashFlowLoadingState extends CashFlowState {}

class CashFlowLoadedState extends CashFlowState {
  final List<CashFlowModel> cashFlows;

  CashFlowLoadedState(this.cashFlows);
}

class CashFlowErrorState extends CashFlowState {
  final String errorMessage;

  CashFlowErrorState(this.errorMessage);
}

class CashFlowAddedState extends CashFlowState {
  final CashFlowModel cashFlow;

  CashFlowAddedState(this.cashFlow);
}

class CashFlowUpdatedState extends CashFlowState {
  final CashFlowModel cashFlow;

  CashFlowUpdatedState(this.cashFlow);
}

class CashFlowDeletedState extends CashFlowState {
  final String id;

  CashFlowDeletedState(this.id);
}
