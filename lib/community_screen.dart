import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'l10n/app_localizations.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedChipIndex = 0;

  final List<Map<String, dynamic>> _posts = [
    {
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
      'name': 'Coal Dingo',
      'time': 'just now',
      'content':
          'Is there a therapy which can cure crossdressing & bdsm compulsion?',
      'likes': 2,
      'comments': 0
    },
    {
      'avatarUrl': 'https://i.pravatar.cc/150?img=6',
      'name': 'Pigeon Car',
      'time': '3 hrs ago',
      'content':
          'Is there a therapy which can cure crossdressing & bdsm compulsion?',
      'likes': 12,
      'comments': 2
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final List<String> chipLabels = [
      localizations.trending,
      localizations.relationship,
      localizations.selfCare,
      localizations.mentalHealth
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const LiquidBackground(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: _buildHeader(),
              ),
              const SizedBox(height: 10),
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
              _buildFilterChips(chipLabels),
              const SizedBox(height: 10),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF5DB075),
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32')),
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
              // Đã sửa lỗi
              backgroundColor: Colors.white.withAlpha(128), // 0.5 opacity
              selectedColor: const Color(0xFF5DB075),
              labelStyle: TextStyle(
                  color: _selectedChipIndex == index
                      ? Colors.white
                      : Colors.black54,
                  fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Đã sửa lỗi
                  side: BorderSide(
                      color: Colors.white.withAlpha(204))), // 0.8 opacity
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          );
        },
      ),
    );
  }

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
        Text(content, style: const TextStyle(fontSize: 16, height: 1.4)),
        const SizedBox(height: 15),
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
