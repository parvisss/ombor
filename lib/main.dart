import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_bloc.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_bloc.dart';
import 'package:ombor/models/helpers/category_helper.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/views/widgets/layout_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // muhim
  //
  // await CategoryHelper().deleteLocalDatabase(); // 💥 Diqqat: faqat test uchun
  // await CategoryHelper().clearTable(); // jadvalni tozalaydi
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.mainColor),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CategoryBloc()),
          BlocProvider(create: (context) => CashFlowBloc()),
          BlocProvider(create: (context) => BalanceBloc()),
          BlocProvider(create: (context) => ResultBloc()),
          BlocProvider(create: (context) => SearchBloc()),

          BlocProvider(
            create: (context) => ArchivedCategoryBloc(CategoryHelper()),
          ),
        ],
        child: const MaterialApp(
          home: LayoutScaffold(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
