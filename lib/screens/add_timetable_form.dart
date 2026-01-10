import 'package:flutter/material.dart';

class AddTimetablePage extends StatefulWidget {
  const AddTimetablePage({super.key});

  @override
  State<AddTimetablePage> createState() => _AddTimetablePageState();
}

class _AddTimetablePageState extends State<AddTimetablePage> {
  String? department;
  String? semester;
  String day = 'Mon';

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),

      /// AppBar
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
        title: const Text(
          "Schedule Class",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      /// Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Context
            _sectionTitle('Context'),

            _dropdown(
              label: 'Department',
              value: department,
              items: const [
                'Computer Science',
                'Engineering',
                'Business Administration',
                'Fine Arts',
              ],
              onChanged: (v) => setState(() => department = v),
            ),

            _dropdown(
              label: 'Semester',
              value: semester,
              items: const [
                'Fall 2024',
                'Spring 2025',
                'Summer 2025',
              ],
              onChanged: (v) => setState(() => semester = v),
            ),

            /// Day selector
            _daySelector(),

            const Divider(height: 32),

            /// Class Details
            _sectionTitle('Class Details'),

            _textField(
              label: 'Course Name or Code',
              hint: 'CS101 Introduction to Algorithms',
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _timePicker(
                    label: 'Start Time',
                    time: startTime,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timePicker(
                    label: 'End Time',
                    time: endTime,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _textField(
              label: 'Room Location',
              hint: 'Building A, Room 304',
              icon: Icons.location_on,
            ),

            _dropdown(
              label: 'Lecturer',
              value: null,
              items: const [
                'Dr. Alan Smith',
                'Prof. Jane Doe',
                'Dr. Kevin Lee',
              ],
              icon: Icons.person,
              onChanged: (_) {},
            ),
          ],
        ),
      ),

      /// Bottom Save Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF136DEC),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text(
            'Save Timetable Entry',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  /// ---------- Widgets ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required List<String> items,
    String? value,
    IconData? icon,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _daySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day of Week',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: days.map((d) {
            final selected = day == d;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => day = d),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF136DEC)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _timePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          controller: TextEditingController(text: time.format(context)),
        ),
      ),
    );
  }
}
