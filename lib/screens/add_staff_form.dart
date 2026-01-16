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

    // Validate position selection
    if (_positionController.text.trim().isEmpty) {
      _showErrorMessage('Please select a position');
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
        title: Text(
          _isEditing ? "Edit Staff Member" : "Add Staff Member",
          style: const TextStyle(fontWeight: FontWeight.bold),
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

                  /// Basic Info
                  sectionTitle("Personal Information"),

                  textField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "e.g., John Doe",
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                  ),

                  textField(
                    controller: _emailController,
                    label: "Email Address",
                    hint: "e.g., john@example.com",
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  textField(
                    controller: _phoneController,
                    label: "Phone Number",
                    hint: "e.g., +1234567890",
                    icon: Icons.phone,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(value.trim())) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Professional Info
                  sectionTitle("Professional Information"),

                  // Position Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Position/Role', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text('Select Position'),
                              value: _positionController.text.isNotEmpty ? _positionController.text : null,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem<String>(
                                  value: 'Professor',
                                  child: Text('Professor'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Associate Professor',
                                  child: Text('Associate Professor'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Lecturer',
                                  child: Text('Lecturer'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Assistant Lecturer',
                                  child: Text('Assistant Lecturer'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Tutor',
                                  child: Text('Tutor'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Researcher',
                                  child: Text('Researcher'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _positionController.text = value ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Department Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Department', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text('Select Department'),
                              value: _selectedDepartmentId,
                              isExpanded: true,
                              items: _departments.map((dept) {
                                return DropdownMenuItem<String>(
                                  value: dept['id'],
                                  child: Text(dept['name'] ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartmentId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hire Date Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hire Date', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedHireDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedHireDate = date;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedHireDate != null
                                      ? '${_selectedHireDate!.day}/${_selectedHireDate!.month}/${_selectedHireDate!.year}'
                                      : 'Select Hire Date',
                                  style: TextStyle(
                                    color: _selectedHireDate != null ? Colors.black : Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  textField(
                    controller: _salaryController,
                    label: "Salary (Optional)",
                    hint: "e.g., 50000.00",
                    icon: Icons.attach_money,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final salary = double.tryParse(value.trim());
                        if (salary == null || salary < 0) {
                          return 'Please enter a valid salary amount';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  /// Save Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveStaff,
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
                          _isLoading ? 'Saving...' : (_isEditing ? "Update Staff" : "Add Staff"),
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

  /// Section Title
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// TextField
  Widget textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF136DEC)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
