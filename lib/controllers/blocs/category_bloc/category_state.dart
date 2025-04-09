import 'package:ombor/models/category_model.dart';

abstract class CategoryState {}

class CategoryInitialState extends CategoryState {}

class CategoryLoadingState extends CategoryState {}

class CategoryLoadedState extends CategoryState {
  final List<CategoryModel> categories;

  CategoryLoadedState(this.categories);
}

class CategoryErrorState extends CategoryState {
  final String errorMessage;

  CategoryErrorState(this.errorMessage);
}

class CategoryAddedState extends CategoryState {
  final CategoryModel category;

  CategoryAddedState(this.category);
}

class CategoryUpdatedState extends CategoryState {
  final CategoryModel category;

  CategoryUpdatedState(this.category);
}

class CategoryDeletedState extends CategoryState {
  final List<String> id;

  CategoryDeletedState(this.id);
}

class CategoryBalanceUpdatedState extends CategoryState {
  final CategoryModel category;

  CategoryBalanceUpdatedState(this.category);
}

class CategoriesArchivedState extends CategoryState {
  final List<String> ids;
  final int isArchived;

  CategoriesArchivedState(this.ids, this.isArchived);
}
