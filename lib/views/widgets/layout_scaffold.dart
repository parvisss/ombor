import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/views/screens/archive/archive_screen.dart';
import 'package:ombor/views/screens/home/home_screen.dart';
import 'package:ombor/views/screens/reports/reporst_screen.dart';
import 'package:ombor/views/screens/result/results_screen.dart';
import 'package:ombor/views/screens/settings/settings_screen.dart';

class LayoutScaffold extends StatefulWidget {
  const LayoutScaffold({super.key});

  @override
  State<LayoutScaffold> createState() => _LayoutScaffoldState();
}

class _LayoutScaffoldState extends State<LayoutScaffold> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomeScreen(),
    ResultsScreen(),
    ReportsScreen(),
    ArchiveScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // selectedIconTheme: IconThemeData(color: Colors.blue),
        selectedFontSize: 16,
        unselectedFontSize: 15,
        selectedItemColor: AppColors.positive,
        unselectedItemColor: AppColors.mainColor,
        iconSize: 35,
        // fixedColor: Colors.red,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: AppIcons.monetization,
            label: 'home'.tr(context: context),
          ),
          BottomNavigationBarItem(
            icon: AppIcons.result,
            label: 'results'.tr(context: context),
          ),
          BottomNavigationBarItem(
            icon: AppIcons.report,
            label: 'reports_screen_title'.tr(context: context),
          ),
          BottomNavigationBarItem(
            icon: AppIcons.archive,
            label: 'archive'.tr(context: context),
          ),
          BottomNavigationBarItem(
            icon: AppIcons.settings,
            label: 'settings'.tr(context: context),
          ),
        ],
        onTap: _onTap,
      ),
    );
  }
}
