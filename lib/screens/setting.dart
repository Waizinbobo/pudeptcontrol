import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../services/supabase_service.dart';
import 'login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  bool darkMode = false;
  bool notifications = true;
  bool twoFactor = false;
  bool biometric = false;
  bool autoSync = true;
  double fontSize = 14.0;
  
  late AnimationController _profileAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _profileAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _profileAnimation = CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _profileAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _profileAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      
      /// MODERN APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // leading: Container(
        //   margin: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.05),
        //         blurRadius: 10,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        //     onPressed: () => Navigator.pop(context),
        //   ),
        // ),
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade600),
              onPressed: () {},
            ),
          ),
        ],
      ),

      /// BODY
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ENHANCED PROFILE SECTION
            AnimatedBuilder(
              animation: _profileAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _profileAnimation.value,
                  child: Opacity(
                    opacity: _profileAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF667EEA),
                            const Color(0xFF764BA2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Color(0xFF667EEA),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dr. Alex Smith',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Computer Science Dept.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Faculty Member',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            /// QUICK STATS
            AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                  child: Opacity(
                    opacity: _cardAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '12',
                              'Courses',
                              Icons.book,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              '248',
                              'Students',
                              Icons.people,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              '4.8',
                              'Rating',
                              Icons.star,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            /// ACCOUNT SECTION
            _buildSection(
              'ACCOUNT',
              [
                _buildModernTile(
                  Icons.person_outline,
                  'Personal Information',
                  'Manage your personal details',
                  Colors.blue,
                  () {},
                ),
                _buildModernTile(
                  Icons.school_outlined,
                  'Department Details',
                  'View department information',
                  Colors.purple,
                  () {},
                ),
              ],
            ),

            /// PREFERENCES SECTION
            _buildSection(
              'PREFERENCES',
              [
                _buildSwitchTile(
                  Icons.dark_mode_outlined,
                  'Dark Mode',
                  'Enable dark theme',
                  darkMode,
                  (v) => setState(() => darkMode = v),
                  Colors.indigo,
                ),
                _buildSwitchTile(
                  Icons.notifications_outlined,
                  'Push Notifications',
                  'Receive important updates',
                  notifications,
                  (v) => setState(() => notifications = v),
                  Colors.red,
                ),
                _buildSliderTile(
                  Icons.text_fields,
                  'Font Size',
                  'Adjust text size',
                  fontSize,
                  (v) => setState(() => fontSize = v),
                  Colors.teal,
                ),
              ],
            ),

            /// SECURITY SECTION
            _buildSection(
              'SECURITY',
              [
                _buildModernTile(
                  Icons.lock_outline,
                  'Change Password',
                  'Update your password',
                  Colors.orange,
                  () {},
                ),
                _buildSwitchTile(
                  Icons.security_outlined,
                  'Two-Factor Auth',
                  'Extra security layer',
                  twoFactor,
                  (v) => setState(() => twoFactor = v),
                  Colors.green,
                ),
                _buildSwitchTile(
                  Icons.fingerprint_outlined,
                  'Biometric Login',
                  'Use fingerprint or face',
                  biometric,
                  (v) => setState(() => biometric = v),
                  Colors.purple,
                ),
              ],
            ),

            /// DATA & STORAGE
            _buildSection(
              'DATA & STORAGE',
              [
                _buildSwitchTile(
                  Icons.sync_outlined,
                  'Auto Sync',
                  'Sync data automatically',
                  autoSync,
                  (v) => setState(() => autoSync = v),
                  Colors.cyan,
                ),
                _buildModernTile(
                  Icons.storage_outlined,
                  'Storage Management',
                  '2.3 GB used of 5 GB',
                  Colors.grey,
                  () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await SupabaseService.logout();

                    if (!mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const DepartmentLoginPage()),
                      (_) => false,
                    );
                  },


                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'Version 2.0.1',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 4),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildModernTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.shade600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          activeTrackColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    IconData icon,
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 10.0,
              max: 20.0,
              divisions: 10,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
