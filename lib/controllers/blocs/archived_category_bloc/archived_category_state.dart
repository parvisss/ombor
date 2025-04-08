import 'package:ombor/models/category_model.dart';

abstract class ArchivedCategoryState {}

class ArchivedCategoryInitial extends ArchivedCategoryState {}

class ArchivedCategoryLoading extends ArchivedCategoryState {}

class ArchivedCategoryLoaded extends ArchivedCategoryState {
  final List<CategoryModel> categories;

  ArchivedCategoryLoaded(this.categories);
}

class ArchivedCategoryError extends ArchivedCategoryState {
  final String message;

  ArchivedCategoryError(this.message);
}

class ArchivedCategoryDeleted extends ArchivedCategoryState {
  final String id;

  ArchivedCategoryDeleted(this.id);
}

class ArchivedCategoryRestored extends ArchivedCategoryState {
  final List<String> ids;

  ArchivedCategoryRestored(this.ids);
}
