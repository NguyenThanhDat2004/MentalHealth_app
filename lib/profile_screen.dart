import 'package:flutter/material.dart';

// Đã gộp màn hình Edit Profile vào đây
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Biến trạng thái để quản lý chế độ xem/chỉnh sửa
  bool _isEditing = false;

  // Controllers để quản lý dữ liệu trong các ô nhập liệu
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // Biến cho dropdown
  String _selectedDepartment = 'Software Engineering';
  final List<String> _departments = [
    'Software Engineering',
    'Technology',
    'Human Resources',
    'Marketing',
    'Computer Engineering',
    'Business Administration',
    'Law',
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu ban đầu
    _nameController = TextEditingController(text: 'Nguyen Thanh Dat');
    _phoneController = TextEditingController(text: '+98 1245560090');
    _emailController = TextEditingController(text: 'amyyoung@random.com');
  }

  @override
  void dispose() {
    // Hủy các controller khi widget bị xóa
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Hàm để lưu thông tin
  void _saveProfile() {
    setState(() {
      // Chỉ cần thoát khỏi chế độ chỉnh sửa là đủ,
      // vì controllers đã giữ giá trị mới.
      _isEditing = false;
    });
    // Hiển thị thông báo đã lưu
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
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Phần nền cong
          ClipPath(
            clipper: BackgroundClipper(),
            child: Container(
              height: 265,
              color: const Color(0xFF5DB075).withAlpha(204),
            ),
          ),
          // Nội dung chính
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              const SizedBox(height: 150),
              // Avatar
              _buildAvatar(),
              const SizedBox(height: 50),
              // Các trường thông tin
              _isEditing
                  ? _buildEditForm() // Form chỉnh sửa
                  : _buildInfoDisplay(), // Giao diện hiển thị
            ],
          ),
        ],
      ),
    );
  }

  // Xây dựng AppBar tùy theo trạng thái
  AppBar _buildAppBar() {
    if (_isEditing) {
      return AppBar(
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => setState(() => _isEditing = true),
            ),
          ),
        ],
      );
    }
  }

  // Widget hiển thị Avatar
  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=33'),
            backgroundColor: Colors.white,
          ),
          if (_isEditing) // Chỉ hiển thị nút '+' khi ở chế độ edit
            Positioned(
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
            ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin (chế độ xem)
  Widget _buildInfoDisplay() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.person_outline,
          title: 'Name',
          subtitle: _nameController.text,
        ),
        _buildInfoTile(
          icon: Icons.business_center_outlined,
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

  // Widget hiển thị form (chế độ chỉnh sửa)
  Widget _buildEditForm() {
    return Column(
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
            padding: const EdgeInsets.symmetric(vertical: 15),
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

  // Widget cho từng dòng thông tin (chế độ xem)
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
          Icon(icon, size: 30, color: Colors.black54),
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

  // Widget cho trường nhập liệu (chế độ chỉnh sửa)
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

  // Widget cho trường dropdown (chế độ chỉnh sửa)
  Widget _buildDropdownField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
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

// Class để tạo hình dạng cong cho background
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.7,
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
