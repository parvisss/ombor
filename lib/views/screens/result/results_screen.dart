import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_bloc.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_event.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/search/calculator_screen.dart';
import 'package:ombor/views/screens/search/filter_data_bottom_sheet.dart';
import 'package:ombor/views/widgets/cash_flow_card.dart';
import 'package:ombor/views/widgets/custom_restart_button.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  _reset() {
    context.read<ResultBloc>().add(GetResultEvent());
  }

  @override
  void initState() {
    _reset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<ResultBloc>().add(GetResultEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text('Итоги', style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(onPressed: () {}, icon: AppIcons.print),

          //**calculator
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => CalculatorScreen()));
            },
            icon: AppIcons.calculate,
          ),

          //**filter
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (ctx) => FilterDateBottomSheet(
                        startDate: AppGlobals.resultStartDate,
                        endDate: AppGlobals.resultEndDate,
                        onStartDateSelected: (pickedDate) {
                          if (pickedDate != null) {
                            AppGlobals.resultStartDate.value = pickedDate;
                          }
                        },
                        onEndDateSelected: (pickedDate) {
                          if (pickedDate != null) {
                            AppGlobals.resultEndDate.value = pickedDate;
                          }
                        },
                        onFilter: () {
                          context.read<ResultBloc>().add(GetResultEvent());
                          context.pop();
                        },
                      ),
                ),
              );
            },
            icon: AppIcons.filter,
          ),
        ],
      ),
      body: BlocBuilder<ResultBloc, ResultState>(
        builder: (context, state) {
          if (state is ResultLoadedState) {
            if (state.results.isEmpty) {
              return Center(
                child: CustomRestartButton(
                  onTap: () {
                    context.read<ResultBloc>().add(GetResultEvent());
                  },
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                _reset();
              },
              child: ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  CashFlowModel result = state.results[index];

                  return CashFlowCard(cashFlow: result);
                },
              ),
            );
          }
          if (state is ResultLoadingState) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is ResultErrorState) {
            return Center(child: Text(state.message));
          }
          return Center(
            child: CustomRestartButton(
              onTap: () {
                context.read<ResultBloc>().add(GetResultEvent());
              },
            ),
          );
        },
      ),
    );
  }
}
