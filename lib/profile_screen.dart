import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  // Thêm các biến để nhận dữ liệu và callback
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

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedDepartment = 'Human Resources';
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
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu được truyền vào
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: '+98 1245560090');
    _emailController = TextEditingController(text: 'amyyoung@random.com');
  }

  // Cập nhật controller nếu widget được rebuild với dữ liệu mới
  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialName != oldWidget.initialName) {
      _nameController.text = widget.initialName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // Gọi callback để gửi tên mới lên cho MainScreen
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isEditing ? _buildEditAppBar() : _buildViewAppBar(),
        ),
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: BackgroundClipper(),
            child: Container(
              height: 300,
              color: const Color(0xFF5DB075).withAlpha(204),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              const SizedBox(height: 220),
              _buildAvatar(),
              const SizedBox(height: 50),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
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
                    ? _buildEditForm(key: const ValueKey('editForm'))
                    : _buildInfoDisplay(key: const ValueKey('infoDisplay')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildViewAppBar() {
    return AppBar(
      key: const ValueKey('viewAppBar'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon:
                const Icon(Icons.edit_outlined, color: Colors.white, size: 30),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ),
      ],
    );
  }

  AppBar _buildEditAppBar() {
    return AppBar(
      key: const ValueKey('editAppBar'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => setState(() => _isEditing = false),
      ),
      title: const Row(
        children: [
          Icon(Icons.edit_outlined, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
                'https://eric.edu.vn/public/upload/2024/12/anh-gai-xinh-lop-10-09.webp'),
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
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDisplay({Key? key}) {
    return Column(
      key: key,
      children: [
        _buildInfoTile(
          icon: Icons.person_outline,
          title: 'Name',
          subtitle: _nameController.text,
        ),
        _buildInfoTile(
          icon: Icons.work_outline,
          title: 'Department',
          subtitle: _selectedDepartment,
        ),
        _buildInfoTile(
          icon: Icons.phone_outlined,
          title: 'Phone no.',
          subtitle: _phoneController.text,
        ),
        _buildInfoTile(
          icon: Icons.email_outlined,
          title: 'E-Mail',
          subtitle: _emailController.text,
        ),
      ],
    );
  }

  Widget _buildEditForm({Key? key}) {
    return Column(
      key: key,
      children: [
        _buildTextField(label: 'Name', controller: _nameController),
        const SizedBox(height: 20),
        _buildDropdownField(label: 'Department'),
        const SizedBox(height: 20),
        _buildTextField(label: 'Phone no.', controller: _phoneController),
        const SizedBox(height: 20),
        _buildTextField(label: 'E-Mail', controller: _emailController),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5DB075),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.grey.shade600),
          const SizedBox(width: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDepartment,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
          ),
        ),
      ],
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
