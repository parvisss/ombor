import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/installment_bloc/installment_bloc.dart';
import 'package:ombor/controllers/blocs/installment_bloc/installment_state.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/widgets/balance_text_widget.dart';

class InstallmentBalanceWidget extends StatelessWidget {
  const InstallmentBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Долги'),
      subtitle: BlocBuilder<InstallmentBloc, InstallmentState>(
        builder: (context, state) {
          if (state is InstallmentLoadedState) {
            return BalanceTextWidget(balance: state.installmentBalance);
          }
          return Text(" 0 Uzs", style: AppTextStyles.bodyLarge);
        },
      ),
    );
  }
}
