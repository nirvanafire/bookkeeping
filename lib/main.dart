import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'database/database.dart';
import 'providers/transaction_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(database: AppDatabase()),
        ),
      ],
      child: MaterialApp(
        title: '记账本',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            surface: Colors.grey[50],
          ),
          fontFamily: 'SF Pro Display',
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavItem> _navItems = [
    const BottomNavItem(
      icon: Icons.edit_note,
      label: '记账',
    ),
    const BottomNavItem(
      icon: Icons.bar_chart,
      label: '统计',
    ),
    const BottomNavItem(
      icon: Icons.person,
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
