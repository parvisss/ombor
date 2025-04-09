import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_event.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_bloc.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_state.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/add_screen.dart';
import 'package:ombor/views/screens/home/cash_flow_screen.dart';
import 'package:ombor/views/screens/home/widgets/overal_balance_widget.dart';
import 'package:ombor/views/screens/search/calculator_screen.dart';
import 'package:ombor/views/screens/search/filter_data_bottom_sheet.dart';
import 'package:ombor/views/screens/search/search_screen.dart';
import 'package:ombor/views/widgets/category_card.dart';
import 'package:ombor/views/widgets/custom_floating_button.dart';
import 'package:ombor/views/widgets/custom_restart_button.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' show Workbook, Worksheet;

import '../../../utils/app_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> selectedCategoryIds = {}; // Tanlangan itemlar ID'lari
  bool isSelectionMode = false;

  @override
  void initState() {
    _reset();
    super.initState();
  }

  void _reset() {
    context.read<CategoryBloc>().add(GetCategoriesEvent(isArchive: false));
    context.read<BalanceBloc>().add(GetTotalBalanceEvent());
    selectedCategoryIds.clear();
    isSelectionMode = false;
  }

  void _onCategoryTap(String categoryId) {
    setState(() {
      if (selectedCategoryIds.contains(categoryId)) {
        selectedCategoryIds.remove(categoryId);
      } else {
        selectedCategoryIds.add(categoryId);
      }
      isSelectionMode = selectedCategoryIds.isNotEmpty;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      selectedCategoryIds.clear();
      isSelectionMode = false;
    });
  }

  void _onArchive() {
    List<String> selectedItemsIds = selectedCategoryIds.toList();
    context.read<CategoryBloc>().add(
      ArchiveMultipleCategoriesEvent(selectedItemsIds, 1),
    );
    context.read<BalanceBloc>().add(GetTotalBalanceEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('categories_archived_successfully'.tr(context: context)),
      ),
    );
    _exitSelectionMode();
  }

  void _onDelete() {
    List<String> ids = selectedCategoryIds.toList();
    context.read<CategoryBloc>().add(DeleteCategoryEvent(id: ids));
    context.read<CashFlowBloc>().add(DeleteCashFlowEvent(ids));
    _exitSelectionMode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('categories_deleted_successfully'.tr(context: context)),
      ),
    );
    Navigator.of(context).pop();
  }

  void _onPrint() async {
    // ResultBlocdan ma'lumotlarni olish
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoadedState) {
      final List<CategoryModel> results = state.categories;

      // Excel faylni yaratish
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Ustun nomlarini qo'shish: faqat "Title", "Amount", "Time"
      if (results.isNotEmpty) {
        // Ustunlar nomini tanlash (faqat kerakli maydonlar)
        List<String> columns = ["Название", "Сумма(uzs)", "Дата"];

        // Ustun nomlarini Excelga yozish
        for (int col = 0; col < columns.length; col++) {
          sheet.getRangeByIndex(1, col + 1).setText(columns[col]);
        }

        // Ma'lumotlarni Excelga yozish (faqat "title", "amount", "time")
        for (int row = 0; row < results.length; row++) {
          var data = [
            results[row].title,
            results[row].balance.toString(),
            results[row].time.toString(),
          ];

          for (int col = 0; col < data.length; col++) {
            sheet.getRangeByIndex(row + 2, col + 1).setText(data[col]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            isSelectionMode
                ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                )
                : null,
        title:
            isSelectionMode
                ? Text(
                  "${selectedCategoryIds.length}  ${"tanlandi".tr(context: context)}",
                )
                : Text(
                  'home'.tr(context: context),
                  style: AppTextStyles.headlineLarge,
                ),
        actions:
            isSelectionMode
                ? [
                  //archive
                  IconButton(onPressed: _onArchive, icon: AppIcons.archive),

                  //delete
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'confirm_delete_title'.tr(context: context),
                            ),
                            actions: <Widget>[
                              //no
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('no'.tr(context: context)),
                              ),

                              //yes
                              TextButton(
                                onPressed: _onDelete,
                                child: Text('yes'.tr(context: context)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: AppIcons.remove,
                  ),
                ]
                : [
                  //print
                  IconButton(
                    onPressed: _onPrint,

                    icon: AppIcons.print, // Excelni chop etish ikonasi
                  ),

                  //calculate
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => CalculatorScreen()),
                      );
                    },
                    icon: AppIcons.calculate,
                  ),

                  //filter
                  IconButton(
                    onPressed: () {
                      final parentContext = context; // yuqorida saqlab qo‘yamiz

                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return FilterDateBottomSheet(
                            startDate: AppGlobals.startDate,
                            endDate: AppGlobals.endDate,
                            onStartDateSelected: (pickedDate) {
                              if (pickedDate != null) {
                                AppGlobals.startDate.value = pickedDate;
                              }
                            },
                            onEndDateSelected: (pickedDate) {
                              if (pickedDate != null) {
                                AppGlobals.endDate.value = pickedDate;
                              }
                            },
                            onFilter: () {
                              parentContext.read<CategoryBloc>().add(
                                GetCategoriesEvent(isArchive: false),
                              );
                              Navigator.pop(context); // BottomSheet ni yopish
                            },
                          );
                        },
                      );
                    },
                    icon: AppIcons.filter,
                  ),

                  //search
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => SearchScreen()),
                      );
                    },
                    icon: AppIcons.search,
                  ),
                ],
      ),
      body: Column(
        children: [
          OveralBalanceWidget(),
          Container(
            color: AppColors.backgroundSecondary,
            width: double.infinity,
            height: 4,
          ),

          // BlocBuilder bilan ListView
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoadedState) {
                  if (state.categories.isEmpty) {
                    return Center(child: CustomRestartButton(onTap: _reset));
                  }
                  final categories = state.categories;
                  return RefreshIndicator(
                    onRefresh: () async {
                      _reset();
                    },
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategoryIds.contains(
                          category.id,
                        );

                        return GestureDetector(
                          onLongPress: () {
                            _onCategoryTap(category.id); // select mode
                          },
                          onTap: () {
                            if (isSelectionMode) {
                              _onCategoryTap(category.id);
                            } else {
                              // Oddiy rejimda CashFlowScreen ga o'tish
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => CashFlowScreen(
                                        title: category.title,
                                        balance: category.balance,
                                        categoryId: category.id,
                                      ),
                                ),
                              );
                              context.read<CashFlowBloc>().add(
                                GetCashFlowsEvent(id: category.id),
                              );
                            }
                          },
                          child: Container(
                            color:
                                isSelected
                                    ? AppColors.mainColor.withValues(alpha: 0.3)
                                    : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: CategoryCard(category: category),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is CategoryErrorState) {
                  return Center(child: Text(state.errorMessage));
                } else {
                  return Center(child: CustomRestartButton(onTap: _reset));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          isSelectionMode
              ? null
              : CustomFloatingButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const AddScreen(isCategory: true),
                    ),
                  );
                },
              ),
    );
  }
}
