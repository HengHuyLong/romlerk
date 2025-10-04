import 'package:flutter/material.dart';
import '../../../ui/widgets/custom_app_bar.dart';
import '../../../ui/widgets/custom_drawer.dart';
import '../../../ui/widgets/custom_bottom_nav.dart';
import '../../../core/theme/app_colors.dart';
import '../documents/documents_screen.dart';
import '../scan/scan_screen.dart';
import '../settings/settings_screen.dart';
import '../../../core/theme/app_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(
        child: Text(
      "Home Page Placeholder",
      style: AppTypography.h2.copyWith(
        color: AppColors.darkGray,
      ),
    )), // ✅ will be replaced later
    const DocumentsScreen(),
    const ScanScreen(),
    const SettingsScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _selectedIndex == 3 ? null : const CustomAppBar(),
      endDrawer: const CustomDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
