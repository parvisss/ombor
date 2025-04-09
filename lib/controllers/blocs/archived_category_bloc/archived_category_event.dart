import 'package:ombor/controllers/app_globals.dart';

abstract class ArchivedCategoryEvent {}

class LoadArchivedCategories extends ArchivedCategoryEvent {
  final DateTime? fromDate = AppGlobals.archiveStartDate.value;
  final DateTime? toDate = AppGlobals.archiveEndDate.value;
}

// class DeleteArchivedCategory extends ArchivedCategoryEvent {
//   final String id;

//   DeleteArchivedCategory(this.id);
// }

class RestoreArchivedCategory extends ArchivedCategoryEvent {
  final List<String> ids;

  RestoreArchivedCategory(this.ids);
}
