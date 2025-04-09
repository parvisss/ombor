import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/app_globals.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_bloc.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_event.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_state.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_event.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/cash_flow_screen.dart';
import 'package:ombor/views/screens/search/calculator_screen.dart';
import 'package:ombor/views/screens/search/filter_data_bottom_sheet.dart';
import 'package:ombor/views/widgets/category_card.dart';
import 'package:ombor/views/widgets/custom_restart_button.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final Set<String> selectedCategoryIds = {}; // Tanlangan itemlar ID'lari
  bool isSelectionMode = false;

  @override
  void initState() {
    _reset();
    super.initState();
  }

  void _reset() {
    context.read<ArchivedCategoryBloc>().add(LoadArchivedCategories());
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

  void _onFilter() {
    final parentContext = context; // yuqorida saqlab qo‘yamiz

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FilterDateBottomSheet(
          startDate: AppGlobals.archiveStartDate,
          endDate: AppGlobals.archiveEndDate,
          onStartDateSelected: (pickedDate) {
            if (pickedDate != null) {
              AppGlobals.archiveStartDate.value = pickedDate;
            }
          },
          onEndDateSelected: (pickedDate) {
            if (pickedDate != null) {
              AppGlobals.archiveEndDate.value = pickedDate;
            }
          },
          onFilter: () {
            parentContext.read<ArchivedCategoryBloc>().add(
              LoadArchivedCategories(),
            );
            Navigator.pop(context); // BottomSheet ni yopish
          },
        );
      },
    );
  }

  void _exitSelectionMode() {
    setState(() {
      selectedCategoryIds.clear();
      isSelectionMode = false;
    });
  }

  void _unArchive() {
    List<String> selectedItemsIds = selectedCategoryIds.toList();
    context.read<ArchivedCategoryBloc>().add(
      RestoreArchivedCategory(selectedItemsIds),
    );

    _exitSelectionMode();
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
                : Text(
                  'archive'.tr(context: context),
                  style: AppTextStyles.headlineLarge,
                ),
        actions:
            isSelectionMode
                ? [
                  IconButton(onPressed: _unArchive, icon: AppIcons.unArchive),
                  IconButton(onPressed: () {}, icon: AppIcons.remove),
                ]
                : [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => CalculatorScreen()),
                      );
                    },
                    icon: AppIcons.calculate,
                  ),
                  IconButton(onPressed: _onFilter, icon: AppIcons.filter),
                ],
      ),
      body: BlocBuilder<ArchivedCategoryBloc, ArchivedCategoryState>(
        builder: (context, state) {
          if (state is ArchivedCategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ArchivedCategoryLoaded) {
            if (state.categories.isEmpty) {
              return Center(
                child: CustomRestartButton(
                  onTap: () {
                    context.read<ArchivedCategoryBloc>().add(
                      LoadArchivedCategories(),
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
                  final isSelected = selectedCategoryIds.contains(category.id);

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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CategoryCard(category: category),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is ArchivedCategoryError) {
            return Center(child: Text("Xatolik: ${state.message}"));
          }

          return Center(
            child: CustomRestartButton(
              onTap: () {
                context.read<ArchivedCategoryBloc>().add(
                  LoadArchivedCategories(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
