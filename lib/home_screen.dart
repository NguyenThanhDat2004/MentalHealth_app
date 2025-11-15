import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';

/// HomeScreen displays greeting, mood selection,
/// session info, quotes, and quick actions.
class HomeScreen extends StatefulWidget {
  final String userName;
  final String? avatarPath;

  const HomeScreen({super.key, required this.userName, this.avatarPath});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag to simulate whether the user’s plan is expired
  final bool _isPlanExpired = false;

  // Timer for updating clock
  late Timer _timer;

  // Current time, date, and greeting string
  String _currentTime = '';
  String _currentDate = '';
  String _greeting = '';

  // ĐÃ THÊM: Biến state để theo dõi tâm trạng được chọn
  int? _selectedMoodIndex;

  @override
  void initState() {
    super.initState();
    // Start a timer that updates every second
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update time immediately after widget is built
    _updateTime();
  }

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  /// Updates time, date, and greeting message based on current hour
  void _updateTime() {
    // ... (existing code, no changes)
    if (!mounted) return;
    final now = DateTime.now();
    final localizations = AppLocalizations.of(context);

    if (localizations != null) {
      final String formattedTime =
          DateFormat('hh:mm:ss a', localizations.localeName).format(now);
      final String formattedDate =
          DateFormat.yMMMMEEEEd(localizations.localeName).format(now);

      // Choose greeting based on time of day
      final hour = now.hour;
      String newGreeting;
      if (hour >= 5 && hour < 12) {
        newGreeting = localizations.goodMorning;
      } else if (hour >= 12 && hour < 14) {
        newGreeting = localizations.goodNoon;
      } else if (hour >= 14 && hour < 18) {
        newGreeting = localizations.goodAfternoon;
      } else {
        newGreeting = localizations.goodEvening;
      }

      setState(() {
        _currentTime = formattedTime;
        _currentDate = formattedDate;
        _greeting = newGreeting;
      });
    }
  }

  // ĐÃ THÊM: Hàm callback để cập nhật trạng thái
  void _onMoodSelected(int index) {
    setState(() {
      _selectedMoodIndex = index;
    });
    // Bạn có thể thêm logic khác ở đây, ví dụ: gửi dữ liệu
    // print('Selected mood index: $index');
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing code, no changes)
    final localizations = AppLocalizations.of(context)!;

