import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/add_screen.dart';
import 'package:ombor/views/widgets/cash_flow_card.dart';
import 'package:ombor/views/widgets/custom_floating_button.dart';
import 'package:ombor/views/widgets/show_snack_bar_message_text.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' show Workbook, Worksheet;

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
  final Set<String> selectedCashFlowIds = {}; // Tanlangan itemlar ID'lari
  bool isSelectionMode = false;
  @override
  void initState() {
    super.initState();
    // Load the cash flow data when the screen is first built
    context.read<CashFlowBloc>().add(GetCashFlowsEvent(id: widget.categoryId));
  }

  void _onCashFlowTap(String cashFlowId) {
    setState(() {
      if (selectedCashFlowIds.contains(cashFlowId)) {
        selectedCashFlowIds.remove(cashFlowId);
      } else {
        selectedCashFlowIds.add(cashFlowId);
      }
      isSelectionMode = selectedCashFlowIds.isNotEmpty;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      selectedCashFlowIds.clear();
      isSelectionMode = false;
    });
  }

  void _onDeleteSelectedCashFlows() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirm_delete_title'.tr(context: context)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('no'.tr(context: context)),
            ),
            TextButton(
              onPressed: () {
                List<String> ids = selectedCashFlowIds.toList();
                context.read<CashFlowBloc>().add(DeleteCashFlowEvent(ids));
                _exitSelectionMode();
                showSnackBarMessage(
                  context,
                  'cash_flows_deleted_successfully'.tr(context: context),
                );
                context.pop();
              },
              child: Text('yes'.tr(context: context)),
            ),
          ],
        );
      },
    );
  }

  void _onPrint() async {
    {
      // ResultBlocdan ma'lumotlarni olish

      final state = context.read<CashFlowBloc>().state;

      if (state is CashFlowLoadedState) {
        final List<CashFlowModel> results = state.cashFlows;

        // Excel faylni yaratish

        final Workbook workbook = Workbook();

        final Worksheet sheet = workbook.worksheets[0];

        // Ustun nomlarini qo'shish: faqat "Title", "Amount", "Time"

        if (results.isNotEmpty) {
          // Ustunlar nomini tanlash (faqat kerakli maydonlar)

          List<String> columns = ["Название", "Сумма(uzs)", "Дата"];

          // Ustun nomlarini Excelga yozish

          sheet.getRangeByIndex(1, 1).setText(widget.title);

          for (int col = 0; col < columns.length; col++) {
            sheet.getRangeByIndex(2, col + 1).setText(columns[col]);
          }

          // Ma'lumotlarni Excelga yozish (faqat "title", "amount", "time")

          for (int row = 0; row < results.length; row++) {
            var data = [
              results[row].title,

              results[row].amount.toString(),

              results[row].time.toString(),
            ];

            for (int col = 0; col < data.length; col++) {
              sheet.getRangeByIndex(row + 3, col + 1).setText(data[col]);
            }
          }
        }

        // Excel faylni saqlash

        final directory = await getApplicationSupportDirectory();

        final String filename = '${directory.path}/output.xlsx';

        final File file = File(filename);

        final List<int> bytes = workbook.saveAsStream();

        await file.writeAsBytes(bytes, flush: true);

        workbook.dispose();

        // Faylni boshqa dasturda ochish

        OpenFile.open(filename);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            isSelectionMode
                ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                )
                : null,
        title:
            isSelectionMode
                ? Text(
                  "${selectedCashFlowIds.length}  ${"tanlandi".tr(context: context)}",
                )
                : Text(widget.title, style: AppTextStyles.headlineLarge),
        actions:
            isSelectionMode
                ? [
                  if (selectedCashFlowIds.length == 1)
                    IconButton(
                      onPressed: _onDeleteSelectedCashFlows,
                      icon: AppIcons.remove,
                    ),
                ]
                : [
                  IconButton(onPressed: _onPrint, icon: AppIcons.print),
                  IconButton(onPressed: () {}, icon: AppIcons.calculate),
                  IconButton(onPressed: () {}, icon: AppIcons.filter),
                ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.backgroundSecondary,
            width: double.infinity,
            height: 4,
          ),
          Expanded(
            child: BlocBuilder<CashFlowBloc, CashFlowState>(
              builder: (context, state) {
                if (state is CashFlowLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CashFlowLoadedState) {
                  final cashFlows = state.cashFlows;
                  if (cashFlows.isEmpty) {
                    return Center(child: Text("empty".tr(context: context)));
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
                        final isSelected = selectedCashFlowIds.contains(
                          cashFlow.id,
                        );
                        return GestureDetector(
                          onLongPress: () {
                            _onCashFlowTap(cashFlow.categoryId);
                          },
                          onTap: () {
                            if (isSelectionMode) {
                              _onCashFlowTap(cashFlow.categoryId);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => AddScreen(
                                        isCategory: false,
                                        title: widget.title,
                                        cashFlowToEdit: cashFlow,
                                      ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            color:
                                isSelected
                                    ? AppColors.mainColor.withValues(alpha: 0.3)
                                    : Colors.transparent,
                            child: CashFlowCard(cashFlow: cashFlow),
                          ),
                        );
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
      floatingActionButton:
          isSelectionMode
              ? SizedBox()
              : CustomFloatingButton(
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
