import 'package:flutter/material.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/views/screens/archive/archive_screen.dart';
import 'package:ombor/views/screens/home/home_screen.dart';
import 'package:ombor/views/screens/result/results_screen.dart';

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
    ResultsScreen(),
    ArchiveScreen(),
    ResultsScreen(),
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
        items: const [
          BottomNavigationBarItem(icon: AppIcons.monetization, label: 'Долги'),
          BottomNavigationBarItem(icon: AppIcons.result, label: 'Итоги'),
          BottomNavigationBarItem(icon: AppIcons.report, label: 'Отчёты'),
          BottomNavigationBarItem(icon: AppIcons.archive, label: 'Архив'),
          BottomNavigationBarItem(icon: AppIcons.settings, label: 'Настройки'),
        ],
        onTap: _onTap,
      ),
    );
  }
}
