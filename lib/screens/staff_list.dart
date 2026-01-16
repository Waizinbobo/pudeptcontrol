import 'package:flutter/material.dart';
import 'add_staff_form.dart';
import '../services/staff_service.dart';
import '../services/department_service.dart';
import '../widgets/bottom_navigation.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _filteredStaff = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _selectedDepartmentFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    _searchController.addListener(() {
      _filterStaff(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final staff = await StaffService.getAllStaff();
      final departments = await DepartmentService.getAllDepartments();
      
      setState(() {
        _staff = staff;
        _filteredStaff = staff;
        _departments = departments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterStaff(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      
      List<Map<String, dynamic>> tempStaff = _staff;
      
      // Filter by department if selected
      if (_selectedDepartmentFilter != null) {
        tempStaff = tempStaff.where((staff) => 
          staff['department_id'] == _selectedDepartmentFilter
        ).toList();
      }
      
      // Filter by search query
      if (query.isNotEmpty) {
        tempStaff = tempStaff.where((staff) {
          final name = staff['name']?.toString().toLowerCase() ?? '';
          final email = staff['email']?.toString().toLowerCase() ?? '';
          final position = staff['position']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || 
                 email.contains(searchQuery) || 
                 position.contains(searchQuery);
        }).toList();
      }
      
      _filteredStaff = tempStaff;
    });
  }

  Future<void> _refreshStaff() async {
    await _loadData();
  }

  void _showStaffOptions(Map<String, dynamic> staff) {
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
                    staff['name'] ?? 'Staff Member',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('Edit Staff'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToEditForm(staff);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.green),
                    title: const Text('View Details'),
                    onTap: () {
                      Navigator.pop(context);
                      _showStaffDetails(staff);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete Staff'),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(staff);
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

  void _navigateToEditForm(Map<String, dynamic> staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStaffformPage(staff: staff),
      ),
    ).then((result) {
      if (result == true) {
        _refreshStaff();
      }
    });
  }

  void _showStaffDetails(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff['name'] ?? 'Staff Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email:', staff['email'] ?? 'N/A'),
            _buildDetailRow('Position:', staff['position'] ?? 'N/A'),
            _buildDetailRow('Phone:', staff['phone'] ?? 'N/A'),
            _buildDetailRow('Department:', _getDepartmentName(staff['department_id'])),
            _buildDetailRow('Hire Date:', _formatDate(staff['hire_date'])),
            _buildDetailRow('Salary:', staff['salary'] != null ? '\$${staff['salary']}' : 'N/A'),
            _buildDetailRow('Created:', _formatDate(staff['created_at'])),
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

  String _getDepartmentName(String? departmentId) {
    if (departmentId == null) return 'N/A';
    
    final department = _departments.firstWhere(
      (dept) => dept['id'] == departmentId,
      orElse: () => {'name': 'Unknown'},
    );
    
    return department['name'] ?? 'Unknown';
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

  void _confirmDelete(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to delete "${staff['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await StaffService.deleteStaff(staff['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Staff deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _refreshStaff();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Failed to delete staff'),
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

  Color _getStaffColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
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
                'Staff Members',
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
                'Manage organization staff',
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
                            hintText: 'Search staff members...',
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

                    /// Department Filter
                    if (_departments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text('All Departments'),
                              value: _selectedDepartmentFilter,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All Departments'),
                                ),
                                ..._departments.map((dept) {
                                  return DropdownMenuItem<String>(
                                    value: dept['id'],
                                    child: Text(dept['name'] ?? 'Unknown'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartmentFilter = value;
                                });
                                _filterStaff(_searchController.text);
                              },
                            ),
                          ),
                        ),
                      ),

                    /// Main Content List
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredStaff.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isSearching ? Icons.search_off : Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isSearching ? 'No staff found' : 'No staff members yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (!_isSearching) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add your first staff member to get started',
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
                                  onRefresh: _refreshStaff,
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
                                                _isSearching ? 'SEARCH RESULTS' : 'ALL STAFF',
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
                                                  'Total: ${_filteredStaff.length}',
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
                                        ..._filteredStaff.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final staff = entry.value;
                                          return _StaffCard(
                                            staff: staff,
                                            color: _getStaffColor(staff['name'] ?? ''),
                                            index: index,
                                            onTap: () => _showStaffOptions(staff),
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
                          builder: (context) => const AddStaffformPage(),
                        ),
                      );
                      if (result == true) {
                        _refreshStaff();
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}

/// Staff Card Widget
class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _StaffCard({
    required this.staff,
    required this.color,
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
          /// Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
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
                        staff['name'] ?? 'Unknown Staff',
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
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        staff['position'] ?? 'No Position',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  staff['email'] ?? 'No Email',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  staff['departments']?['name'] ?? 'No Department',
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
