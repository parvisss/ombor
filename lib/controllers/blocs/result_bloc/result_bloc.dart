import 'package:bloc/bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_event.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_state.dart';
import 'package:ombor/models/helpers/result_helper.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final ResultHelper resultHelper;

  ResultBloc() : resultHelper = ResultHelper(), super(ResultInitialState()) {
    //! Add Result
    on<AddResultEvent>((event, emit) async {
      emit(ResultLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        await resultHelper.insertCashFlow(event.result);
        final results = await resultHelper.getCashFlows();
        emit(ResultLoadedState(results));
      } catch (e) {
        emit(ResultErrorState("Failed to add result"));
      }
    });

    //! Get Results
    on<GetResultEvent>((event, emit) async {
      emit(ResultLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        final results = await resultHelper.getCashFlows(
          fromDate: AppGlobals.resultStartDate.value,
          toDate: AppGlobals.resultEndDate.value,
        ); // sizga mos parametr
        emit(ResultLoadedState(results));
      } catch (e) {
        emit(ResultErrorState("Failed to fetch results"));
      }
    });

    //! Update Result
    on<UpdateResultEvent>((event, emit) async {
      emit(ResultLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        await resultHelper.updateCashFlow(event.result);
        emit(ResultUpdatedState(event.result));
      } catch (e) {
        emit(ResultErrorState("Failed to update result"));
      }
    });

    //! Delete Result
    on<DeleteResultEvent>((event, emit) async {
      emit(ResultLoadingState());
      await Future.delayed(Duration(milliseconds: 300));

      try {
        await resultHelper.deleteCashFlow(event.id);
        emit(ResultDeletedState(event.id));
      } catch (e) {
        emit(ResultErrorState("Failed to delete result"));
      }
    });
  }
}
