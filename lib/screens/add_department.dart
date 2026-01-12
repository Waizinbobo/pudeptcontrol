import 'package:flutter/material.dart';
import 'add_department_form.dart';
import '../services/department_service.dart';
import '../widgets/bottom_navigation.dart';

class AddDepartmentPage extends StatefulWidget {
  const AddDepartmentPage({super.key});

  @override
  State<AddDepartmentPage> createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _filteredDepartments = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    
    _searchController.addListener(() {
      _filterDepartments(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoading = true);
    
    try {
      final departments = await DepartmentService.getAllDepartments();
      setState(() {
        _departments = departments;
        _filteredDepartments = departments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading departments: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterDepartments(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredDepartments = _departments;
      } else {
        _filteredDepartments = _departments.where((dept) {
          final name = dept['name']?.toString().toLowerCase() ?? '';
          final code = dept['code']?.toString().toLowerCase() ?? '';
          final headName = dept['head_name']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || 
                 code.contains(searchQuery) || 
                 headName.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _refreshDepartments() async {
    await _loadDepartments();
  }

  void _showDepartmentOptions(Map<String, dynamic> department) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    department['name'] ?? 'Department',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('Edit Department'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToEditForm(department);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.green),
                    title: const Text('View Details'),
                    onTap: () {
                      Navigator.pop(context);
                      _showDepartmentDetails(department);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete Department'),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(department);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditForm(Map<String, dynamic> department) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDepartmentFormPage(department: department),
      ),
    ).then((result) {
      if (result == true) {
        _refreshDepartments();
      }
    });
  }

  void _showDepartmentDetails(Map<String, dynamic> department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(department['name'] ?? 'Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Code:', department['code'] ?? 'N/A'),
            _buildDetailRow('Head:', department['head_name'] ?? 'N/A'),
            _buildDetailRow('Staff Count:', '${department['staff_count'] ?? 0}'),
            _buildDetailRow('Description:', department['description'] ?? 'No description'),
            _buildDetailRow('Created:', _formatDate(department['created_at'])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _confirmDelete(Map<String, dynamic> department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${department['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await DepartmentService.deleteDepartment(department['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Department deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _refreshDepartments();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Failed to delete department'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String name) {
    final colors = [
      Colors.blue,
      Colors.indigo,
      Colors.pink,
      Colors.green,
      Colors.purple,
      Colors.amber,
      Colors.teal,
      Colors.orange,
    ];
    
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  IconData _getDepartmentIcon(String name) {
    final icons = [
      Icons.groups,
      Icons.code,
      Icons.campaign,
      Icons.trending_up,
      Icons.palette,
      Icons.account_balance,
      Icons.school,
      Icons.local_hospital,
      Icons.security,
      Icons.analytics,
    ];
    
    final index = name.hashCode.abs() % icons.length;
    return icons[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7F8),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
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
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredDepartments.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isSearching ? Icons.search_off : Icons.business_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isSearching ? 'No departments found' : 'No departments yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (!_isSearching) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add your first department to get started',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _refreshDepartments,
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
                                                _isSearching ? 'SEARCH RESULTS' : 'ALL DEPARTMENTS',
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
                                                  'Total: ${_filteredDepartments.length}',
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
                                        ..._filteredDepartments.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final dept = entry.value;
                                          return _DepartmentCard(
                                            department: dept,
                                            color: _getDepartmentColor(dept['name'] ?? ''),
                                            icon: _getDepartmentIcon(dept['name'] ?? ''),
                                            index: index,
                                            onTap: () => _showDepartmentOptions(dept),
                                          );
                                        }),
                                      ],
                                    ),
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddDepartmentFormPage(),
                        ),
                      );
                      if (result == true) {
                        _refreshDepartments();
                      }
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
  final Map<String, dynamic> department;
  final Color color;
  final IconData icon;
  final int index;
  final VoidCallback onTap;

  const _DepartmentCard({
    required this.department,
    required this.color,
    required this.icon,
    required this.index,
    required this.onTap,
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
                        department['name'] ?? 'Unknown Department',
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
                        '${department['staff_count'] ?? 0} Staff',
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
                  'Head: ${department['head_name'] ?? 'Not assigned'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Code: ${department['code'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 11,
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
            onPressed: onTap,
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
