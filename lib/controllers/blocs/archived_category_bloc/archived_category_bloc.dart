import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_event.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_state.dart';
import 'package:ombor/models/helpers/category_helper.dart';

class ArchivedCategoryBloc
    extends Bloc<ArchivedCategoryEvent, ArchivedCategoryState> {
  final CategoryHelper categoryHelper;

  ArchivedCategoryBloc(this.categoryHelper) : super(ArchivedCategoryInitial()) {
    on<LoadArchivedCategories>((event, emit) async {
      emit(ArchivedCategoryLoading());
      await Future.delayed(Duration(milliseconds: 300));
      try {
        final archivedCategories = await categoryHelper.fetchCategories(
          isArchive: true,
          fromDate: AppGlobals.archiveStartDate.value,
          toDate: AppGlobals.archiveEndDate.value,
        );
        emit(ArchivedCategoryLoaded(archivedCategories));
      } catch (e) {
        emit(ArchivedCategoryError("Failed to load archived categories"));
      }
    });

    on<DeleteArchivedCategory>((event, emit) async {
      emit(ArchivedCategoryLoading());
      await Future.delayed(Duration(milliseconds: 300));
      try {
        await categoryHelper.deleteCategory(event.id);
        emit(ArchivedCategoryDeleted(event.id));

        final updatedList = await categoryHelper.fetchCategories(
          isArchive: true,
        );
        emit(ArchivedCategoryLoaded(updatedList));
      } catch (e) {
        emit(ArchivedCategoryError("Failed to delete archived category"));
      }
    });

    on<RestoreArchivedCategory>((event, emit) async {
      emit(ArchivedCategoryLoading());
      await Future.delayed(Duration(milliseconds: 300));
      try {
        await categoryHelper.archiveMultipleCategories(
          event.ids,
          0,
        ); // 0 -> active
        emit(ArchivedCategoryRestored(event.ids));

        final updatedList = await categoryHelper.fetchCategories(
          isArchive: true,
        );
        emit(ArchivedCategoryLoaded(updatedList));
      } catch (e) {
        emit(ArchivedCategoryError("Failed to restore category"));
      }
    });
  }
}
