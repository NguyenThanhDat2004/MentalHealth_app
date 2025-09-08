import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'sessions_screen.dart';

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
  int _selectedIndex = 0;

  // Cập nhật danh sách các trang
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SessionsScreen(),
    CommunityScreen(),
    ProfileScreen(), // Thêm màn hình Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam, size: 30),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 30),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 30),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5DB075),
        unselectedItemColor: Colors.grey.shade400,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _isPlanExpired = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _isPlanExpired ? _buildSimpleHeader() : _buildGreetingHeader(),
            const SizedBox(height: 25),
            if (!_isPlanExpired)
              const Text(
                'How are you feeling today ?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (!_isPlanExpired) const SizedBox(height: 20),
            _isPlanExpired
                ? _buildIconMoodSelection()
                : _buildEmojiMoodSelection(),
            const SizedBox(height: 30),
            _buildSessionCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildQuoteCard(),
            const SizedBox(height: 20),
            _isPlanExpired
                ? _buildPlanExpiredCard()
                : _buildPlanExaminedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: 30,
                  color: Colors.grey,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Good Afternoon,',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const Text(
          'Thanh Dat!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiMoodSelection() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _EmojiMoodWidget(emoji: '😄', text: 'Happy', color: Color(0xFFE84F8F)),
        _EmojiMoodWidget(emoji: '☯️', text: 'Calm', color: Color(0xFF7C83FD)),
        _EmojiMoodWidget(emoji: '🌀', text: 'Manic', color: Color(0xFF63D2D6)),
        _EmojiMoodWidget(emoji: '😠', text: 'Angry', color: Color(0xFFF39C12)),
        _EmojiMoodWidget(
          emoji: '😔',
          text: 'Sad',
          color: Colors.green,
          isPartial: true,
        ),
      ],
    );
  }

  Widget _buildPlanExaminedButton() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF588f72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -60,
            bottom: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFF66a681),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Examined',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'You can examine your plan\nand book sessions',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Examine',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Icon(Icons.spa, size: 85, color: Color(0xFFa2c8af)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.notifications_none, size: 32, color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF9F9F9), width: 2),
              ),
              child: const Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconMoodSelection() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _IconMoodWidget(
          icon: Icons.sentiment_very_satisfied,
          text: 'Happy',
          color: Color(0xFFE84F8F),
        ),
        _IconMoodWidget(
          icon: Icons.self_improvement,
          text: 'Calm',
          color: Color(0xFF7C83FD),
        ),
        _IconMoodWidget(
          icon: Icons.sync_problem,
          text: 'Manic',
          color: Color(0xFF63D2D6),
        ),
        _IconMoodWidget(
          icon: Icons.sentiment_very_dissatisfied,
          text: 'Angry',
          color: Color(0xFFF39C12),
        ),
        _IconMoodWidget(
          icon: Icons.sentiment_dissatisfied,
          text: 'Sad',
          color: Colors.green,
          isPartial: true,
        ),
      ],
    );
  }

  Widget _buildPlanExpiredCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF588f72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -60,
            bottom: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFF66a681),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Expired',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Get back chat access and\nsession credits',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Buy More',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Icon(Icons.spa, size: 85, color: Color(0xFFa2c8af)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1 on 1 Sessions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Let\'s open up to the things that\nmatter the most',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2994A),
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFFF2994A),
                  ),
                ],
              ),
            ],
          ),
          Icon(
            Icons.people_alt,
            size: 50,
            color: const Color(0xFFF2994A).withAlpha(204),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _actionButton(Icons.menu_book, 'Journal')),
        const SizedBox(width: 20),
        Expanded(child: _actionButton(Icons.format_list_bulleted, 'Library')),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black54),
      label: Text(
        label,
        style: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '“It is better to conquer yourself than to win a thousand battles”',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            '”',
            style: TextStyle(
              fontSize: 60,
              color: Color(0xFFE5E5E5),
              height: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiMoodWidget extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;
  final bool isPartial;

  const _EmojiMoodWidget({
    required this.emoji,
    required this.text,
    required this.color,
    this.isPartial = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    if (isPartial) {
      return ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 0.5,
          child: content,
        ),
      );
    }
    return content;
  }
}

class _IconMoodWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isPartial;

  const _IconMoodWidget({
    required this.icon,
    required this.text,
    required this.color,
    this.isPartial = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color, size: 35),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
    if (isPartial) {
      return ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 0.5,
          child: content,
        ),
      );
    }
    return content;
  }
}
