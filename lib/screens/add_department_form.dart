import 'package:flutter/material.dart';

class AddDepartmentFormPage extends StatelessWidget {
  const AddDepartmentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101822) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDark ? const Color(0xFF101822) : const Color(0xFFF6F7F8),
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
          "Add Department",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const SizedBox(height: 24),

                /// Profile Image
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      child: Icon(
                        Icons.apartment,
                        size: 56,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF136DEC),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  "Upload Photo",
                  style: TextStyle(
                    color: Color(0xFF136DEC),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                /// Basic Info
                sectionTitle("Basic Info"),

                textField(
                  label: "Department Name",
                  hint: "e.g., Human Resources",
                ),

                textField(
                  label: "Department Code",
                  hint: "e.g., HR-001",
                  suffixIcon: Icons.tag,
                  uppercase: true,
                ),

                const SizedBox(height: 16),

                /// Details
                sectionTitle("Details"),

                textArea(
                  label: "Description",
                  hint:
                      "Enter a brief description of the department's responsibilities...",
                ),

                const SizedBox(height: 24),

                /// Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check, size: 24,color: Colors.white,),
                      label: const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
    required String label,
    required String hint,
    IconData? suffixIcon,
    bool uppercase = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            textCapitalization:
                uppercase ? TextCapitalization.characters : TextCapitalization.none,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon:
                  suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
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
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
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
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "0/250",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }
}
