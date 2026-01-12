import 'package:flutter/material.dart';
import '../services/department_service.dart';

class AddDepartmentFormPage extends StatefulWidget {
  final Map<String, dynamic>? department; // For editing existing department
  
  const AddDepartmentFormPage({super.key, this.department});

  @override
  State<AddDepartmentFormPage> createState() => _AddDepartmentFormPageState();
}

class _AddDepartmentFormPageState extends State<AddDepartmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _headNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.department != null;
    
    if (_isEditing) {
      // Populate form with existing data
      _nameController.text = widget.department!['name'] ?? '';
      _codeController.text = widget.department!['code'] ?? '';
      _descriptionController.text = widget.department!['description'] ?? '';
      _headNameController.text = widget.department!['head_name'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _headNameController.dispose();
    super.dispose();
  }

  Future<void> _saveDepartment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Update existing department
        final success = await DepartmentService.updateDepartment(
          id: widget.department!['id'],
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          description: _descriptionController.text.trim(),
          headName: _headNameController.text.trim(),
        );

        if (success) {
          _showSuccessMessage('Department updated successfully!');
          Navigator.pop(context, true);
        } else {
          _showErrorMessage('Failed to update department');
        }
      } else {
        // Check if department code already exists
        final codeExists = await DepartmentService.departmentCodeExists(_codeController.text.trim());
        if (codeExists) {
          _showErrorMessage('Department code already exists');
          setState(() => _isLoading = false);
          return;
        }

        // Check if department name already exists
        final nameExists = await DepartmentService.departmentNameExists(_nameController.text.trim());
        if (nameExists) {
          _showErrorMessage('Department name already exists');
          setState(() => _isLoading = false);
          return;
        }

        // Create new department
        final department = await DepartmentService.createDepartment(
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          description: _descriptionController.text.trim(),
          headName: _headNameController.text.trim(),
        );

        if (department != null) {
          _showSuccessMessage('Department created successfully!');
          Navigator.pop(context, true);
        } else {
          _showErrorMessage('Failed to create department');
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
        title: Text(
          _isEditing ? "Edit Department" : "Add Department",
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
                  sectionTitle("Basic Info"),

                  textField(
                    controller: _nameController,
                    label: "Department Name",
                    hint: "e.g., Human Resources",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter department name';
                      }
                      return null;
                    },
                  ),

                  textField(
                    controller: _codeController,
                    label: "Department Code",
                    hint: "e.g., HR-001",
                    suffixIcon: Icons.tag,
                    uppercase: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter department code';
                      }
                      if (value.trim().length < 3) {
                        return 'Code must be at least 3 characters';
                      }
                      return null;
                    },
                  ),

                  textField(
                    controller: _headNameController,
                    label: "Department Head",
                    hint: "e.g., John Doe",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter department head name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Details
                  sectionTitle("Details"),

                  textArea(
                    controller: _descriptionController,
                    label: "Description",
                    hint: "Enter a brief description of the department's responsibilities...",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter department description';
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
                        onPressed: _isLoading ? null : _saveDepartment,
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
                          _isLoading ? 'Saving...' : (_isEditing ? "Update Department" : "Save Changes"),
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
    IconData? suffixIcon,
    bool uppercase = false,
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
            textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
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

  /// TextArea
  Widget textArea({
    required TextEditingController controller,
    required String label,
    required String hint,
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
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF136DEC)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${controller.text.length}/250",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }
}
