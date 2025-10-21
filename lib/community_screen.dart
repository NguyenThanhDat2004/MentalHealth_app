import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'l10n/app_localizations.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';
import 'ai_chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  final String? avatarPath;
  const CommunityScreen({super.key, this.avatarPath});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedChipIndex = 0; // Keeps track of selected filter chip
  Offset? _fabPosition; // Floating action button position

  // Dummy post data
  final List<Map<String, dynamic>> _posts = [
    {
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
      'name': 'Coal Dingo',
      'time': 'just now',
      'content':
          'Is there a therapy which can cure crossdressing & bdsm compulsion?',
      'likes': 2,
      'comments': 0,
    },
    {
      'avatarUrl': 'https://i.pravatar.cc/150?img=6',
      'name': 'Pigeon Car',
      'time': '3 hrs ago',
      'content':
          'Is there a therapy which can cure crossdressing & bdsm compulsion?',
      'likes': 12,
      'comments': 2,
    },
    {
      'avatarUrl':
          'https://i.pinimg.com/474x/87/63/1f/87631fc7ae2f77de122e268b64b3baf3.jpg',
      'name': 'Jennyfer Aniston',
      'time': '2 hrs ago',
      'content':
          'Is there a therapy which can cure crossdressing & bdsm compulsion?',
      'likes': 100,
      'comments': 9,
    },
  ];

  @override
  void initState() {
    super.initState();
    // After the first frame, calculate the default FAB position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        final padding = MediaQuery.of(context).padding;
        setState(() {
          _fabPosition = Offset(
            size.width - 80, // Position on the right side
            size.height -
                padding.top -
                padding.bottom -
                150, // Above bottom nav
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Filter chip labels from localization
    final List<String> chipLabels = [
      localizations.trending,
      localizations.relationship,
      localizations.selfCare,
      localizations.mentalHealth
    ];

    // Floating action button that navigates to AI Chat screen
    final fabWidget = FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiChatScreen()),
        );
      },
      backgroundColor: Colors.white,
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Padding inside FAB
        child: Image.asset('assets/images/bot.png'), // Bot image
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Liquid animation background
          const LiquidBackground(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar + notifications
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: _buildHeader(),
              ),
              const SizedBox(height: 10),
              // Section title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  localizations.wellnessHub,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              // Filter chips
              _buildFilterChips(chipLabels),
              const SizedBox(height: 10),
              // Post list with animations
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: GlassCard(
                              child: _buildPostCard(
                                avatarUrl: post['avatarUrl'],
                                name: post['name'],
                                time: post['time'],
                                content: post['content'],
                                likes: post['likes'],
                                comments: post['comments'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Draggable floating action button
          if (_fabPosition != null)
            Positioned(
              left: _fabPosition!.dx,
              top: _fabPosition!.dy,
              child: Draggable(
                feedback: Material(color: Colors.transparent, child: fabWidget),
                childWhenDragging: const SizedBox.shrink(),
                onDragEnd: (details) {
                  final size = MediaQuery.of(context).size;
                  final padding = MediaQuery.of(context).padding;
                  const fabSize = 56.0;

                  // Constrain FAB within screen bounds
                  setState(() {
                    _fabPosition = Offset(
                      details.offset.dx.clamp(0.0, size.width - fabSize),
                      details.offset.dy.clamp(
                          padding.top,
                          size.height -
                              padding.bottom -
                              fabSize -
                              kBottomNavigationBarHeight -
                              20),
                    );
                  });
                },
                child: fabWidget,
              ),
            ),
        ],
      ),
    );
  }

  // Builds header with avatar and notification icon
  Widget _buildHeader() {
    final ImageProvider avatarImage = widget.avatarPath != null
        ? (widget.avatarPath!.startsWith('http')
            ? NetworkImage(widget.avatarPath!)
            : FileImage(File(widget.avatarPath!))) as ImageProvider
        : const NetworkImage('https://i.pravatar.cc/150?img=32');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(radius: 25, backgroundImage: avatarImage),
        Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.notifications_none, size: 30, color: Colors.grey),
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
    );
  }

  // Builds horizontal filter chips
  Widget _buildFilterChips(List<String> chipLabels) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chipLabels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(chipLabels[index]),
              selected: _selectedChipIndex == index,
              onSelected: (bool selected) {
                setState(() {
                  _selectedChipIndex = selected ? index : -1;
                });
              },
              backgroundColor: Colors.white.withAlpha(128),
              selectedColor: const Color(0xFF5DB075),
              labelStyle: TextStyle(
                  color: _selectedChipIndex == index
                      ? Colors.white
                      : Colors.black54,
                  fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withAlpha(204)),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          );
        },
      ),
    );
  }

  // Builds a post card widget
  Widget _buildPostCard({
    required String avatarUrl,
    required String name,
    required String time,
    required String content,
    required int likes,
    required int comments,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info row
        Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('  •  ', style: TextStyle(color: Colors.grey)),
            Text(time, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 15),
        // Post content
        Text(content, style: const TextStyle(fontSize: 16, height: 1.4)),
        const SizedBox(height: 15),
        // Like, comment, share row
        Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined,
                color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 5),
            Text('$likes', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(width: 20),
            Icon(Icons.chat_bubble_outline,
                color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 5),
            Text('$comments', style: TextStyle(color: Colors.grey.shade600)),
            const Spacer(),
            Icon(Icons.share_outlined, color: Colors.grey.shade600, size: 20),
          ],
        )
      ],
    );
  }
}
