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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              _isEditing ? 'Edit Timetable' : 'Add Timetable',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule your classes',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            children: [
              _sectionCard(
                "Basic Information",
                Icons.info_outline,
                [
                  _field(_subjectController, "Subject", Icons.book),
                  _dropdown(
                    "Staff",
                    _selectedStaffId,
                    _staff.map((e) => e['id']).toList(),
                    (v) => setState(() => _selectedStaffId = v),
                    labels: _staff.map((e) => '${e['name']} - ${e['position']}').toList(),
                    isExpanded: true,
                  ),
                  _field(_roomController, "Room", Icons.meeting_room),
                  _dropdown(
                    "Semester",
                    _selectedSemester,
                    _semesters,
                    (v) => setState(() => _selectedSemester = v),
                    isExpanded: true,
                  ),
                ],
              ),
              _sectionCard(
                "Schedule Information",
                Icons.schedule,
                [
                  _dropdown(
                    "Day",
                    _selectedDay,
                    _days,
                    (v) => setState(() => _selectedDay = v),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _timeBox("Start Time", _startTime,
                          () => _pickTime(true)),
                      const SizedBox(width: 12),
                      _timeBox(
                          "End Time", _endTime, () => _pickTime(false)),
                    ],
                  ),
                ],
              ),
              _sectionCard(
                "Additional Information",
                Icons.layers_outlined,
                [
                  _dropdown(
                    "Department",
                    _selectedDepartmentId,
                    _departments.map((e) => e['id']).toList(),
                    (v) => setState(() => _selectedDepartmentId = v),
                    labels:
                        _departments.map((e) => e['name']).toList(),
                    isExpanded: true,
                  ),
                  _field(
                    _descriptionController,
                    "Description",
                    Icons.description,
                    maxLines: 3,
                    required: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTimetable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136DEC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing
                              ? 'Update Timetable'
                              : 'Create Timetable',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF136DEC)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    dynamic value,
    List items,
    Function(dynamic) onChanged, {
    List? labels,
    bool isExpanded = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        value: value,
        isExpanded: isExpanded,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: List.generate(items.length, (i) {
          return DropdownMenuItem(
            value: items[i],
            child: Text(
              labels != null ? labels[i] : items[i].toString(),
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
        onChanged: onChanged,
      ),
    );
  }

  Widget _timeBox(
      String title, TimeOfDay time, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                time.format(context),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
