import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_state.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_event.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_bloc.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_event.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_state.dart';
import 'package:ombor/views/screens/reports/widgets/pie_cahrt_overall.dart';
import 'package:ombor/views/screens/reports/widgets/pie_chart_widget.dart';
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
    context.read<ResultBloc>().add(GetResultEvent());
  }

  @override
  void initState() {
    _reset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Отчеты")),
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
                  if (state is IncomeCashFlowLoadedState) {
                    return PieChartWidget(
                      title: "Kirimlar Tahlili",
                      cashFlows: state.incomeCashFlows,
                    );
                  }
                  if (state is IncomeCashFlowErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text("data"));
                },
              ),
              SizedBox(height: 70),
              BlocBuilder<ExpenseCashFlowBloc, ExpenseCashFlowState>(
                builder: (context, state) {
                  if (state is ExpenseCashFlowLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is ExpenseCashFlowLoadedState) {
                    return PieChartWidget(
                      title: "Chiqimlar Tahlili",
                      cashFlows: state.expenseCashFlows,
                    );
                  }
                  if (state is ExpenseCashFlowErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text("data"));
                },
              ),
              SizedBox(height: 70),
              BlocBuilder<ResultBloc, ResultState>(
                builder: (context, state) {
                  if (state is ResultLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is ResultLoadedState) {
                    return PieCahrtOverall(
                      title: "Umumiy Tahlil",
                      cashFlows: state.results,
                    );
                  }
                  if (state is ResultErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text("data"));
                },
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
