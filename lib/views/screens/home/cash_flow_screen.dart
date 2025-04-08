import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_state.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/add_screen.dart';
import 'package:ombor/views/widgets/balance_text_widget.dart';
import 'package:ombor/views/widgets/cash_flow_card.dart';
import 'package:ombor/views/widgets/custom_floating_button.dart';

import '../../../utils/app_icons.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({
    super.key,
    required this.title,
    required this.balance,
    required this.categoryId,
  });
  final String title;
  final num balance;
  final String categoryId;

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  @override
  void initState() {
    super.initState();
    // Load the cash flow data when the screen is first built
    context.read<CashFlowBloc>().add(GetCashFlowsEvent(id: widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: AppTextStyles.headlineLarge),
        actions: [
          AppIcons.print,
          AppIcons.calculate,
          AppIcons.filter,
          AppIcons.search,
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Общая сумма'),
            subtitle: BalanceTextWidget(balance: widget.balance),
          ),
          Container(
            color: AppColors.backgroundSecondary,
            width: double.infinity,
            height: 4,
          ),

          // BlocBuilder for CashFlow Bloc
          Expanded(
            child: BlocBuilder<CashFlowBloc, CashFlowState>(
              builder: (context, state) {
                if (state is CashFlowLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CashFlowLoadedState) {
                  final cashFlows = state.cashFlows;
                  if (cashFlows.isEmpty) {
                    return const Center(
                      child: Text("Hech qanday naqd pul yo'q"),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CashFlowBloc>().add(
                        GetCashFlowsEvent(id: widget.categoryId),
                      );
                    },
                    child: ListView.builder(
                      itemCount: cashFlows.length,
                      itemBuilder: (context, index) {
                        final cashFlow = cashFlows[index];
                        return CashFlowCard(cashFlow: cashFlow);
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text('Пусто'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (ctx) => AddScreen(
                    isCategory: false,
                    title: widget.title,
                    categoryId: widget.categoryId,
                  ),
            ),
          );
        },
      ),
    );
  }
}
