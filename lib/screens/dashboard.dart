import 'package:flutter/material.dart';
import 'add_department.dart';
import 'add_staff.dart';
import 'timetable.dart';
import 'setting.dart';
import 'add_timetable_form.dart';
import 'add_department_form.dart';
import 'add_staff_form.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 1:
        // Navigate to Departments page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddDepartmentPage(),
          ),
        );
        break;
      case 2:
        // Navigate to Staff page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddStaffPage(),
          ),
        );
        break;
      case 3:
        // Navigate to Timetable page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TimetablePage(),
          ),
        );
        break;
      case 4:
        // Navigate to Settings page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsPage(),
          ),
        );
        break;
      case 0:
      default:
        // Dashboard - already on this page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),

      /// 🔝 AppBar with Profile Avatar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),

            /// 👤 Profile Avatar
            const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person, color: Colors.white),
            ),

            const SizedBox(width: 12),

            /// 📅 Date + Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Sep 24, 2023",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "Dashboard",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications, color: Colors.black),
          )
        ],
      ),

      /// ⬇️ Bottom Navigation (Responsive)
       /// ⬇️ Bottom Navigation (UI only)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
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
      ),

      /// 📱 Responsive Body (Phone Width)
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👋 Welcome
                const Text(
                  "Have A Great Day,\nDr. Smith",
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddDepartmentPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.apartment,
                                color: const Color.fromARGB(255, 0, 162, 255),
                                size: 45,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Departments",
                                style: TextStyle(
                                    fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "5",
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.groups_sharp,
                            color: const Color.fromARGB(255, 0, 162, 255),
                            size: 45,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Staff",
                            style: TextStyle(
                                fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "12",
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold
                            ),
                          ),

                        ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔵 Next Up Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF135BEC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Active Timetable",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "10",
                            style: TextStyle(
                                color: Color.fromARGB(179, 255, 255, 255),
                                fontSize: 25,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Quick Actions",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                /// ⚡ Quick Actions
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _QuickAction(
                        Icons.apartment_rounded,
                        "Add Department",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddDepartmentFormPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        Icons.group_add,
                        "Add Staff",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddStaffformPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        Icons.calendar_month,
                        "New Timetable",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTimetablePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const _QuickAction(Icons.description, "Reports"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Recent Activities",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "View All",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._getRecentActivities(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<Widget> _getRecentActivities() {
    final activities = [
      _ActivityData(
        icon: Icons.add_circle_outline,
        title: "New Class Added",
        description: "CS-301 - Data Structures",
        time: "2 hours ago",
        color: Colors.green,
        iconBg: Colors.green.withOpacity(0.1),
      ),
      _ActivityData(
        icon: Icons.person_add,
        title: "Staff Member Added",
        description: "Dr. Sarah Johnson joined",
        time: "5 hours ago",
        color: Colors.blue,
        iconBg: Colors.blue.withOpacity(0.1),
      ),
      _ActivityData(
        icon: Icons.edit_calendar,
        title: "Timetable Updated",
        description: "Room 204 schedule changed",
        time: "1 day ago",
        color: Colors.orange,
        iconBg: Colors.orange.withOpacity(0.1),
      ),
      _ActivityData(
        icon: Icons.delete_outline,
        title: "Class Cancelled",
        description: "CS-205 cancelled for today",
        time: "2 days ago",
        color: Colors.red,
        iconBg: Colors.red.withOpacity(0.1),
      ),
      _ActivityData(
        icon: Icons.notifications_active,
        title: "Reminder Set",
        description: "Meeting reminder for tomorrow",
        time: "3 days ago",
        color: Colors.purple,
        iconBg: Colors.purple.withOpacity(0.1),
      ),
    ];

    return activities.map((activity) => _ActivityCard(activity)).toList();
  }
}

/// 🔘 Quick Action Item
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction(this.icon, this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: onTap ?? () {},
            icon: Icon(icon, color: Colors.blue, size: 20),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// /// 👤 Staff Card
// class _StaffCard extends StatelessWidget {
//   final String name;
//   final String role;

//   const _StaffCard(this.name, this.role);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 130,
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           const CircleAvatar(radius: 24),
//           const SizedBox(height: 8),
//           Text(name,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 13)),
//           Text(role,
//               style: const TextStyle(
//                   fontSize: 11, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }

/// 📋 Activity Data Model
class _ActivityData {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final Color color;
  final Color iconBg;

  _ActivityData({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.color,
    required this.iconBg,
  });
}

/// 🎴 Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final _ActivityData activity;

  const _ActivityCard(this.activity);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 0, right: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          /// Time
          Text(
            activity.time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
