import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _apiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'AIzaSyCcudhaJxV2IcW5dis-AEJxn5ybRni7z7I',
);

class ChatHistory {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Map<String, String>> messages;
  bool isPinned;
  final String preview;

  ChatHistory({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
    this.isPinned = false,
    required this.preview,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'messages': messages,
      'isPinned': isPinned,
      'preview': preview,
    };
  }

  factory ChatHistory.fromMap(String id, Map<String, dynamic> data) {
    return ChatHistory(
      id: id,
      title: data['title'] ?? 'New Chat',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messages: List<Map<String, String>>.from(
        (data['messages'] as List<dynamic>? ?? []).map(
          (msg) => Map<String, String>.from(msg as Map),
        ),
      ),
      isPinned: data['isPinned'] ?? false,
      preview: data['preview'] ?? '',
    );
  }
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  final List<ChatHistory> _chatHistory = [];
  bool _showHistory = false;
  final _historyScrollController = ScrollController();
  String? _currentChatId;

  late final FirebaseFirestore _db;
  late final FirebaseAuth _auth;
  String? _userId;
  StreamSubscription? _chatSubscription;
  bool _isAuthInitialized = false;

  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late AnimationController _fadeController;
  late Animation<double> _waveAnimation;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _fadeAnimation;

  static const String _baseUrlV1 =
      'https://generativelanguage.googleapis.com/v1/models';
  static const String _baseUrlV1Beta =
      'https://generativelanguage.googleapis.com/v1beta/models';

  String? _workingModel;
  String? _workingApiVersion;

  // Modern Glass Color Scheme
  final Color _primaryGlass = const Color(0xFF6366F1);
  final Color _secondaryGlass = const Color(0xFF8B5CF6);
  final Color _accentGlass = const Color(0xFF06D6A0);
  final Color _backgroundGlass = const Color(0xFF0F172A);
  final Color _surfaceGlass = const Color.fromRGBO(255, 255, 255, 0.08);
  final Color _textPrimaryGlass = const Color(0xFFF1F5F9);
  final Color _textSecondaryGlass = const Color(0xFF94A3B8);

