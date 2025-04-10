import 'package:ombor/models/cash_flow_model.dart';

abstract class CashFlowEvent {}

class AddCashFlowEvent extends CashFlowEvent {
  final CashFlowModel cashFlow;

  AddCashFlowEvent(this.cashFlow);
}

class GetCashFlowsEvent extends CashFlowEvent {
  final String id;
  GetCashFlowsEvent({required this.id});
}

class UpdateCashFlowEvent extends CashFlowEvent {
  final CashFlowModel cashFlow;

  UpdateCashFlowEvent(this.cashFlow);
}

class DeleteCashFlowEvent extends CashFlowEvent {
  final List<String> ids;
  final String? categoryId;

  DeleteCashFlowEvent({required this.ids, this.categoryId});
}
