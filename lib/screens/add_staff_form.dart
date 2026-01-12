import 'package:flutter/material.dart';
import '../services/staff_service.dart';
import '../services/department_service.dart';

class AddStaffformPage extends StatefulWidget {
  final Map<String, dynamic>? staff; // For editing existing staff
  
  const AddStaffformPage({super.key, this.staff});

  @override
  State<AddStaffformPage> createState() => _AddStaffformPageState();
}

class _AddStaffformPageState extends State<AddStaffformPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  
  String? _selectedDepartmentId;
  DateTime? _selectedHireDate;
  bool _isLoading = false;
  bool _isEditing = false;
  
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.staff != null;
    _loadDepartments();
    
    if (_isEditing) {
      // Populate form with existing data
      _nameController.text = widget.staff!['name'] ?? '';
      _emailController.text = widget.staff!['email'] ?? '';
      _phoneController.text = widget.staff!['phone'] ?? '';
      _positionController.text = widget.staff!['position'] ?? '';
      _salaryController.text = widget.staff!['salary']?.toString() ?? '';
      _selectedDepartmentId = widget.staff!['department_id'];
      
      if (widget.staff!['hire_date'] != null) {
        _selectedHireDate = DateTime.parse(widget.staff!['hire_date']);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await DepartmentService.getAllDepartments();
      setState(() {
        _departments = departments;
      });
    } catch (e) {
      print('Error loading departments: $e');
    }
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final salary = _salaryController.text.isNotEmpty 
          ? double.tryParse(_salaryController.text) 
          : null;

      if (_isEditing) {
        // Update existing staff
        final success = await StaffService.updateStaff(
          id: widget.staff!['id'],
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          position: _positionController.text.trim(),
          departmentId: _selectedDepartmentId,
          hireDate: _selectedHireDate,
          salary: salary,
        );

        if (success) {
          _showSuccessMessage('Staff updated successfully!');
          Navigator.pop(context, true);
        } else {
          _showErrorMessage('Failed to update staff');
        }
      } else {
        // Check if email already exists
        final emailExists = await StaffService.staffEmailExists(_emailController.text.trim());
        if (emailExists) {
          _showErrorMessage('Email already exists');
          setState(() => _isLoading = false);
          return;
        }

        // Create new staff
        final staff = await StaffService.createStaff(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          position: _positionController.text.trim(),
          departmentId: _selectedDepartmentId,
          hireDate: _selectedHireDate,
          salary: salary,
        );

        if (staff != null) {
          _showSuccessMessage('Staff created successfully!');
          Navigator.pop(context, true);
        } else {
          _showErrorMessage('Failed to create staff');
        }
      }
    } catch (e) {
      _showErrorMessage('An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
