import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  final String initialName;
  final Function(String) onNameUpdated;

  const ProfileScreen({
    super.key,
    required this.initialName,
    required this.onNameUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedDepartment = 'Software Engineering';
  final List<String> _departments = [
    'Software Engineering',
    'Technology',
    'Human Resources',
    'Marketing',
    'Law',
    'Data Science',
    'Cybersecurity',
    'UI/UX Design',
    'Finance',
    'Accounting',
    'Sales',
    'Business Administration',
    'Graphic Design',
    'Content Writing',
    'Medicine',
    'Nursing',
    'Pharmacy',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Teaching',
    'Architecture',
    'Journalism',
    'Project Management',
    'Product Management',
    'Consulting',
    'Scientific Research'
  ];

  // Animation Controller cho hiệu ứng nền lỏng
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: '+98 1245560090');
    _emailController = TextEditingController(text: 'amyyoung@random.com');

    // Cấu hình animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _animationController.dispose(); // Hủy animation controller
    super.dispose();
  }

  void _saveProfile() {
    widget.onNameUpdated(_nameController.text);
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors
          .transparent, // Nền trong suốt để thấy background của MainScreen
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(localizations),
      body: Stack(
        children: [
          const LiquidBackground(),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            children: [
              const SizedBox(height: 120),
              GlassCard(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _isEditing
                          ? _buildEditForm(localizations)
                          : _buildInfoDisplay(localizations),
                    ),
                    const SizedBox(height: 0),
                    _buildLanguageSelector(localizations),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations localizations) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _isEditing
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => setState(() => _isEditing = false),
            )
          : null,
      title: AnimatedOpacity(
        opacity: _isEditing ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Text(
          localizations.editProfile,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _isEditing
              ? TextButton(
                  key: const ValueKey('saveButton'),
                  onPressed: _saveProfile,
                  child: Text(
                    localizations.save,
                    style: const TextStyle(
                        color: Color(0xFF5DB075),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : IconButton(
                  key: const ValueKey('editButton'),
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.black87, size: 28),
                  onPressed: () => setState(() => _isEditing = true),
                ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=12'),
            backgroundColor: Colors.white,
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isEditing ? 1.0 : 0.0,
            child: _isEditing
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5DB075),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDisplay(AppLocalizations localizations) {
    return Column(
      key: const ValueKey('infoDisplay'),
      children: [
        Text(_nameController.text,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 8),
        Text(_selectedDepartment,
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 20),
        const Divider(color: Colors.black12),
        _buildInfoTile(
          icon: Icons.phone_outlined,
          title: localizations.phoneNumber,
          subtitle: _phoneController.text,
        ),
        _buildInfoTile(
          icon: Icons.email_outlined,
          title: localizations.email,
          subtitle: _emailController.text,
        ),
      ],
    );
  }

  Widget _buildEditForm(AppLocalizations localizations) {
    return Column(
      key: const ValueKey('editForm'),
      children: [
        _buildTextField(label: localizations.name, controller: _nameController),
        const SizedBox(height: 20),
        _buildDropdownField(label: localizations.department),
        const SizedBox(height: 20),
        _buildTextField(
            label: localizations.phoneNumber, controller: _phoneController),
        const SizedBox(height: 20),
        _buildTextField(
            label: localizations.email, controller: _emailController),
      ],
    );
  }

  Widget _buildLanguageSelector(AppLocalizations localizations) {
    return _buildInfoTile(
      icon: Icons.language,
      title: localizations.language,
      subtitleWidget: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: Localizations.localeOf(context),
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: const [
            DropdownMenuItem(value: Locale('en'), child: Text('English')),
            DropdownMenuItem(value: Locale('vi'), child: Text('Tiếng Việt')),
            DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
          ],
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              MentalHealthApp.setLocale(context, newLocale);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 3),
              subtitleWidget ??
                  Text(
                    subtitle ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        // Đã sửa lỗi
        fillColor: Colors.white.withAlpha(128), // 0.5 opacity
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildDropdownField({required String label}) {
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        // Đã sửa lỗi
        fillColor: Colors.white.withAlpha(128), // 0.5 opacity
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: _departments.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedDepartment = newValue!;
        });
      },
    );
  }
}

// Class để tạo hình dạng cong cho background
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
