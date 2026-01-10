import 'package:flutter/material.dart';
import 'add_timetable_form.dart';
import '../widgets/bottom_navigation.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _timetables = [
    {
      'day': 'Today, Mon 24',
      'items': [
        {
          'subject': 'CS101 - Intro to Programming',
          'teacher': 'Dr. Alan Turing',
          'time': '09:00 AM - 11:00 AM',
          'room': 'Hall A',
          'icon': Icons.code,
          'color': Colors.blue,
        },
        {
          'subject': 'CS202 - Data Structures',
          'teacher': 'Dr. Grace Hopper',
          'time': '11:30 AM - 01:30 PM',
          'room': 'Lab 3',
          'icon': Icons.storage,
          'color': Colors.purple,
          'live': true,
        },
      ],
    },
    {
      'day': 'Tomorrow, Tue 25',
      'items': [
        {
          'subject': 'PHY101 - Physics I',
          'teacher': 'Dr. Albert Einstein',
          'time': '09:00 AM - 11:00 AM',
          'room': 'Lab 1',
          'icon': Icons.science,
          'color': Colors.green,
        },
      ],
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
                'Daily class schedules',
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
                    /// Search
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
                            hintText: 'Search timetable...',
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _timetables.map((section) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionHeader(section['day']),
                                const SizedBox(height: 12),
                                ...section['items'].map<Widget>((item) {
                                  return _TimetableCard(
                                    subject: item['subject'],
                                    teacher: item['teacher'],
                                    time: item['time'],
                                    room: item['room'],
                                    icon: item['icon'],
                                    color: item['color'],
                                    live: item['live'] ?? false,
                                  );
                                }).toList(),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                /// FAB
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Action for adding a new timetable
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTimetablePage(),
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// ================= Card Widget =================

class _TimetableCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;
  final String room;
  final IconData icon;
  final Color color;
  final bool live;

  const _TimetableCard({
    required this.subject,
    required this.teacher,
    required this.time,
    required this.room,
    required this.icon,
    required this.color,
    this.live = false,
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
            child: Icon(icon, color: color, size: 28),
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
                        subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (live)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "LIVE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  teacher,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.meeting_room,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(room, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
