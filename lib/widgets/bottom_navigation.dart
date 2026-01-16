import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/add_department.dart';
import '../screens/staff_list.dart';
import '../screens/timetable.dart';
import '../screens/setting.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  
  const AppBottomNavigation({super.key, required this.currentIndex});

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardUI()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AddDepartmentPage()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StaffListPage()),
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TimetablePage()),
          (route) => false,
        );
        break;
      case 4:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigateToPage(context, index),
      selectedItemColor: const Color(0xFF135BEC),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(
            icon: Icon(Icons.apartment), label: "Departments"),
        BottomNavigationBarItem(
            icon: Icon(Icons.group), label: "Staff"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month), label: "Timetable"),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
