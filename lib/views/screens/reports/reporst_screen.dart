import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_state.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_bloc.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_event.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_state.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/views/screens/reports/widgets/pie_cahrt_overall.dart';
import 'package:ombor/views/screens/reports/widgets/pie_chart_widget.dart';
import 'package:ombor/views/screens/search/calculator_screen.dart';
import 'package:ombor/views/screens/search/filter_data_bottom_sheet.dart';
import '../../../controllers/blocs/income_cash_flows/income_cash_flow_state.dart';

class ReporstScreen extends StatefulWidget {
  const ReporstScreen({super.key});

  @override
  State<ReporstScreen> createState() => _ReporstScreenState();
}

class _ReporstScreenState extends State<ReporstScreen> {
  _reset() async {
    context.read<IncomeCashFlowBloc>().add(GetIncomeCashFlowsEvent());
    context.read<ExpenseCashFlowBloc>().add(GetExpenseCashFlowsEvent());
    context.read<IncomeExpenseBloc>().add(GetIncomeExpenseEventEvent());
  }

  @override
  void initState() {
    _reset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчеты"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => CalculatorScreen()));
            },
            icon: AppIcons.calculate,
          ),

          //filter
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FilterDateBottomSheet(
                    startDate: AppGlobals.expenseIncomeStartDate,
                    endDate: AppGlobals.expenseIncomeEndDate,
                    onStartDateSelected: (pickedDate) {
                      if (pickedDate != null) {
                        AppGlobals.expenseIncomeStartDate.value = pickedDate;
                      }
                    },
                    onEndDateSelected: (pickedDate) {
                      if (pickedDate != null) {
                        AppGlobals.expenseIncomeEndDate.value = pickedDate;
                      }
                    },
                    onFilter: () {
                      _reset();
                      Navigator.pop(context); // BottomSheet ni yopish
                    },
                  );
                },
              );
            },
            icon: AppIcons.filter,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _reset();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<IncomeCashFlowBloc, IncomeCashFlowState>(
                builder: (context, state) {
                  if (state is IncomeCashFlowLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is IncomeCashFlowLoadedState &&
                      state.incomeCashFlows.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 70.0),
                      child: PieChartWidget(
                        title: "Kirimlar Tahlili",
                        cashFlows: state.incomeCashFlows,
                      ),
                    );
                  }
                  if (state is IncomeCashFlowErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return SizedBox();
                },
              ),
              BlocBuilder<ExpenseCashFlowBloc, ExpenseCashFlowState>(
                builder: (context, state) {
                  if (state is ExpenseCashFlowLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is ExpenseCashFlowLoadedState &&
                      state.expenseCashFlows.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 70.0),
                      child: PieChartWidget(
                        title: "Chiqimlar Tahlili",
                        cashFlows: state.expenseCashFlows,
                      ),
                    );
                  }
                  if (state is ExpenseCashFlowErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return SizedBox();
                },
              ),
              BlocBuilder<IncomeExpenseBloc, IncomeExpenseState>(
                builder: (context, state) {
                  if (state is IncomeExpenseStatetLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is IncomeExpenseStateLoadedState &&
                      state.results.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 70.0),
                      child: PieCahrtOverall(
                        title: "Umumiy Tahlil",
                        cashFlows: state.results,
                      ),
                    );
                  }
                  if (state is IncomeExpenseStateErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(child: Text("Пусто")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