  BoxDecoration _glassDecoration({double blur = 20, double opacity = 0.1}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _surfaceGlass.withValues(alpha: opacity),
          _surfaceGlass.withValues(alpha: opacity * 0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    _db = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    _initializeApp();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );

    _bubbleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      _initialize(),
      _initializeAuth(),
    ]);
  }

  Future<void> _initializeAuth() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() {
          _userId = currentUser.uid;
          _isAuthInitialized = true;
        });
        await _loadChatHistory();
      } else {
        await _signInAnonymously();
      }
    } catch (e) {
      debugPrint("Error initializing auth: $e");
      setState(() {
        _errorMessage = "Không thể kết nối dịch vụ chat.";
      });
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      setState(() {
        _userId = userCredential.user?.uid;
        _isAuthInitialized = true;
      });
      await _loadChatHistory();
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      setState(() {
        _errorMessage = "Không thể đăng nhập dịch vụ chat.";
      });
    }
  }

  Future<void> _loadChatHistory() async {
    if (_userId == null) return;

    try {
      _chatSubscription?.cancel();
      final collectionRef =
          _db.collection('users').doc(_userId).collection('chats');

      _chatSubscription = collectionRef
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        final chats = snapshot.docs.map((doc) {
          return ChatHistory.fromMap(doc.id, doc.data());
        }).toList();

        if (mounted) {
          setState(() {
            _chatHistory.clear();
            _chatHistory.addAll(chats);
          });
        }
      }, onError: (e) {
        debugPrint("Error loading chat history: $e");
        _showError("Không thể tải lịch sử chat.");
      });
    } catch (e) {
      debugPrint("Error setting up chat listener: $e");
    }
  }

  Future<void> _initialize() async {
    if (_apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'API Key không được cung cấp';
      });
      return;
    }
    _workingModel = 'gemini-2.0-flash';
    _workingApiVersion = 'v1';

    // ĐÃ SỬA: Thêm lời chào ngay lập tức khi khởi tạo
    if (mounted) {
      setState(() {
        _isInitialized = true;
        if (_messages.isEmpty) {
          _messages.add(const {
            'role': 'model',
            'text':
                'Xin chào! Tôi là AI Companion. Tôi có thể giúp gì cho bạn hôm nay?'
          });
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty || _loading || !_isInitialized) {
      return;
    }

    final userMessage = _textController.text.trim();
    _textController.clear();

    setState(() {
      _loading = true;
      _messages.add({'role': 'user', 'text': userMessage});
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollDown);

    try {
      final aiResponse = await _callGeminiAPI(userMessage);

      if (aiResponse != null && aiResponse.isNotEmpty) {
        setState(() {
          _messages.add({'role': 'model', 'text': aiResponse});
        });

        if (_currentChatId == null) {
          final newId = await _saveNewChat();
          if (newId != null) {
            setState(() {
              _currentChatId = newId;
            });
          }
        } else {
          await _updateExistingChat();
        }
      } else {
        _showError('Không nhận được phản hồi từ AI');
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
      _showError('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      Future.delayed(const Duration(milliseconds: 100), _scrollDown);
    }
  }

  Future<String?> _saveNewChat() async {
    if (_userId == null || !_isAuthInitialized) return null;
    if (_messages.length < 2) return null;

    try {
      String rawPreview = _messages.length > 1
          ? _messages[1]['text'] ?? 'New Chat'
          : 'New Chat';

      final newChat = ChatHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateChatTitle(),
        createdAt: DateTime.now(),
        messages: List.from(_messages),
        preview: _safeSubstring(rawPreview, 50),
      );

      final collectionRef =
          _db.collection('users').doc(_userId).collection('chats');

      final docRef = await collectionRef.add({
        ...newChat.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      debugPrint("Error saving chat: $e");
      return null;
    }
  }

  Future<void> _updateExistingChat() async {
    if (_userId == null || _currentChatId == null || !_isAuthInitialized) {
      return;
    }

    try {
      final docRef = _db
          .collection('users')
          .doc(_userId)
          .collection('chats')
          .doc(_currentChatId);

      String lastMessageText =
          _messages.isNotEmpty ? _messages.last['text'] ?? '' : '';

      await docRef.update({
        'messages': _messages,
        'preview': _safeSubstring(lastMessageText, 50),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error updating chat: $e");
    }
  }

  String _generateChatTitle() {
    if (_messages.length > 1) {
      final firstUserMessage = _messages.firstWhere(
        (msg) => msg['role'] == 'user',
        orElse: () => const {'text': 'New Chat'},
      )['text']!;

      return _safeSubstring(firstUserMessage, 30);
    }
    return 'New Chat';
  }

  String _safeSubstring(String? text, int maxLength) {
    if (text == null) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<String?> _callGeminiAPI(
    String userMessage, {
    String? modelName,
    String? apiVersion,
    int retryCount = 0,
  }) async {
    const maxRetries = 2;

    try {
      final model = modelName ?? _workingModel ?? 'gemini-2.0-flash';
      final version = apiVersion ?? _workingApiVersion ?? 'v1';
      final baseUrl = version == 'v1' ? _baseUrlV1 : _baseUrlV1Beta;

      final url = Uri.parse('$baseUrl/$model:generateContent?key=$_apiKey');

      final response = await http.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': userMessage}
              ]
            }
          ],
          'safetySettings': const [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE'
            }
          ],
          'generationConfig': const {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text as String;
        }
      } else if ((response.statusCode == 503 || response.statusCode == 429) &&
          retryCount < maxRetries) {
        await Future.delayed(const Duration(seconds: 3));
        return _callGeminiAPI(
          userMessage,
          modelName: modelName,
          apiVersion: apiVersion,
          retryCount: retryCount + 1,
        );
      } else {
        if (response.statusCode == 429) {
          throw Exception('Hệ thống bận (429). Vui lòng thử lại sau.');
        }
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _currentChatId = null;
      _messages.add(const {
        'role': 'model',
        'text':
            'Xin chào! Tôi là AI Companion. Tôi có thể giúp gì cho bạn hôm nay?'
      });
    });
  }

  void _handleHistoryMenu(String value, ChatHistory chat) async {
    switch (value) {
      case 'pin':
        if (_userId == null) return;
        try {
          await _db
              .collection('users')
              .doc(_userId)
              .collection('chats')
              .doc(chat.id)
              .update({'isPinned': !chat.isPinned});
        } catch (e) {
          debugPrint("Error toggling pin: $e");
          _showError("Không thể cập nhật trạng thái ghim.");
        }
        break;
      case 'delete':
        _deleteChat(chat);
        break;
    }
  }

  void _deleteChat(ChatHistory chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cuộc trò chuyện'),
        content: const Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (_userId == null) return;
              try {
                await _db
                    .collection('users')
                    .doc(_userId)
                    .collection('chats')
                    .doc(chat.id)
                    .delete();
                if (_currentChatId == chat.id) {
                  _resetChat();
                }
              } catch (e) {
                debugPrint("Error deleting chat: $e");
                _showError("Không thể xóa cuộc trò chuyện.");
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _loadChat(ChatHistory chat) {
    setState(() {
      _messages.clear();
      _messages.addAll(chat.messages);
      _currentChatId = chat.id;
    });
    _scrollDown();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Đang lưu...';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';

    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _historyScrollController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGlass,
      body: SafeArea(
        child: Stack(
          children: [
            _buildLiquidGlassBackground(),
            _buildFloatingBubbles(),
            Column(
              children: [
                _buildGlassAppBar(),
                if (!_isInitialized && _errorMessage == null)
                  _buildGlassConnectingIndicator(),
                if (_errorMessage != null) _buildGlassErrorHeader(),
                Expanded(
                  child: _showHistory
                      ? _buildGlassChatHistory()
                      : _buildGlassChatInterface(),
                ),
                if (_loading && !_showHistory) _buildGlassTypingIndicator(),
                if (!_showHistory) _buildGlassMessageInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidGlassBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: LiquidGlassPainter(
            animationValue: _waveAnimation.value,
            primaryColor: _primaryGlass,
            secondaryColor: _secondaryGlass,
          ),
        );
      },
    );
  }

  Widget _buildFloatingBubbles() {
    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + _bubbleAnimation.value * 10,
              left: 30,
              child: _buildFloatingBubble(
                  40, _primaryGlass.withValues(alpha: 0.1)),
            ),
            Positioned(
              top: 200 - _bubbleAnimation.value * 8,
              right: 40,
              child: _buildFloatingBubble(
                  60, _secondaryGlass.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: 150 + _bubbleAnimation.value * 12,
              left: 50,
              child: _buildFloatingBubble(
                  35, _accentGlass.withValues(alpha: 0.06)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _fadeAnimation.value) * 20),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: _glassDecoration(blur: 30, opacity: 0.15),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryGlass, _secondaryGlass],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryGlass.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Companion',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: _textPrimaryGlass,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Trợ lý thông minh',
                          style: TextStyle(
                            color: _textSecondaryGlass,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _showHistory
                          ? LinearGradient(
                              colors: [
                                _accentGlass,
                                _accentGlass.withValues(alpha: 0.7)
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                _surfaceGlass,
                                _surfaceGlass.withValues(alpha: 0.5)
                              ],
                            ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() => _showHistory = !_showHistory);
                        if (!_showHistory) {
                          _resetChat();
                        }
                      },
                      icon: Icon(
                        _showHistory ? Icons.chat_bubble : Icons.history,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassConnectingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: _glassDecoration(blur: 20, opacity: 0.1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_primaryGlass, _secondaryGlass],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGlass.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: _loading ? 3 : 0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Đang kết nối AI...',
              style: TextStyle(
                color: _textSecondaryGlass,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassErrorHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.1),
              Colors.red.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.withValues(alpha: 0.8), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lỗi kết nối',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Vui lòng kiểm tra kết nối mạng',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassChatInterface() {
    return Stack(
      children: [
        if (_errorMessage != null)
          _buildGlassErrorWidget()
        else if (!_isInitialized)
          _buildGlassWelcomeWidget()
        else
          _buildGlassChatMessages(),
      ],
    );
  }

  Widget _buildGlassChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassMessageWidget(
            text: message['text']!,
            isFromUser: message['role'] == 'user',
            primaryColor: _primaryGlass,
            surfaceColor: _surfaceGlass,
          ),
        );
      },
    );
  }

  Widget _buildGlassTypingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: _glassDecoration(blur: 20, opacity: 0.1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryGlass, _secondaryGlass],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Companion',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _textPrimaryGlass,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildGlassTypingDot(0),
                    _buildGlassTypingDot(1),
                    _buildGlassTypingDot(2),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + index * 200),
      margin: const EdgeInsets.only(right: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _primaryGlass.withValues(alpha: 0.8 - index * 0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryGlass.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: index == 0 ? 1 : 0,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassErrorWidget() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: _glassDecoration(blur: 30, opacity: 0.15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.2),
                        Colors.red.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Icon(Icons.wifi_off_rounded,
                      size: 50, color: Colors.red.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Lỗi kết nối',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textPrimaryGlass,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _textSecondaryGlass,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryGlass, _secondaryGlass],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGlass.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _initialize();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassWelcomeWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: _glassDecoration(blur: 30, opacity: 0.15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_primaryGlass, _secondaryGlass],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGlass.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text(
                  'AI Companion',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: _textPrimaryGlass,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trợ lý thông minh hỗ trợ sức khỏe tinh thần',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _textSecondaryGlass,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accentGlass.withValues(alpha: 0.1),
                        _accentGlass.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: _accentGlass.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: _accentGlass, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hỏi về sức khỏe tinh thần, mẹo hàng ngày, hoặc trò chuyện thân mật!',
                          style: TextStyle(
                              color: _textSecondaryGlass, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMessageInput() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: _glassDecoration(blur: 30, opacity: 0.15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: _textController,
                  style: TextStyle(color: _textPrimaryGlass, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(
                      color: _textSecondaryGlass.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 0,
                    ),
                  ),
                  enabled: _isInitialized,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _isInitialized && !_loading
                    ? LinearGradient(
                        colors: [_primaryGlass, _secondaryGlass],
                      )
                    : LinearGradient(
                        colors: [
                          _textSecondaryGlass.withValues(alpha: 0.3),
                          _textSecondaryGlass.withValues(alpha: 0.2)
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: _isInitialized && !_loading
                    ? [
                        BoxShadow(
                          color: _primaryGlass.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                onPressed: !_isInitialized || _loading ? null : _sendMessage,
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassChatHistory() {
    final pinnedChats = _chatHistory.where((chat) => chat.isPinned).toList();
    final otherChats = _chatHistory.where((chat) => !chat.isPinned).toList();

    return ListView(
      controller: _historyScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (pinnedChats.isNotEmpty) ...[
          _buildHistorySectionHeader('Đã ghim'),
          ...pinnedChats.map((chat) => _buildHistoryItem(chat)),
          const SizedBox(height: 16),
        ],
        if (otherChats.isNotEmpty) ...[
          _buildHistorySectionHeader('Gần đây'),
          ...otherChats.map((chat) => _buildHistoryItem(chat)),
        ],
        if (_chatHistory.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Chưa có lịch sử trò chuyện',
                style: TextStyle(color: _textSecondaryGlass),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistorySectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: _textSecondaryGlass,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ChatHistory chat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: _glassDecoration(blur: 20, opacity: 0.1),
        child: ListTile(
          onTap: () {
            _loadChat(chat);
            setState(() => _showHistory = false);
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryGlass.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.chat_bubble_outline, color: _primaryGlass, size: 20),
          ),
          title: Text(
            chat.title,
            style: TextStyle(
              color: _textPrimaryGlass,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chat.preview,
                style: TextStyle(
                  color: _textSecondaryGlass,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(chat.createdAt),
                style: TextStyle(
                  color: _textSecondaryGlass.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: _textSecondaryGlass, size: 20),
            color: const Color(0xFF1E293B),
            onSelected: (value) => _handleHistoryMenu(value, chat),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                        chat.isPinned
                            ? Icons.push_pin_outlined
                            : Icons.push_pin,
                        color: _accentGlass,
                        size: 18),
                    const SizedBox(width: 8),
                    Text(chat.isPinned ? 'Bỏ ghim' : 'Ghim',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiquidGlassPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  LiquidGlassPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withValues(alpha: 0.03),
          secondaryColor.withValues(alpha: 0.02),
          const Color(0xFF0F172A).withValues(alpha: 0.95),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);

    path.cubicTo(
      size.width * 0.2,
      size.height * (0.6 - 0.1 * animationValue),
      size.width * 0.5,
      size.height * (0.6 + 0.15 * animationValue),
      size.width * 0.8,
      size.height * (0.6 - 0.05 * animationValue),
    );

    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * (0.6 - 0.1 * animationValue),
      size.width,
      size.height * 0.6,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final path2 = Path();
    path2.moveTo(0, size.height * 0.4);

    path2.cubicTo(
      size.width * 0.3,
      size.height * (0.4 + 0.1 * (1 - animationValue)),
      size.width * 0.6,
      size.height * (0.4 - 0.15 * (1 - animationValue)),
      size.width,
      size.height * 0.4,
    );

    path2.lineTo(size.width, size.height * 0.6);
    path2.lineTo(0, size.height * 0.6);
    path2.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(
      path2,
      paint..color = secondaryColor.withValues(alpha: 0.02),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GlassMessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;
  final Color primaryColor;
  final Color surfaceColor;

  const GlassMessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isFromUser ? 20 : 4),
          bottomRight: Radius.circular(isFromUser ? 4 : 20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFromUser
                  ? primaryColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: isFromUser ? 0.5 : 0.2),
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
