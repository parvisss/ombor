import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_state.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/widgets/balance_text_widget.dart';

class OveralBalanceWidget extends StatelessWidget {
  const OveralBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Общая сумма'),
      subtitle: BlocBuilder<BalanceBloc, BalanceState>(
        builder: (context, state) {
          if (state is BalanceLoadedState) {
            return BalanceTextWidget(balance: state.totalBalance);
          }
          return Text(" 0 Uzs", style: AppTextStyles.bodyLarge);
        },
      ),
    );
  }
}
