import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'l10n/app_localizations.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';

/// HomeScreen displays the main dashboard UI for the user.
class HomeScreen extends StatefulWidget {
  final String userName; // Username passed from parent widget
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag to simulate whether the subscription/plan is expired
  final bool _isPlanExpired = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Build a list of widgets that compose the home screen content
    List<Widget> children = [
      _isPlanExpired
          ? _buildSimpleHeader()
          : _buildGreetingHeader(localizations),
      const SizedBox(height: 25),
      if (!_isPlanExpired)
        GlassCard(
          margin: const EdgeInsets.symmetric(vertical: 0),
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
          // Animate each child in the list view
          child: ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: children[index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Header with greeting, avatar, and notification icon
  Widget _buildGreetingHeader(AppLocalizations localizations) {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with avatar + notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=32'),
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
          // Greeting texts
          Text(
            localizations.goodAfternoon,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333)),
          ),
          Text(
            localizations.userName(widget.userName),
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }

  /// Session booking card with description and button
  Widget _buildSessionCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
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
        // Icon aligned to the right
        Icon(Icons.people_alt,
            size: 50, color: const Color(0xFFF2994A).withAlpha(204)),
      ],
    );
  }

  /// Motivational quote card
  Widget _buildQuoteCard() {
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
                TextStyle(fontSize: 60, color: Color(0xFFE5E5E5), height: 0.5)),
      ],
    );
  }

  /// Simpler header when plan is expired
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
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Mood selection with icons (used when plan expired)
  Widget _buildIconMoodSelection() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _IconMoodWidget(
            icon: Icons.sentiment_very_satisfied,
            text: 'Happy',
            color: Color(0xFFE84F8F)),
        _IconMoodWidget(
            icon: Icons.self_improvement,
            text: 'Calm',
            color: Color(0xFF7C83FD)),
        _IconMoodWidget(
            icon: Icons.sync_problem, text: 'Manic', color: Color(0xFF63D2D6)),
        _IconMoodWidget(
            icon: Icons.sentiment_very_dissatisfied,
            text: 'Angry',
            color: Color(0xFFF39C12)),
        _IconMoodWidget(
            icon: Icons.sentiment_dissatisfied,
            text: 'Sad',
            color: Colors.green,
            isPartial: true),
      ],
    );
  }

  /// Mood selection with emojis (default)
  Widget _buildEmojiMoodSelection() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _EmojiMoodWidget(emoji: '😄', text: 'Happy', color: Color(0xFFE84F8F)),
        _EmojiMoodWidget(emoji: '☯️', text: 'Calm', color: Color(0xFF7C83FD)),
        _EmojiMoodWidget(emoji: '🌀', text: 'Manic', color: Color(0xFF63D2D6)),
        _EmojiMoodWidget(emoji: '😠', text: 'Angry', color: Color(0xFFF39C12)),
        _EmojiMoodWidget(
            emoji: '😔', text: 'Sad', color: Colors.green, isPartial: true),
      ],
    );
  }

  /// Action buttons row (Journal, Library)
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _actionButton(Icons.menu_book, 'Journal')),
        const SizedBox(width: 20),
        Expanded(child: _actionButton(Icons.format_list_bulleted, 'Library')),
      ],
    );
  }

  /// Single action button builder
  Widget _actionButton(IconData icon, String label) {
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

/// Emoji-based mood widget (used when plan is active)
class _EmojiMoodWidget extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;
  final bool isPartial;

  const _EmojiMoodWidget(
      {required this.emoji,
      required this.text,
      required this.color,
      this.isPartial = false});

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
          color: color.withAlpha(38), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    // Show only half if isPartial is true
    if (isPartial) {
      return ClipRect(
          child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: content));
    }
    return content;
  }
}

/// Icon-based mood widget (used when plan is expired)
class _IconMoodWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isPartial;

  const _IconMoodWidget(
      {required this.icon,
      required this.text,
      required this.color,
      this.isPartial = false});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, color: color, size: 35),
        ),
        const SizedBox(height: 8),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
    // Show only half if isPartial is true
    if (isPartial) {
      return ClipRect(
          child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: content));
    }
    return content;
  }
}
