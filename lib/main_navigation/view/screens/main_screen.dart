import 'package:flutter/material.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/view/screens/home_screen.dart';
// TODO: Import other screens as they are implemented
// import '../../savings/view/screens/savings_screen.dart';
// import '../../statistics/view/screens/statistics_screen.dart';
// import '../../settings/view/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Savings Screen (Coming Soon)")),
    const Center(child: Text("Statistics Screen (Coming Soon)")),
    const Center(child: Text("Settings Screen (Coming Soon)")),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
