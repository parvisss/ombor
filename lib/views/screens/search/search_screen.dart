import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_event.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_state.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/models/search_result.dart';
import 'package:ombor/utils/app_text_styles.dart';
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
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Qidiruv so\'zini kiriting',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 12,
                ),
              ),
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
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
                      'Qidiruvni kiriting',
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
                          return CashFlowCard(cashFlow: cashFlow);
                        } else if (searchResult.type ==
                            SearchResultType.category) {
                          // CategoryModel uchun UI
                          final category = searchResult.data as CategoryModel;
                          return CategoryCard(category: category);
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
