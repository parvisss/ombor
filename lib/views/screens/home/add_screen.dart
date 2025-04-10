import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_event.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_bloc.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_event.dart';
import 'package:ombor/controllers/blocs/installment_bloc/installment_bloc.dart';
import 'package:ombor/controllers/blocs/installment_bloc/installment_event.dart';
import 'package:ombor/extensions/data_time_extension.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/views/widgets/custom_button.dart';
import 'package:ombor/views/widgets/custom_text_field.dart';

class AddScreen extends StatefulWidget {
  final bool isCategory;
  final String? categoryId;
  final String? title;
  final CategoryModel? categoryToEdit;
  final CashFlowModel? cashFlowToEdit;

  const AddScreen({
    super.key,
    required this.isCategory,
    this.categoryId,
    this.title,
    this.categoryToEdit,
    this.cashFlowToEdit,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  bool isDebt = true;
  bool isInstallment = false;

  //! Validation flags
  bool isNameValid = true;
  bool isAmountValid = true;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      nameController.text = widget.categoryToEdit!.title;
    }
    if (widget.cashFlowToEdit != null) {
      nameController.text = widget.cashFlowToEdit!.title;
      amountController.text = widget.cashFlowToEdit!.amount.abs().toString();
      commentController.text = widget.cashFlowToEdit!.comment ?? '';
      isDebt =
          widget.cashFlowToEdit!.amount < 0 &&
          widget.cashFlowToEdit!.isInstallment == 0;
      isInstallment = widget.cashFlowToEdit!.isInstallment == 1;
    }
  }

