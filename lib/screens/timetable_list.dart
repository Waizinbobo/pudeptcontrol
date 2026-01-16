import 'package:flutter/material.dart';
import '../services/timetable_service.dart';
import '../services/department_service.dart';
import 'add_timetable_form.dart';
import '../widgets/bottom_navigation.dart';
import 'timetable.dart';

class TimetableListPage extends StatefulWidget {
  const TimetableListPage({super.key});

  @override
  State<TimetableListPage> createState() => _TimetableListPageState();
}

class _TimetableListPageState extends State<TimetableListPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _timetables = [];
  List<Map<String, dynamic>> _filteredTimetables = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _selectedDepartmentFilter;
  String? _selectedDayFilter;

  final List<String> _days = ['All', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final timetables = await TimetableService.getAllTimetables();
      final departments = await DepartmentService.getAllDepartments();
      
      setState(() {
        _timetables = timetables;
        _filteredTimetables = timetables;
        _departments = departments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterTimetables(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      
      List<Map<String, dynamic>> tempTimetables = _timetables;
      
      // Filter by department if selected
      if (_selectedDepartmentFilter != null) {
        tempTimetables = tempTimetables.where((timetable) => 
          timetable['department_id'] == _selectedDepartmentFilter
        ).toList();
      }
      
      // Filter by day if selected
      if (_selectedDayFilter != null && _selectedDayFilter != 'All') {
        tempTimetables = tempTimetables.where((timetable) => 
          timetable['day'] == _selectedDayFilter
        ).toList();
      }
      
      // Filter by search query
      if (query.isNotEmpty) {
        tempTimetables = tempTimetables.where((timetable) {
          final subject = timetable['subject']?.toString().toLowerCase() ?? '';
          final teacher = timetable['teacher']?.toString().toLowerCase() ?? '';
          final room = timetable['room']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return subject.contains(searchQuery) || 
                 teacher.contains(searchQuery) || 
                 room.contains(searchQuery);
        }).toList();
      }
      
      _filteredTimetables = tempTimetables;
    });
  }

  Future<void> _refreshTimetables() async {
    await _loadData();
  }

  void _showTimetableOptions(Map<String, dynamic> timetable) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              timetable['subject'] ?? 'Timetable Entry',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showTimetableDetails(timetable);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTimetablePage(timetable: timetable),
                  ),
                ).then((_) => _refreshTimetables());
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(timetable);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTimetableDetails(Map<String, dynamic> timetable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(timetable['subject'] ?? 'Timetable Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Teacher:', timetable['teacher'] ?? 'N/A'),
              _buildDetailRow('Day:', timetable['day'] ?? 'N/A'),
              _buildDetailRow('Time:', '${timetable['start_time'] ?? 'N/A'} - ${timetable['end_time'] ?? 'N/A'}'),
              _buildDetailRow('Room:', timetable['room'] ?? 'N/A'),
              _buildDetailRow('Department:', timetable['departments']?['name'] ?? 'N/A'),
              if (timetable['description'] != null && timetable['description'].toString().isNotEmpty)
                _buildDetailRow('Description:', timetable['description']),
              _buildDetailRow('Created:', _formatDate(timetable['created_at'])),
            ],
          ),
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

  void _confirmDelete(Map<String, dynamic> timetable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timetable'),
        content: Text('Are you sure you want to delete "${timetable['subject']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await TimetableService.deleteTimetable(timetable['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Timetable deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                _refreshTimetables();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete timetable'),
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

  Color _getSubjectColor(String subject) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    final index = subject.hashCode % colors.length;
    return colors[index];
  }

  IconData _getSubjectIcon(String subject) {
    final icons = [
      Icons.book,
      Icons.code,
      Icons.science,
      Icons.calculate,
      Icons.language,
      Icons.palette,
      Icons.music_note,
      Icons.sports,
    ];
    final index = subject.hashCode % icons.length;
    return icons[index];
  }

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
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Timetables',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Manage class schedules',
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
                    // Search Bar
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
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search timetables...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: _filterTimetables,
                        ),
                      ),
                    ),

                    // Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: const Text('Day', style: TextStyle(fontSize: 14)),
                                  value: _selectedDayFilter,
                                  isExpanded: true,
                                  items: _days.map((day) {
                                    return DropdownMenuItem<String>(
                                      value: day,
                                      child: Text(day, style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDayFilter = value;
                                    });
                                    _filterTimetables(_searchController.text);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: const Text('Department', style: TextStyle(fontSize: 14)),
                                  value: _selectedDepartmentFilter,
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All', style: TextStyle(fontSize: 14)),
                                    ),
                                    ..._departments.map((dept) {
                                      return DropdownMenuItem<String>(
                                        value: dept['id'],
                                        child: Text(
                                          dept['name'] ?? 'Unknown',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDepartmentFilter = value;
                                    });
                                    _filterTimetables(_searchController.text);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredTimetables.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isSearching ? 'No timetables found' : 'No timetables yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (!_isSearching) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add your first timetable to get started',
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
                                  onRefresh: _refreshTimetables,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                                    itemCount: _filteredTimetables.length,
                                    itemBuilder: (context, index) {
                                      final timetable = _filteredTimetables[index];
                                      return _TimetableCard(
                                        timetable: timetable,
                                        onTap: () => _showTimetableOptions(timetable),
                                        subjectColor: _getSubjectColor(timetable['subject'] ?? ''),
                                        subjectIcon: _getSubjectIcon(timetable['subject'] ?? ''),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),

                // Floating Action Button
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTimetablePage(),
                        ),
                      ).then((_) => _refreshTimetables());
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }
}

class _TimetableCard extends StatelessWidget {
  final Map<String, dynamic> timetable;
  final VoidCallback onTap;
  final Color subjectColor;
  final IconData subjectIcon;

  const _TimetableCard({
    required this.timetable,
    required this.onTap,
    required this.subjectColor,
    required this.subjectIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(subjectIcon, color: subjectColor, size: 28),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          timetable['subject'] ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          timetable['day'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timetable['teacher'] ?? 'No teacher',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${timetable['start_time'] ?? 'N/A'} - ${timetable['end_time'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.meeting_room, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        timetable['room'] ?? 'N/A',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}