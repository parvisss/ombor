import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_event.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/models/search_result.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/add_screen.dart';
import 'package:ombor/views/screens/home/cash_flow_screen.dart';
import 'package:ombor/views/widgets/cash_flow_card.dart';
import 'package:ombor/views/widgets/category_card.dart'; // Yangi modelni import qilish

class SearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Qidiruv')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Qidiruv TextField
            TextField(
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
              controller: _controller,
              keyboardType: TextInputType.webSearch,
              decoration: InputDecoration(
                prefixIcon: AppIcons.search,
                hintText: 'enter_search_term'.tr(context: context),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.mainColor,
                    width: 2.8,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.mainColor,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.mainColor,
                    width: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // BlocBuilder
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                // Loading holatida spinner ko'rsatish
                if (state is SearchLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                // Bo'sh qidiruv holati
                if (_controller.text.isEmpty) {
                  return Center(
                    child: Text(
                      'enter_search_term'.tr(context: context),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // Natijalar yuklanganda
                if (state is SearchLoaded) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final searchResult = state.results[index];
                        if (searchResult.type == SearchResultType.cashFlow) {
                          // CashFlowModel uchun UI
                          final cashFlow = searchResult.data as CashFlowModel;
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => AddScreen(
                                        isCategory: false,
                                        cashFlowToEdit: cashFlow,
                                        categoryId: cashFlow.categoryId,
                                        title: cashFlow.title,
                                      ),
                                ),
                              );
                            },
                            child: CashFlowCard(
                              cashFlow: cashFlow,
                              isSearch: true,
                            ),
                          );
                        } else if (searchResult.type ==
                            SearchResultType.category) {
                          // CategoryModel uchun UI
                          final category = searchResult.data as CategoryModel;
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => CashFlowScreen(
                                        title: category.title,
                                        balance: category.balance,
                                        categoryId: category.id,
                                      ),
                                ),
                              );
                            },
                            child: CategoryCard(category: category),
                          );
                        }
                        return Container();
                      },
                    ),
                  );
                }

                // Xato holati
                if (state is SearchError) {
                  return Center(child: Text(state.message));
                }

                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
