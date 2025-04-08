import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_event.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_state.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_bloc.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_event.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_state.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/add_screen.dart';
import 'package:ombor/views/screens/home/cash_flow_screen.dart';
import 'package:ombor/views/screens/search/calculator_screen.dart';
import 'package:ombor/views/screens/search/filter_data_bottom_sheet.dart';
import 'package:ombor/views/screens/search/search_screen.dart';
import 'package:ombor/views/widgets/balance_text_widget.dart';
import 'package:ombor/views/widgets/category_card.dart';
import 'package:ombor/views/widgets/custom_floating_button.dart';
import 'package:ombor/views/widgets/custom_restart_button.dart';

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
                ? Text("${selectedCategoryIds.length} tanlandi")
                : Text('Долги', style: AppTextStyles.headlineLarge),
        actions:
            isSelectionMode
                ? [
                  //archive
                  IconButton(
                    onPressed: () {
                      List<String> selectedItemsIds =
                          selectedCategoryIds.toList();
                      context.read<CategoryBloc>().add(
                        ArchiveMultipleCategoriesEvent(selectedItemsIds, 1),
                      );
                      _exitSelectionMode();
                    },
                    icon: AppIcons.archive,
                  ),

                  //delete
                  IconButton(onPressed: () {}, icon: AppIcons.remove),
                ]
                : [
                  //print
                  IconButton(onPressed: () {}, icon: AppIcons.print),

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
          ListTile(
            title: Text('Общая сумма'),
            subtitle: BlocBuilder<BalanceBloc, BalanceState>(
              builder: (context, state) {
                if (state is BalanceLoadedState) {
                  return BalanceTextWidget(balance: state.totalBalance);
                }
                return Text("0");
              },
            ),
          ),
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
                    return Center(
                      child: CustomRestartButton(
                        onTap: () {
                          context.read<CategoryBloc>().add(
                            GetCategoriesEvent(isArchive: false),
                          );
                        },
                      ),
                    );
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
                  return Center(child: Text("Xatolik: ${state.errorMessage}"));
                } else {
                  return Center(
                    child: CustomRestartButton(
                      onTap: () {
                        context.read<CategoryBloc>().add(
                          GetCategoriesEvent(isArchive: false),
                        );
                      },
                    ),
                  );
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
