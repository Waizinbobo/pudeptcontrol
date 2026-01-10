import 'package:flutter/material.dart';
import 'add_staff_form.dart';
import '../widgets/bottom_navigation.dart';

class AddStaffPage extends StatefulWidget {
  const AddStaffPage({super.key});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _searchController = TextEditingController();

  // Sample staff list
  final List<Map<String, dynamic>> _staffList = [
    {
      'name': 'Dr. Sarah Jenkins',
      'role': 'Senior Lecturer',
      'department': 'Computer Science',
      'icon': Icons.person,
      'color': Colors.blue,
      'badge': 'ADMIN',
    },
    {
      'name': 'Mark Thompson',
      'role': 'Lab Technician',
      'department': 'Physics',
      'icon': Icons.science,
      'color': Colors.green,
    },
    {
      'name': 'Prof. Alan Grant',
      'role': 'Head of Department',
      'department': 'Paleontology',
      'icon': Icons.school,
      'color': Colors.purple,
      'badge': 'HEAD',
    },
    {
      'name': 'Dr. Emily Chen',
      'role': 'Research Fellow',
      'department': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.orange,
    },
    {
      'name': 'James Wilson',
      'role': 'Coordinator',
      'department': 'Administration',
      'icon': Icons.work,
      'color': Colors.indigo,
    },
    {
      'name': 'Dr. Michael Brown',
      'role': 'Professor',
      'department': 'Engineering',
      'icon': Icons.engineering,
      'color': Colors.red,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7F8),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios, size: 18),
              Text("Back"),
            ],
          ),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Staff',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Manage staff members',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              children: [
                Column(
                  children: [
                    /// Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search staff...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Main Content List
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// List Header
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16, top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ALL STAFF MEMBERS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF136DEC).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Total: ${_staffList.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF136DEC),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Staff List
                            ..._staffList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final staff = entry.value;
                              return _StaffCard(
                                name: staff['name'],
                                role: staff['role'],
                                department: staff['department'],
                                icon: staff['icon'],
                                color: staff['color'],
                                badge: staff['badge'],
                                index: index,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                /// Floating Action Button
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Navigate to add staff form page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddStaffformPage(),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF136DEC),
                    elevation: 8,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}

/// Staff Card Widget
class _StaffCard extends StatelessWidget {
  final String name;
  final String role;
  final String department;
  final IconData icon;
  final Color color;
  final String? badge;
  final int index;

  const _StaffCard({
    required this.name,
    required this.role,
    required this.department,
    required this.icon,
    required this.color,
    this.badge,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Icon/Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  department,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          /// More Options Button
          IconButton(
            onPressed: () {
              // Show options menu
            },
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
