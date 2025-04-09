import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ombor/views/screens/auth/password_screen.dart';
import 'package:ombor/controllers/blocs/archived_category_bloc/archived_category_bloc.dart';
import 'package:ombor/controllers/blocs/balance_bloc/balance_bloc.dart';
import 'package:ombor/controllers/blocs/cash_flow_bloc/cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/category_bloc/category_bloc.dart';
import 'package:ombor/controllers/blocs/expense_cash_flows/expense_cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/income_cash_flows/income_cash_flow_bloc.dart';
import 'package:ombor/controllers/blocs/income_expense_bloc/income_expense_bloc.dart';
import 'package:ombor/controllers/blocs/result_bloc/result_bloc.dart';
import 'package:ombor/controllers/blocs/search_bloc/search_bloc.dart';
import 'package:ombor/models/helpers/category_helper.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/views/widgets/layout_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // Ensure localization is initialized

  runApp(
    EasyLocalization(
      saveLocale: true,
      supportedLocales: [Locale('en'), Locale('uz'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: Locale('uz'),
      child: MainApp(),
    ),
  );
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
          BlocProvider(create: (context) => IncomeCashFlowBloc()),
          BlocProvider(create: (context) => ExpenseCashFlowBloc()),
          BlocProvider(create: (context) => IncomeExpenseBloc()),
          BlocProvider(
            create: (context) => ArchivedCategoryBloc(CategoryHelper()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: LauncherScreen(), // ✅ Shu yerdan boshlanadi
        ),
      ),
    );
  }
}

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  bool _isAuthenticated = false;

  void _handleAuthSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated
        ? const LayoutScaffold()
        : PasswordScreen(onSuccess: _handleAuthSuccess);
  }
}
