import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/models/category_model.dart';

abstract class CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final CategoryModel category;

  AddCategoryEvent(this.category);
}

class GetCategoriesEvent extends CategoryEvent {
  final bool isArchive;
  final DateTime? fromDate = AppGlobals.startDate.value;
  final DateTime? toDate = AppGlobals.endDate.value;

  GetCategoriesEvent({required this.isArchive});
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryModel category;

  UpdateCategoryEvent(this.category);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  DeleteCategoryEvent(this.id);
}

class ChangeBalanceEvent extends CategoryEvent {
  final String id;
  final double amount;
  final bool isIncrement;
  final bool isArchive;

  ChangeBalanceEvent({
    required this.id,
    required this.amount,
    required this.isIncrement,
    required this.isArchive,
  });
}

class ArchiveMultipleCategoriesEvent extends CategoryEvent {
  final List<String> ids;
  final int isArchived;

  ArchiveMultipleCategoriesEvent(this.ids, this.isArchived);
}

// class GetCategoriesByDateEvent extends CategoryEvent {
//   final DateTime? fromDate;
//   final DateTime? toDate;

//   GetCategoriesByDateEvent({this.fromDate, this.toDate});
// }
