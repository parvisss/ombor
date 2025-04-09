import 'package:ombor/models/cash_flow_model.dart';

abstract class IncomeCashFlowState {}

class IncomeCashFlowInitial extends IncomeCashFlowState {}

class IncomeCashFlowLoadingState extends IncomeCashFlowState {}

class IncomeCashFlowLoadedState extends IncomeCashFlowState {
  final List<CashFlowModel> incomeCashFlows;

  IncomeCashFlowLoadedState(this.incomeCashFlows);
}

class IncomeCashFlowErrorState extends IncomeCashFlowState {
  final String message;

  IncomeCashFlowErrorState(this.message);
}
