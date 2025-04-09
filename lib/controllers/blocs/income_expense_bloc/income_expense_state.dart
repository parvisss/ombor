import 'package:ombor/models/cash_flow_model.dart';

abstract class IncomeExpenseState {}

class IncomeExpenseStateInitialState extends IncomeExpenseState {}

class IncomeExpenseStatetLoadingState extends IncomeExpenseState {}

class IncomeExpenseStateLoadedState extends IncomeExpenseState {
  final List<CashFlowModel> results;

  IncomeExpenseStateLoadedState(this.results);
}

class IncomeExpenseStateErrorState extends IncomeExpenseState {
  final String message;

  IncomeExpenseStateErrorState(this.message);
}
