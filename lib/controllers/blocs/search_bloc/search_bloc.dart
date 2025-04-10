import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_event.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/models/helpers/cash_flof_db_helper.dart';
import 'package:ombor/models/helpers/category_helper.dart';
import 'package:ombor/models/search_result.dart'; // Yangi modelni import qilish

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final CashFlowDBHelper cashFlowDBHelper = CashFlowDBHelper();
  final CategoryHelper categoryHelper = CategoryHelper();

  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>((event, emit) async {
      emit(SearchLoading()); // Qidiruvni boshlash holatini ko'rsatish

      try {
        final List<CashFlowModel> result1 = await cashFlowDBHelper
            .searchAllTables(event.query);
        final List<CategoryModel> result2 = await categoryHelper
            .searchCategories(event.query);

        // Ikkala natijani birlashtirish
        List<SearchResult> combinedResults = [];

        for (var cashFlow in result1) {
          combinedResults.add(
            SearchResult(type: SearchResultType.cashFlow, data: cashFlow),
          );
        }
        for (var category in result2) {
          combinedResults.add(
            SearchResult(type: SearchResultType.category, data: category),
          );
        }

        emit(
          SearchLoaded(combinedResults),
        ); // Birlashtirilgan natijani yuborish
      } catch (e) {
        emit(
          SearchError("Qidiruvda xatolik yuz berdi."),
        ); // Xato bo'lsa, xabarni ko'rsatish
      }
    });
  }
}
