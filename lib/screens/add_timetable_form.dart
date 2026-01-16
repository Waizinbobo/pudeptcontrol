import 'package:flutter/material.dart';
import '../services/timetable_service.dart';
import '../services/department_service.dart';
import '../services/staff_service.dart';

class AddTimetablePage extends StatefulWidget {
  final Map<String, dynamic>? timetable;

  const AddTimetablePage({super.key, this.timetable});

  @override
  State<AddTimetablePage> createState() => _AddTimetablePageState();
}

class _AddTimetablePageState extends State<AddTimetablePage> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();
  String? _selectedStaffId;
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _semesterController = TextEditingController();

  String? _selectedDepartmentId;
  String _selectedDay = 'Mon';
  String _selectedSemester = 'Semester - I';

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _semesters = [
    'Semester - I',
    'Semester - II',
    'Semester - III',
    'Semester - IV',
    'Semester - V',
    'Semester - VI',
    'Semester - VII',
    'Semester - VIII',
    'Semester - IX',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.timetable != null;
    _loadDepartments();
    if (_isEditing) _populateForm();
  }

  void _populateForm() {
    final t = widget.timetable!;
    _subjectController.text = t['subject'] ?? '';
    _teacherController.text = t['teacher'] ?? '';
    _roomController.text = t['room'] ?? '';
    _descriptionController.text = t['description'] ?? '';
    _selectedSemester = t['semester'] ?? 'Semester - I';
    _selectedStaffId = t['staff_id'] ?? '';
    _selectedDay = t['day'] ?? 'Mon';

    if (t['start_time'] != null) {
      final p = (t['start_time'] as String).split(':');
      _startTime = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }
    if (t['end_time'] != null) {
      final p = (t['end_time'] as String).split(':');
      _endTime = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }
  }

  Future<void> _loadDepartments() async {
    final data = await DepartmentService.getAllDepartments();
    final staffData = await StaffService.getAllStaff();
    setState(() {
      _departments = data;
      _staff = staffData;
    });
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() => start ? _startTime = picked : _endTime = picked);
    }
  }

  Future<void> _saveTimetable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        final success = await TimetableService.updateTimetable(
          id: widget.timetable!['id'],
          subject: _subjectController.text.trim(),
          teacher: _getStaffName(_selectedStaffId),
          day: _selectedDay,
          startTime: _startTime,
          endTime: _endTime,
          room: _roomController.text.trim(),
          departmentId: _selectedDepartmentId,
          description: _descriptionController.text.trim(),
          semester: _selectedSemester,
          staffId: _selectedStaffId,
        );
        if (success) Navigator.pop(context, true);
      } else {
        final res = await TimetableService.createTimetable(
          subject: _subjectController.text.trim(),
          teacher: _getStaffName(_selectedStaffId),
          day: _selectedDay,
          startTime: _startTime,
          endTime: _endTime,
          room: _roomController.text.trim(),
          departmentId: _selectedDepartmentId,
          description: _descriptionController.text.trim(),
          semester: _selectedSemester,
          staffId: _selectedStaffId,
        );
        if (res != null) Navigator.pop(context, true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStaffName(String? staffId) {
    if (staffId == null || staffId.isEmpty) return '';
    final staff = _staff.firstWhere((s) => s['id'] == staffId, orElse: () => {});
    return staff['name']?.toString() ?? '';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _descriptionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101822) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF101822) : const Color(0xFFF6F7F8),
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
                _isEditing ? 'Edit Timetable' : 'Add Timetable',
                style: const TextStyle(
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
                'Schedule your classes',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  /// Basic Information
                  _sectionTitle("Basic Information"),
                  
                  _field(
                    controller: _subjectController,
                    label: "Subject",
                    hint: "e.g., CS-301 - Data Structures",
                    icon: Icons.book,
                  ),
                  
                  _dropdown(
                    label: "Staff",
                    value: _selectedStaffId,
                    items: _staff.map((e) => e['id']).toList(),
                    onChanged: (v) => setState(() => _selectedStaffId = v),
                    labels: _staff.map((e) => '${e['name']} - ${e['position']}').toList(),
                    icon: Icons.person,
                  ),
                  
                  _field(
                    controller: _roomController,
                    label: "Room",
                    hint: "e.g., Hall A, Lab 3",
                    icon: Icons.meeting_room,
                  ),
                  
                  _dropdown(
                    label: "Semester",
                    value: _selectedSemester,
                    items: _semesters,
                    onChanged: (v) => setState(() => _selectedSemester = v),
                    icon: Icons.school,
                  ),

                  const SizedBox(height: 16),

                  /// Schedule Information
                  _sectionTitle("Schedule Information"),
                  
                  _dropdown(
                    label: "Day",
                    value: _selectedDay,
                    items: _days,
                    onChanged: (v) => setState(() => _selectedDay = v),
                    icon: Icons.calendar_today,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _timeBox(
                          "Start Time",
                          _startTime,
                          () => _pickTime(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeBox(
                          "End Time",
                          _endTime,
                          () => _pickTime(false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Additional Information
                  _sectionTitle("Additional Information"),
                  
                  _dropdown(
                    label: "Department",
                    value: _selectedDepartmentId,
                    items: _departments.map((e) => e['id']).toList(),
                    onChanged: (v) => setState(() => _selectedDepartmentId = v),
                    labels: _departments.map((e) => e['name']).toList(),
                    icon: Icons.apartment,
                  ),
                  
                  _textArea(
                    controller: _descriptionController,
                    label: "Description",
                    hint: "Enter additional notes or description...",
                  ),

                  const SizedBox(height: 24),

                  /// Save Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveTimetable,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check, size: 24, color: Colors.white),
                        label: Text(
                          _isLoading
                              ? 'Saving...'
                              : (_isEditing ? 'Update Timetable' : 'Save Changes'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF136DEC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: required
                ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCFD9E7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF136DEC), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textArea({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCFD9E7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF136DEC), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "0/250",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required dynamic value,
    required List items,
    required Function(dynamic) onChanged,
    required IconData icon,
    List? labels,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCFD9E7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF136DEC), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: List.generate(items.length, (i) {
              return DropdownMenuItem(
                value: items[i],
                child: Text(labels != null ? labels[i] : items[i].toString()),
              );
            }),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String title, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCFD9E7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
