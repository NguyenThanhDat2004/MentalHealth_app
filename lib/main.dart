import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'home_screen.dart';
import 'sessions_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MentalHealthApp());
}

/// Root widget of the application
class MentalHealthApp extends StatefulWidget {
  const MentalHealthApp({super.key});

  @override
  State<MentalHealthApp> createState() => _MentalHealthAppState();

  /// Allows changing app locale dynamically from anywhere in the widget tree
  static void setLocale(BuildContext context, Locale newLocale) {
    _MentalHealthAppState? state =
        context.findAncestorStateOfType<_MentalHealthAppState>();
    state?.setLocale(newLocale);
  }
}

class _MentalHealthAppState extends State<MentalHealthApp> {
  Locale? _locale; // Stores the currently selected locale

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style (status bar appearance)
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
      // Apply current locale
      locale: _locale,
      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom app localizations
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Supported languages
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('vi', ''), // Vietnamese
        Locale('ru', ''), // Russian
      ],
      home: const MainScreen(),
    );
  }
}

/// MainScreen manages the bottom navigation and main pages
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Track current bottom navigation index
  String _userName = 'What is your name?'; // User’s displayed name

  /// Update the username when changed from Profile screen
  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pages controlled by bottom navigation
    final List<Widget> pages = [
      HomeScreen(userName: _userName),
      const SessionsScreen(),
      const CommunityScreen(),
      ProfileScreen(
        initialName: _userName,
        onNameUpdated: _updateUserName,
      ),
    ];

    // Calculate navigation bar item width for indicator animation
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
          // KeyedSubtree ensures widget state resets when switching pages
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
            /// Smooth sliding indicator at the top of the navigation bar
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

            /// Custom bottom navigation using Row instead of BottomNavigationBar
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

  /// Build a single navigation item
  Widget _buildNavItem(IconData icon, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        // Ensure the whole area is tappable
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: _currentIndex == index
                ? const Color(0xFF5DB075) // Active item color
                : Colors.grey.shade400, // Inactive item color
          ),
        ),
      ),
    );
  }
}
