import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_event.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_bloc.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_event.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_bloc.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_event.dart';
import 'package:ombor/extensions/data_time_extension.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/views/widgets/custom_button.dart';

class AddScreen extends StatefulWidget {
  final bool isCategory;
  final String? categoryId;
  final String? title;

  const AddScreen({
    super.key,
    required this.isCategory,
    this.categoryId,
    this.title,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  bool isDebt = true;

  //! Validation flags
  bool isNameValid = true;
  bool isAmountValid = true;

  //! on tap
  void _addCategory(BuildContext context) {
    final name = nameController.text.trim();
    final amountText = amountController.text.trim();

    // Reset validation flags
    setState(() {
      isNameValid = name.isNotEmpty;
      isAmountValid = amountText.isNotEmpty;
    });

    // If adding category
    if (widget.isCategory && name.isNotEmpty) {
      final model = CategoryModel(
        id: "id${DateTime.now().millisecondsSinceEpoch.toString()}",
        title: name,
        balance: 0, // balance will be set to 0
        time: DateTime.now().formatTime().toString(),
        isArchived: 0,
      );
      context.read<CategoryBloc>().add(AddCategoryEvent(model));
      context.read<CategoryBloc>().add(GetCategoriesEvent(isArchive: false));

      Navigator.pop(context);
    }
    // If adding cash flow
    else if (!widget.isCategory && name.isNotEmpty && amountText.isNotEmpty) {
      final cashFlow = CashFlowModel(
        time: DateTime.now().formatTime().toString(),
        id: "id${DateTime.now().millisecondsSinceEpoch.toString()}",
        categoryId: widget.categoryId!,
        title: name,
        isPositive: !isDebt ? 1 : 0,
        amount:
            isDebt ? double.parse(amountText) * -1 : double.parse(amountText),
        comment: commentController.text,
      );
      context.read<CategoryBloc>().add(
        ChangeBalanceEvent(
          id: widget.categoryId!,
          amount: double.parse(amountText),
          isIncrement: !isDebt,
          isArchive: false,
        ),
      );
      context.read<CashFlowBloc>().add(AddCashFlowEvent(cashFlow));
      context.read<BalanceBloc>().add(GetTotalBalanceEvent());
      context.read<CashFlowBloc>().add(
        GetCashFlowsEvent(id: cashFlow.categoryId),
      );
      context.read<ResultBloc>().add(AddResultEvent(cashFlow));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Категория')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Name input
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'имя*',
                  border: const OutlineInputBorder(),
                  errorText: isNameValid ? null : 'This field is required',
                ),
              ),
              const SizedBox(height: 16),

              // If it's not a category, show Debt/Loan options
              if (!widget.isCategory) ...[
                // Toggle: Debt / Loan
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.comment),
                    labelText: 'Комментарий',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Row(
                        children: const [
                          Icon(Icons.remove_circle, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Долг", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      selected: isDebt,
                      selectedColor: Colors.red,
                      onSelected: (_) => setState(() => isDebt = true),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: Row(
                        children: const [
                          Icon(Icons.add_circle, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Займ", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      selected: !isDebt,
                      selectedColor: Colors.green,
                      onSelected: (_) => setState(() => isDebt = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Amount input (only show if not a category)
              if (!widget.isCategory) ...[
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money),
                    labelText: 'сумма* Uzs',
                    border: const OutlineInputBorder(),
                    errorText: isAmountValid ? null : 'This field is required',
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Comment input (optional)
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: CustomButton(
          onTap: () => _addCategory(context),
          color: AppColors.mainColor,
          child: const Text('Добавить'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
