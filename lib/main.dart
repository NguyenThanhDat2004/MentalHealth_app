import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'sessions_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MentalHealthApp());
}

class MentalHealthApp extends StatelessWidget {
  const MentalHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mental Health App',
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _userName = 'Thanh Dat';

  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(userName: _userName),
      const SessionsScreen(),
      const CommunityScreen(),
      ProfileScreen(
        initialName: _userName,
        onNameUpdated: _updateUserName,
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    const itemCount = 4;
    final itemWidth = screenWidth / itemCount;
    const indicatorWidth = 40.0;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height:
            kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Thanh chỉ báo trượt mượt mà
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              top: 0,
              left: (_currentIndex * itemWidth) +
                  (itemWidth / 2) -
                  (indicatorWidth / 2),
              child: Container(
                width: indicatorWidth,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF5DB075),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Đã sửa: Thay thế BottomNavigationBar bằng Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.videocam_outlined, 1),
                _buildNavItem(Icons.chat_bubble_outline, 2),
                _buildNavItem(Icons.people_outline, 3),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget trợ giúp để tạo từng mục điều hướng
  Widget _buildNavItem(IconData icon, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque, // Đảm bảo toàn bộ khu vực có thể nhấn
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: _currentIndex == index
                ? const Color(0xFF5DB075)
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
