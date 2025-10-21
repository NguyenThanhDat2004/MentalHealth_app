import 'dart:io';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  final String initialName;
  final Function(String) onNameUpdated;
  final String? initialAvatarPath;
  final Function(String) onAvatarUpdated;

  const ProfileScreen({
    super.key,
    required this.initialName,
    required this.onNameUpdated,
    this.initialAvatarPath,
    required this.onAvatarUpdated,
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

  String? _currentAvatarPath;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: '+98 1245560090');
    _emailController = TextEditingController(text: 'amyyoung@random.com');
    _currentAvatarPath = widget.initialAvatarPath;

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showAvatarChangeOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GlassCard(
          margin: const EdgeInsets.all(10),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF5DB075)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Color(0xFF5DB075)),
                title: const Text('Use Image URL'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showImageUrlDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentAvatarPath = image.path;
      });
    }
  }

  Future<void> _showImageUrlDialog() async {
    final TextEditingController urlController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xffeaf2f2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Image URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: "https://..."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                      color: Color(0xFF5DB075), fontWeight: FontWeight.bold)),
              onPressed: () {
                if (urlController.text.isNotEmpty &&
                    (urlController.text.startsWith('http://') ||
                        urlController.text.startsWith('https://'))) {
                  setState(() {
                    _currentAvatarPath = urlController.text;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() {
    widget.onNameUpdated(_nameController.text);
    if (_currentAvatarPath != null) {
      widget.onAvatarUpdated(_currentAvatarPath!);
    }
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(localizations),
      body: Stack(
        children: [
          const LiquidBackground(),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    const SizedBox(height: 20),
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
    ImageProvider avatarImage;
    if (_currentAvatarPath != null) {
      if (_currentAvatarPath!.startsWith('http')) {
        avatarImage = NetworkImage(_currentAvatarPath!);
      } else {
        avatarImage = FileImage(File(_currentAvatarPath!));
      }
    } else {
      avatarImage = const NetworkImage(
          'https://eric.edu.vn/public/upload/2024/12/anh-gai-xinh-lop-10-09.webp');
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: avatarImage,
            backgroundColor: Colors.white,
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isEditing ? 1.0 : 0.0,
            child: _isEditing
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarChangeOptions,
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
        fillColor: Colors.white.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // ĐÃ SỬA: Bọc DropdownButtonFormField trong Material
  Widget _buildDropdownField({required String label}) {
    return Material(
      color: Colors.transparent,
      child: DropdownButtonFormField<String>(
        initialValue: "Some initial text",
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withAlpha(128),
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
      ),
    );
  }
}

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
