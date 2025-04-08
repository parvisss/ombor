import 'package:ombor/models/cash_flow_model.dart';

abstract class ResultEvent {}

class AddResultEvent extends ResultEvent {
  final CashFlowModel result;

  AddResultEvent(this.result);
}

class GetResultEvent extends ResultEvent {}

class UpdateResultEvent extends ResultEvent {
  final CashFlowModel result;

  UpdateResultEvent(this.result);
}

class DeleteResultEvent extends ResultEvent {
  final String id;

  DeleteResultEvent(this.id);
}
