import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_screen.dart';
import 'sessions_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MentalHealthApp());
}

class MentalHealthApp extends StatefulWidget {
  const MentalHealthApp({super.key});

  @override
  State<MentalHealthApp> createState() => _MentalHealthAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MentalHealthAppState? state =
        context.findAncestorStateOfType<_MentalHealthAppState>();
    // Sử dụng null-aware operator để gọi method an toàn
    state?.setLocale(newLocale);
  }
}

class _MentalHealthAppState extends State<MentalHealthApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      setState(() {
        _locale = locale;
      });
    }
  }

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
        scaffoldBackgroundColor: const Color(0xffeaf2f2),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('vi', ''),
        Locale('ru', ''),
      ],
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
  String? _avatarPath;

  late final List<Widget> _pages;
  late final List<IconData> _navBarIcons;

  @override
  void initState() {
    super.initState();

    // Khởi tạo danh sách icons
    _navBarIcons = [
      Icons.home,
      Icons.videocam_outlined,
      Icons.chat_bubble_outline,
      Icons.people_outline,
    ];

    // Khởi tạo pages
    _updatePages();
  }

  void _updatePages() {
    _pages = [
      HomeScreen(userName: _userName, avatarPath: _avatarPath),
      SessionsScreen(avatarPath: _avatarPath),
      CommunityScreen(avatarPath: _avatarPath),
      ProfileScreen(
        initialName: _userName,
        onNameUpdated: _updateUserName,
        initialAvatarPath: _avatarPath,
        onAvatarUpdated: _updateUserAvatar,
      ),
    ];
  }

  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
      _updatePages();
    });
  }

  void _updateUserAvatar(String newPath) {
    setState(() {
      _avatarPath = newPath;
      _updatePages();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tạo navigation items với màu động
    final items = List.generate(_navBarIcons.length, (index) {
      return Icon(
        _navBarIcons[index],
        size: 30,
        color: _currentIndex == index
            ? const Color(0xFF5DB075)
            : Colors.grey.shade500,
      );
    });

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        height: 65.0,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.white,
        color: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
