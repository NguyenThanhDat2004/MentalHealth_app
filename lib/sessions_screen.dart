import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'l10n/app_localizations.dart';
import 'widgets/liquid_background.dart';
import 'widgets/glass_card.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> sessions = [
      {
        'imageUrl': 'https://i.pravatar.cc/150?img=1',
        'name': 'Sahana V',
        'specialty': 'Msc in Clinical Psychology',
        'date': '31st March ‘22',
        'time': '7:30 PM - 8:30 PM',
        'isCompleted': false
      },
      {
        'imageUrl': 'https://i.pravatar.cc/150?img=2',
        'name': 'Sahana V',
        'specialty': 'Msc in Clinical Psychology',
        'date': '31st March ‘22',
        'time': '7:30 PM - 8:30 PM',
        'isCompleted': true
      },
    ];

    return Stack(
      children: [
        const LiquidBackground(),
        AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: sessions.length + 3,
            itemBuilder: (context, index) {
              Widget child;
              if (index == 0) {
                child = _buildHeader();
              } else if (index == 1) {
                child =
                    GlassCard(child: _buildUpcomingSessionCard(localizations));
              } else if (index == 2) {
                child = _buildAllSessionsHeader(localizations);
              } else {
                final sessionIndex = index - 3;
                final session = sessions[sessionIndex];
                child = GlassCard(
                  child: _buildSessionCard(
                    localizations: localizations,
                    imageUrl: session['imageUrl'],
                    name: session['name'],
                    specialty: session['specialty'],
                    date: session['date'],
                    time: session['time'],
                    isCompleted: session['isCompleted'],
                  ),
                );
              }
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                    verticalOffset: 50.0, child: FadeInAnimation(child: child)),
              );
            },
          ),
        ),
      ],
    );
  }

  // Các hàm build widget không thay đổi nhiều, chỉ bỏ decoration bên trong
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
              radius: 25,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?img=32')),
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
    );
  }

  Widget _buildUpcomingSessionCard(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.upcomingSession,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Sahana V. Msc in Clinical Psychology',
            style: TextStyle(color: Colors.black54, fontSize: 15)),
        const SizedBox(height: 5),
        const Text('7:30 PM - 8:30 PM',
            style: TextStyle(color: Colors.black54, fontSize: 15)),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(localizations.joinNow,
                style: const TextStyle(
                    color: Color(0xFF5DB075),
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle_fill, color: Color(0xFF5DB075)),
          ],
        )
      ],
    );
  }

  Widget _buildAllSessionsHeader(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(localizations.allSessions,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          Icon(Icons.swap_vert, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required AppLocalizations localizations,
    required String imageUrl,
    required String name,
    required String specialty,
    required String date,
    required String time,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(specialty,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(date, style: const TextStyle(color: Colors.black54)),
            const SizedBox(width: 20),
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(time, style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 20),
        isCompleted
            ? _buildCompletedButtons(localizations)
            : _buildUpcomingButtons(localizations),
      ],
    );
  }

  Widget _buildUpcomingButtons(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5DB075),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text(localizations.reschedule,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5DB075)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text(localizations.joinNow,
                style: const TextStyle(color: Color(0xFF5DB075), fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedButtons(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5DB075),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text(localizations.rebook,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5DB075)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 15)),
            child: Text(localizations.viewProfile,
                style: const TextStyle(color: Color(0xFF5DB075), fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
