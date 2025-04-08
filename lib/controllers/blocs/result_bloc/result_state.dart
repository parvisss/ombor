import 'package:ombor/models/cash_flow_model.dart';

abstract class ResultState {}

class ResultInitialState extends ResultState {}

class ResultLoadingState extends ResultState {}

class ResultLoadedState extends ResultState {
  final List<CashFlowModel> results;

  ResultLoadedState(this.results);
}

class ResultAddedState extends ResultState {
  final CashFlowModel result;

  ResultAddedState(this.result);
}

class ResultUpdatedState extends ResultState {
  final CashFlowModel result;

  ResultUpdatedState(this.result);
}

class ResultDeletedState extends ResultState {
  final String id;

  ResultDeletedState(this.id);
}

class ResultErrorState extends ResultState {
  final String message;

  ResultErrorState(this.message);
}
