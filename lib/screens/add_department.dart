import 'package:flutter/material.dart';
import 'add_department_form.dart';
import '../widgets/bottom_navigation.dart';

class AddDepartmentPage extends StatefulWidget {
  const AddDepartmentPage({super.key});

  @override
  State<AddDepartmentPage> createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  final _searchController = TextEditingController();

  // Sample departments list with colors
  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'Human Resources',
      'head': 'Sarah Jenkins',
      'staff': '8',
      'icon': Icons.groups,
      'color': Colors.blue,
    },
    {
      'name': 'Engineering',
      'head': 'Mike Ross',
      'staff': '24',
      'icon': Icons.code,
      'color': Colors.indigo,
    },
    {
      'name': 'Marketing',
      'head': 'Jessica Pearson',
      'staff': '12',
      'icon': Icons.campaign,
      'color': Colors.pink,
    },
    {
      'name': 'Sales',
      'head': 'Louis Litt',
      'staff': '18',
      'icon': Icons.trending_up,
      'color': Colors.green,
    },
    {
      'name': 'Product Design',
      'head': 'Rachel Zane',
      'staff': '6',
      'icon': Icons.palette,
      'color': Colors.purple,
    },
    {
      'name': 'Finance',
      'head': 'Katrina Bennett',
      'staff': '5',
      'icon': Icons.account_balance,
      'color': Colors.amber,
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
        // toolbarHeight: 70,
        backgroundColor: const Color(0xFFF6F7F8),
        // leading: InkWell(
        //   onTap: () => Navigator.pop(context),
        //   child: const Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Icon(Icons.arrow_back_ios, size: 18),
        //       Text("Back"),
        //     ],
        //   ),
        // ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child:  Text(
                'Departments',
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
                'Manage organization structure',
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
                            hintText: 'Search departments...',
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
                                    'ALL DEPARTMENTS',
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
                                      'Total: ${_departments.length}',
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

                            /// Departments List
                            ..._departments.asMap().entries.map((entry) {
                              final index = entry.key;
                              final dept = entry.value;
                              return _DepartmentCard(
                                name: dept['name'],
                                head: dept['head'],
                                staffCount: dept['staff'],
                                icon: dept['icon'],
                                color: dept['color'],
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddDepartmentFormPage(),
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

/// Department Card Widget
class _DepartmentCard extends StatelessWidget {
  final String name;
  final String head;
  final String staffCount;
  final IconData icon;
  final Color color;
  final int index;

  const _DepartmentCard({
    required this.name,
    required this.head,
    required this.staffCount,
    required this.icon,
    required this.color,
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
          /// Icon
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$staffCount Staff',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Head: $head',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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