  //! Add category
  void _addCategory(BuildContext context) {
    final name = nameController.text.trim();

    // Reset validation flags
    setState(() {
      isNameValid = name.isNotEmpty;
    });

    if (name.isNotEmpty) {
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
  }

  //! Update category
  void _updateCategory(BuildContext context) {
    final name = nameController.text.trim();

    setState(() {
      isNameValid = name.isNotEmpty;
    });

    if (name.isNotEmpty && widget.categoryToEdit != null) {
      final model = widget.categoryToEdit!.copyWith(
        title: name,
        time: DateTime.now().formatTime().toString(),
      );
      context.read<CategoryBloc>().add(UpdateCategoryEvent(model));
      context.read<CategoryBloc>().add(GetCategoriesEvent(isArchive: false));
      Navigator.pop(context);
    }
  }

  //! Add cash flow
  void _addCashFlow(BuildContext context) {
    final name = nameController.text.trim();
    final amountText = amountController.text.trim();

    setState(() {
      isNameValid = name.isNotEmpty;
      isAmountValid = amountText.isNotEmpty;
    });

    if (name.isNotEmpty && amountText.isNotEmpty && widget.categoryId != null) {
      int isPositive = !isDebt && !isInstallment ? 1 : 0;
      num amount = double.parse(amountText);

      if (isDebt || isInstallment) {
        amount *= -1;
      }

      final cashFlow = CashFlowModel(
        time: DateTime.now().formatTime().toString(),
        id: "id${DateTime.now().millisecondsSinceEpoch.toString()}",
        categoryId: widget.categoryId!,
        title: name,
        isPositive: isPositive,
        amount: amount,
        comment: commentController.text,
        isInstallment: isInstallment ? 1 : 0,
      );

      if (!isInstallment) {
        context.read<CategoryBloc>().add(
          ChangeBalanceEvent(
            id: widget.categoryId!,
            amount: amount.abs().toDouble(),
            isIncrement: !isDebt,
            isArchive: false,
          ),
        );
      }

      context.read<CashFlowBloc>().add(AddCashFlowEvent(cashFlow));
      // context.read<BalanceBloc>().add(GetTotalBalanceEvent());
      context.read<CashFlowBloc>().add(
        GetCashFlowsEvent(id: widget.categoryId!),
      );

      Navigator.pop(context);
    }
  }

  //! Update cash flow
  void _updateCashFlow(BuildContext context) {
    final name = nameController.text.trim();
    final amountText = amountController.text.trim();

    setState(() {
      isNameValid = name.isNotEmpty;
      isAmountValid = amountText.isNotEmpty;
    });

    if (name.isNotEmpty &&
        amountText.isNotEmpty &&
        widget.cashFlowToEdit != null) {
      int isPositive = !isDebt && !isInstallment ? 1 : 0;
      num amount = double.parse(amountText);

      if (isDebt || isInstallment) {
        amount *= -1;
      }

      final cashFlow = widget.cashFlowToEdit!.copyWith(
        time: DateTime.now().formatTime().toString(),
        title: name,
        isPositive: isPositive,
        amount: amount,
        comment: commentController.text,
        isInstallment: isInstallment ? 1 : 0,
      );

      if (!isInstallment) {
        final amountDifference = amount - widget.cashFlowToEdit!.amount;
        context.read<CategoryBloc>().add(
          ChangeBalanceEvent(
            id: cashFlow.categoryId,
            amount: amountDifference.abs().toDouble(),
            isIncrement: amountDifference >= 0,
            isArchive: false,
          ),
        );
        context.read<BalanceBloc>().add(GetTotalBalanceEvent());
      } else {
        context.read<InstallmentBloc>().add(GetInstallmentTotlaBalanceEvent());
      }
      context.read<CashFlowBloc>().add(UpdateCashFlowEvent(cashFlow));
      context.read<CashFlowBloc>().add(
        GetCashFlowsEvent(id: cashFlow.categoryId),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryToEdit != null || widget.cashFlowToEdit != null
              ? 'edit'.tr(context: context)
              : 'add'.tr(context: context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Name input
              CustomTextField(
                controller: nameController,
                hintText: 'name'.tr(context: context),
                icon: Icons.person,
                isRequired: true,
                isValid: isNameValid,
              ),
              const SizedBox(height: 16),

              // If it's not a category, show Debt/Loan/Installment options
              if (!widget.isCategory) ...[
                CustomTextField(
                  controller: commentController,
                  hintText: 'comment'.tr(context: context),
                  icon: Icons.comment,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.remove_circle,
                            color: isDebt ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "debt".tr(context: context),
                            style: TextStyle(
                              color: isDebt ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      selected: isDebt,
                      selectedColor: AppColors.negative,
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      onSelected:
                          (_) => setState(() {
                            isDebt = true;
                            isInstallment = false; // Nasiya bekor qilinadi
                          }),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color:
                                !isDebt && !isInstallment
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "loan".tr(context: context),
                            style: TextStyle(
                              color:
                                  !isDebt && !isInstallment
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      selected: !isDebt && !isInstallment,
                      selectedColor: AppColors.positive,
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      onSelected:
                          (_) => setState(() {
                            isDebt = false;
                            isInstallment = false; // Nasiya bekor qilinadi
                          }),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: isInstallment ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "nasiya".tr(context: context),
                            style: TextStyle(
                              color:
                                  isInstallment ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      selected: isInstallment,
                      selectedColor:
                          AppColors
                              .secondaryColor, // O'zingizga mos rang tanlang
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      onSelected:
                          (_) => setState(() {
                            isInstallment = true;
                            isDebt = false; // Qarz bekor qilinadi
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Amount input (only show if not a category)
              if (!widget.isCategory) ...[
                CustomTextField(
                  controller: amountController,
                  hintText: 'amount'.tr(context: context),
                  icon: Icons.attach_money,
                  isRequired: true,
                  isValid: isAmountValid,
                  keyboardType: TextInputType.number,
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
          onTap: () {
            if (widget.isCategory) {
              widget.categoryToEdit != null
                  ? _updateCategory(context)
                  : _addCategory(context);
            } else {
              widget.cashFlowToEdit != null
                  ? _updateCashFlow(context)
                  : _addCashFlow(context);
            }
          },
          color: AppColors.mainColor,
          child: Text(
            widget.categoryToEdit != null || widget.cashFlowToEdit != null
                ? 'save'.tr(context: context)
                : 'add'.tr(context: context),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
