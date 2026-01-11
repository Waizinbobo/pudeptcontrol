import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AddStaffformPage extends StatefulWidget {
  const AddStaffformPage({super.key});

  @override
  State<AddStaffformPage> createState() => _AddStaffformPageState();
}

class _AddStaffformPageState extends State<AddStaffformPage> {
  bool isActive = true;
  String? selectedDepartment;
  String? selectedRole;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController staffIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> departments = [
    "Computer Science",
    "Engineering",
    "Business School",
    "Arts & Humanities",
    "Medicine",
  ];

  final List<String> roles = [
    "Lecturer",
    "Senior Lecturer",
    "Professor",
    "Administrator",
    "Researcher",
  ];

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
        title: const Text(
          "Add Staff Member",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [

            const SizedBox(height: 24),
            Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  child: Icon(Icons.person, size: 56),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Upload Photo",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),

            _sectionTitle("Personal Details"),
            _textField("Full Name", nameController, Icons.person),
            _textField("Staff ID", staffIdController, Icons.badge),
            _divider(),

            _sectionTitle("Professional Info"),
            _dropdown("Department", departments, selectedDepartment, (val) {
              setState(() => selectedDepartment = val);
            }),
            _dropdown("Role", roles, selectedRole, (val) {
              setState(() => selectedRole = val);
            }),
            _divider(),

            _sectionTitle("Contact Details"),
            _textField("Email Address", emailController, Icons.email, TextInputType.emailAddress),
            _textField("Phone Number", phoneController, Icons.call, TextInputType.phone),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active Status", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Allow user to access the system", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text("Save Profile",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            try {
              await SupabaseService.addStaff(
                name: nameController.text,
                staffId: staffIdController.text,
                email: emailController.text,
                phone: phoneController.text,
                department: selectedDepartment ?? '',
                role: selectedRole ?? '',
                isActive: isActive,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Staff added successfully!')),
              );

              Navigator.pop(context, true); // return true to refresh list
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, IconData icon,
      [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Divider(),
    );
  }
}