    // Build UI components dynamically based on plan status
    List<Widget> children = [
      _isPlanExpired
          ? _buildSimpleHeader()
          : _buildGreetingHeader(localizations),
      const SizedBox(height: 25),
      if (!_isPlanExpired)
        GlassCard(
          margin: EdgeInsets.zero,
          child: Text(
            localizations.howAreYouFeeling,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      if (!_isPlanExpired) const SizedBox(height: 20),
      _isPlanExpired ? _buildIconMoodSelection() : _buildEmojiMoodSelection(),
      const SizedBox(height: 20),
      GlassCard(child: _buildSessionCard()),
      const SizedBox(height: 10),
      _buildActionButtons(),
      const SizedBox(height: 10),
      GlassCard(child: _buildQuoteCard()),
    ];

    return Stack(
      children: [
        const LiquidBackground(), // Animated liquid background
        AnimationLimiter(
          // Animate list items with staggered effect
          child: ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: children[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Greeting header with avatar, notifications, date & time
  Widget _buildGreetingHeader(AppLocalizations localizations) {
    // ... (existing code, no changes)
    // Use custom avatar if provided, otherwise default network image
    final ImageProvider avatarImage = widget.avatarPath != null
        ? (widget.avatarPath!.startsWith('http')
            ? NetworkImage(widget.avatarPath!)
            : FileImage(File(widget.avatarPath!))) as ImageProvider
        : const NetworkImage('https://i.pravatar.cc/150?img=32');

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & time with notification icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_currentDate,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  Text(_currentTime,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.notifications_none,
                      size: 30, color: Colors.grey),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: const Text('3',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          CircleAvatar(radius: 25, backgroundImage: avatarImage),
          const SizedBox(height: 10),
          Text(_greeting,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(localizations.userName(widget.userName),
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Session advertisement card
  Widget _buildSessionCard() {
    // ... (existing code, no changes)
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1 on 1 Sessions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Let\'s open up to the things that\nmatter the most',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            SizedBox(height: 15),
            Row(
              children: [
                Text('Book Now',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF2994A))),
                SizedBox(width: 5),
                Icon(Icons.calendar_today, size: 16, color: Color(0xFFF2994A)),
              ],
            ),
          ],
        ),
        Icon(Icons.people_alt, size: 50, color: Color(0xFFF2994A)),
      ],
    );
  }

  /// Motivational quote card
  Widget _buildQuoteCard() {
    // ... (existing code, no changes)
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '“It is better to conquer yourself than to win a thousand battles”',
            style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black54),
          ),
        ),
        SizedBox(width: 10),
        Text('”',
            style:
                TextStyle(fontSize: 60, color: Color(0xFFE5E5EE), height: 0.5)),
      ],
    );
  }

  /// Simple header for expired plan (minimal info)
  Widget _buildSimpleHeader() {
    // ... (existing code, no changes)
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
                  color: Colors.red.shade400, shape: BoxShape.circle),
              child: const Text('3',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  /// Mood selection with icons (when plan is expired)
  /// ĐÃ CẬP NHẬT: Trở nên động và tương tác
  Widget _buildIconMoodSelection() {
    final List<Map<String, dynamic>> moods = [
      {
        'icon': Icons.sentiment_very_satisfied,
        'text': 'Happy',
        'color': const Color(0xFFE84F8F)
      },
      {
        'icon': Icons.self_improvement,
        'text': 'Calm',
        'color': const Color(0xFF7C83FD)
      },
      {
        'icon': Icons.sync_problem,
        'text': 'Manic',
        'color': const Color(0xFF63D2D6)
      },
      {
        'icon': Icons.sentiment_very_dissatisfied,
        'text': 'Angry',
        'color': const Color(0xFFF39C12)
      },
      {
        'icon': Icons.sentiment_dissatisfied,
        'text': 'Sad',
        'color': Colors.green,
        // 'isPartial': true // <-- LỖI 2: Đã xóa dòng này
      },
    ];

    // ĐÃ THAY ĐỔI: Thay thế Row bằng SizedBox + ListView.builder
    return SizedBox(
      height: 100, // Thêm chiều cao cố định cho ListView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        padding:
            const EdgeInsets.symmetric(horizontal: 20), // Thêm padding cho list
        itemBuilder: (context, index) {
          final mood = moods[index];
          return Padding(
            padding: const EdgeInsets.only(
                right: 15), // Thêm khoảng cách giữa các item
            child: _IconMoodWidget(
              icon: mood['icon'],
              text: mood['text'],
              color: mood['color'],
              // isPartial: mood['isPartial'] ?? false, // <-- Đã xóa
              isSelected: _selectedMoodIndex == index,
              onTap: () => _onMoodSelected(index),
            ),
          );
        },
      ),
    );
  }

  /// Mood selection with emojis (default mode)
  /// ĐÃ CẬP NHẬT: Trở nên động và tương tác
  Widget _buildEmojiMoodSelection() {
    final List<Map<String, dynamic>> moods = [
      {'emoji': '😄', 'text': 'Happy', 'color': const Color(0xFFE84F8F)},
      {'emoji': '☯️', 'text': 'Calm', 'color': const Color(0xFF7C83FD)},
      {'emoji': '🌀', 'text': 'Manic', 'color': const Color(0xFF63D2D6)},
      {'emoji': '😠', 'text': 'Angry', 'color': const Color(0xFFF39C12)},
      {
        'emoji': '😔', 'text': 'Sad', 'color': Colors.green,
        // 'isPartial': true // <-- LỖI 2: Đã xóa dòng này
      },
    ];

    // ĐÃ THAY ĐỔI: Thay thế Row bằng SizedBox + ListView.builder
    return SizedBox(
      height: 110, // Thêm chiều cao cố định cho ListView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        padding:
            const EdgeInsets.symmetric(horizontal: 20), // Thêm padding cho list
        itemBuilder: (context, index) {
          final mood = moods[index];
          return Padding(
            padding: const EdgeInsets.only(
                right: 15), // Thêm khoảng cách giữa các item
            child: _EmojiMoodWidget(
              emoji: mood['emoji'],
              text: mood['text'],
              color: mood['color'],
              // isPartial: mood['isPartial'] ?? false, // <-- Đã xóa
              isSelected: _selectedMoodIndex == index,
              onTap: () => _onMoodSelected(index),
            ),
          );
        },
      ),
    );
  }

  /// Quick action buttons (Journal & Library)
  Widget _buildActionButtons() {
    // ... (existing code, no changes)
    return Row(
      children: [
        Expanded(child: _actionButton(Icons.menu_book, 'Journal')),
        const SizedBox(width: 20),
        Expanded(child: _actionButton(Icons.format_list_bulleted, 'Library')),
      ],
    );
  }

  /// Helper method to build an action button
  Widget _actionButton(IconData icon, String label) {
    // ... (existing code, no changes)
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black54),
      label: Text(label,
          style: const TextStyle(color: Colors.black54, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}

/// Emoji mood selection widget
/// ĐÃ CẬP NHẬT: Thêm isSelected và onTap
class _EmojiMoodWidget extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;
  // final bool isPartial; // <-- ĐÃ XÓA
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiMoodWidget({
    required this.emoji,
    required this.text,
    required this.color,
    // this.isPartial = false, // <-- ĐÃ XÓA
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
          // Thay đổi màu nền và thêm viền nếu được chọn
          color: isSelected ? color.withAlpha(80) : color.withAlpha(38),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: color, width: 2) : null),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

    // ĐÃ THAY ĐỔI: Logic được đơn giản hóa, xóa bỏ isPartial
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content, // Bọc 'content'
    );
  }
}

/// Icon mood selection widget
/// ĐÃ CẬP NHẬT: Thêm isSelected và onTap
class _IconMoodWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  // final bool isPartial; // <-- ĐÃ XÓA
  final bool isSelected;
  final VoidCallback onTap;

  const _IconMoodWidget({
    required this.icon,
    required this.text,
    required this.color,
    // this.isPartial = false, // <-- ĐÃ XÓA
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              // Thay đổi màu nền và thêm viền nếu được chọn
              color: isSelected ? color.withAlpha(80) : color.withAlpha(51),
              borderRadius: BorderRadius.circular(18),
              border: isSelected ? Border.all(color: color, width: 2) : null),
          child: Icon(icon, color: color, size: 35),
        ),

        // 1. ĐÃ SỬA: Thêm lại SizedBox
        const SizedBox(height: 8),

        // 2. ĐÃ SỬA: Thêm lại Text widget
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey)),
      ], // <-- 3. ĐÃ SỬA: Thêm dấu ']' bị thiếu để đóng 'children'
    );

    // ĐÃ THAY ĐỔI: Logic được đơn giản hóa, xóa bỏ isPartial
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content, // Bọc 'content'
    );
  }
}
