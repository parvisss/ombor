import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_state.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';
import 'package:ombor/models/helpers/category_helper.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryHelper categoryHelper = CategoryHelper();
  final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();
  CategoryBloc() : super(CategoryInitialState()) {
    //!add
    on<AddCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await categoryHelper.insertCategory(event.category);
        emit(CategoryAddedState(event.category));
      } catch (e) {
        emit(CategoryErrorState(e.toString()));
      }
    });

    //!get
    on<GetCategoriesEvent>((event, emit) async {
      emit(CategoryLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        final categories = await categoryHelper.fetchCategories(
          isArchive: event.isArchive,
          fromDate: AppGlobals.startDate.value,
          toDate: AppGlobals.endDate.value,
        );
        emit(CategoryLoadedState(categories));
      } catch (e) {
        emit(CategoryErrorState(e.toString()));
      }
    });

    //!update
    on<UpdateCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await categoryHelper.updateCategory(event.category);
        emit(CategoryUpdatedState(event.category));
        final categories = await categoryHelper.fetchCategories(
          isArchive: false,
          fromDate: AppGlobals.startDate.value,
          toDate: AppGlobals.endDate.value,
        );
        emit(CategoryLoadedState(categories));
      } catch (e) {
        emit(CategoryErrorState("Failed to update category"));
      }
    });

    //!delete
    on<DeleteCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await categoryHelper.deleteCategory(event.id);
        emit(CategoryDeletedState(event.id));
        final categories = await categoryHelper.fetchCategories(
          isArchive: false,
          fromDate: AppGlobals.startDate.value,
          toDate: AppGlobals.endDate.value,
        );
        emit(CategoryLoadedState(categories));
      } catch (e) {
        emit(CategoryErrorState("Failed to delete category"));
      }
    });

    //!change balance
    on<ChangeBalanceEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final double amount = await cashFlowDBHelper.getCategoryCashFlowAmount(
          categoryId: event.id,
        );
        await categoryHelper.changeBalance(event.id, amount, event.isIncrement);
        final categories = await categoryHelper.fetchCategories(
          isArchive: event.isArchive,
        );
        emit(CategoryLoadedState(categories));
      } catch (e) {
        emit(CategoryErrorState("Failed to change balance"));
      }
    });

    //!archive
    on<ArchiveMultipleCategoriesEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await categoryHelper.archiveMultipleCategories(
          event.ids,
          event.isArchived,
        );

        final cashFlowDBHelper = CashFlowDBHelper();
        for (final categoryId in event.ids) {
          await cashFlowDBHelper.archiveCashFlow(
            categoryId,
            categoryId, // Diqqat: Cash flow IDsi hozircha bo'sh. Butun jadval arxivlanadi/arxivdan chiqariladi.
            1, // 1 -> archive, 0 -> unarchive
          );
        }

        final categories = await categoryHelper.fetchCategories(
          isArchive: event.isArchived == 0,
          fromDate: AppGlobals.startDate.value,
          toDate: AppGlobals.endDate.value,
        );
        emit(CategoryLoadedState(categories));
      } catch (e) {
        emit(
          CategoryErrorState(
            "Failed to archive categories and related cash flows",
          ),
        );
      }
    });
  }
}
