import 'package:ombor/models/cash_flow_model.dart';

abstract class ExpenseCashFlowState {}

class ExpenseCashFlowInitial extends ExpenseCashFlowState {}

class ExpenseCashFlowLoadingState extends ExpenseCashFlowState {}

class ExpenseCashFlowLoadedState extends ExpenseCashFlowState {
  final List<CashFlowModel> expenseCashFlows;

  ExpenseCashFlowLoadedState(this.expenseCashFlows);
}

class ExpenseCashFlowErrorState extends ExpenseCashFlowState {
  final String message;

  ExpenseCashFlowErrorState(this.message);
}
