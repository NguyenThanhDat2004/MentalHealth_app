import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Sử dụng biến môi trường để bảo mật API Key
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
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  final List<ChatHistory> _chatHistory = [];
  bool _showHistory = false;
  final _historyScrollController = ScrollController();

  // THÊM MỚI: Biến để theo dõi chat session hiện tại
  String? _currentChatId;

  late final FirebaseFirestore _db;
  late final FirebaseAuth _auth;
  String? _userId;
  StreamSubscription? _chatSubscription;

  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  static const String _baseUrlV1 =
      'https://generativelanguage.googleapis.com/v1/models';
  static const String _baseUrlV1Beta =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const List<Map<String, String>> _modelsToTry = [
    {'name': 'gemini-2.0-flash-lite', 'apiVersion': 'v1'},
    {'name': 'gemini-2.5-flash-lite', 'apiVersion': 'v1'},
    {'name': 'gemini-2.0-flash', 'apiVersion': 'v1'},
    {'name': 'gemini-2.5-flash', 'apiVersion': 'v1'},
    {'name': 'gemini-2.5-pro', 'apiVersion': 'v1'},
  ];

  String? _workingModel;
  String? _workingApiVersion;

  // Color Scheme
  final Color _primaryColor = const Color(0xFF6366F1);
  final Color _secondaryColor = const Color(0xFF8B5CF6);
  final Color _accentColor = const Color(0xFF06D6A0);
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF1E293B);
  final Color _textSecondary = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initialize();

    _db = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _userId = user.uid;
        });
        _loadChatHistory();
      } else {
        _signInAnonymously();
      }
    });
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      setState(() {
        _userId = userCredential.user?.uid;
      });
      _loadChatHistory();
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      setState(() {
        _errorMessage = "Could not sign in to chat service.";
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _loadChatHistory() {
    if (_userId == null) return;

    _chatSubscription?.cancel();
    final collectionRef =
        _db.collection('users').doc(_userId).collection('chats');

    _chatSubscription = collectionRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final chats = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatHistory(
          id: doc.id,
          title: data['title'] ?? 'New Chat',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          messages: List<Map<String, String>>.from(
            (data['messages'] as List<dynamic>? ?? []).map(
              (msg) => Map<String, String>.from(msg),
            ),
          ),
          isPinned: data['isPinned'] ?? false,
          preview: data['preview'] ?? '',
        );
      }).toList();

      setState(() {
        _chatHistory.clear();
        _chatHistory.addAll(chats);
      });
    }, onError: (e) {
      debugPrint("Error loading chat history: $e");
      _showError("Failed to load chat history.");
    });
  }

  // ĐÃ SỬA: Đổi tên thành _saveNewChat và trả về ID của chat mới
  Future<String?> _saveNewChat() async {
    if (_userId == null) return null;
    if (_messages.length > 1) {
      final newChat = ChatHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateChatTitle(),
        createdAt: DateTime.now(),
        messages: List.from(_messages),
        preview: _messages.length > 1
            ? _messages[1]['text']!
            : _messages[0]['text']!,
      );

      try {
        final collectionRef =
            _db.collection('users').doc(_userId).collection('chats');
        // SỬA: Dùng add() và lấy DocumentReference
        final docRef = await collectionRef.add({
          'title': newChat.title,
          'createdAt': Timestamp.fromDate(newChat.createdAt),
          'messages': newChat.messages,
          'isPinned': newChat.isPinned,
          'preview': newChat.preview,
        });
        return docRef.id; // <-- TRẢ VỀ ID CHAT MỚI
      } catch (e) {
        debugPrint("Error saving chat: $e");
        _showError("Could not save your chat.");
      }
    }
    return null;
  }

  // THÊM MỚI: Hàm để cập nhật chat đã có
  Future<void> _updateExistingChat() async {
    if (_userId == null || _currentChatId == null) return;
    try {
      final docRef = _db
          .collection('users')
          .doc(_userId)
          .collection('chats')
          .doc(_currentChatId);
      // Cập nhật danh sách tin nhắn
      await docRef.update({
        'messages': _messages,
      });
    } catch (e) {
      debugPrint("Error updating chat: $e");
      _showError("Could not update your chat.");
    }
  }

  String _generateChatTitle() {
    if (_messages.length > 1) {
      final firstUserMessage = _messages.firstWhere(
        (msg) => msg['role'] == 'user',
        orElse: () => {'text': 'New Chat'},
      )['text']!;

      return firstUserMessage.length > 30
          ? '${firstUserMessage.substring(0, 30)}...'
          : firstUserMessage;
    }
    return 'New Chat';
  }

  Future<void> _initialize() async {
    if (_apiKey.isEmpty) {
      setState(() {
        _errorMessage =
            'API Key not provided. Please run with --dart-define=GEMINI_API_KEY=YOUR_KEY';
      });
      return;
    }

    for (final modelConfig in _modelsToTry) {
      try {
        debugPrint('🤖 Trying model: ${modelConfig['name']}');
        const testMessage = 'Hello';
        final response = await _callGeminiAPI(
          testMessage,
          modelName: modelConfig['name']!,
          apiVersion: modelConfig['apiVersion']!,
        );

        if (response != null && response.isNotEmpty) {
          debugPrint('SUCCESS with ${modelConfig['name']}');
          setState(() {
            _workingModel = modelConfig['name'];
            _workingApiVersion = modelConfig['apiVersion'];
            _isInitialized = true;
            _messages.add({
              'role': 'model',
              'text':
                  'Xin chào! Tôi là AI Companion. Tôi có thể giúp gì cho bạn hôm nay?'
            });
          });
          return;
        }
      } catch (e) {
        debugPrint('FAILED ${modelConfig['name']}: $e');
        continue;
      }
    }

    debugPrint('ALL MODELS FAILED');
    setState(() {
      _errorMessage =
          'Could not connect to any AI model. Please check your API key or try again later.';
    });
  }

  Future<String?> _callGeminiAPI(
    String userMessage, {
    String? modelName,
    String? apiVersion,
    int retryCount = 0,
  }) async {
    const maxRetries = 2;

    try {
      final model = modelName ?? _workingModel ?? 'gemini-2.0-flash-lite';
      final version = apiVersion ?? _workingApiVersion ?? 'v1';
      final baseUrl = version == 'v1' ? _baseUrlV1 : _baseUrlV1Beta;

      final url = Uri.parse('$baseUrl/$model:generateContent?key=$_apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': userMessage}
              ]
            }
          ],
          'safetySettings': [
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
          'generationConfig': {
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
      } else if (response.statusCode == 503 && retryCount < maxRetries) {
        debugPrint(
            '⚠️ Model overloaded, retrying... (${retryCount + 1}/$maxRetries)');
        await Future.delayed(const Duration(seconds: 2));
        return _callGeminiAPI(
          userMessage,
          modelName: modelName,
          apiVersion: apiVersion,
          retryCount: retryCount + 1,
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _historyScrollController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        // THÊM SafeArea Ở ĐÂY
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            Column(
              children: [
                _buildAppBar(),
                if (!_isInitialized && _errorMessage == null)
                  _buildConnectingIndicator(),
                if (_errorMessage != null) _buildErrorHeader(),
                Expanded(
                  child: _showHistory
                      ? _buildChatHistory()
                      : _buildChatInterface(),
                ),
                if (_loading && !_showHistory) _buildTypingIndicator(),
                if (!_showHistory) _buildMessageInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5 + _waveAnimation.value * 0.5,
              colors: [
                _primaryColor.withOpacity(0.03),
                _secondaryColor.withOpacity(0.02),
                _backgroundColor.withOpacity(0.9),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12), // GIẢM padding vertical
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16), // GIẢM border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15, // GIẢM blur radius
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, // GIẢM kích thước
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 20, // GIẢM kích thước icon
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'AI Companion',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18, // GIẢM font size
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _showHistory = !_showHistory);
              if (!_showHistory) {
                setState(() {
                  _messages.clear();
                  _currentChatId = null; // Xóa ID chat cũ
                  // Thêm lại tin nhắn chào
                  _messages.add({
                    'role': 'model',
                    'text':
                        'Xin chào! Tôi là AI Companion. Tôi có thể giúp gì cho bạn hôm nay?'
                  });
                });
              }
            },
            icon: Icon(
              _showHistory ? Icons.chat_bubble : Icons.history,
              color: _primaryColor,
              size: 22, // GIẢM kích thước icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // ĐIỀU CHỈNH margin
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // GIẢM padding
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18, // GIẢM kích thước
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
          const SizedBox(width: 10), // GIẢM khoảng cách
          Text(
            'Đang kết nối AI...',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13, // GIẢM font size
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // ĐIỀU CHỈNH margin
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // GIẢM padding
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Colors.red.shade600, size: 20), // GIẢM kích thước
          const SizedBox(width: 10), // GIẢM khoảng cách
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lỗi kết nối',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // GIẢM font size
                  ),
                ),
                Text(
                  'Vui lòng kiểm tra kết nối mạng',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 11, // GIẢM font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    return Stack(
      children: [
        _errorMessage != null
            ? _buildErrorWidget()
            : !_isInitialized
                ? _buildWelcomeWidget()
                : _buildChatMessages(),
      ],
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 12), // GIẢM padding
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageWidget(
          text: message['text']!,
          isFromUser: message['role'] == 'user',
          primaryColor: _primaryColor,
          surfaceColor: _surfaceColor,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // GIẢM margin
      padding: const EdgeInsets.all(12), // GIẢM padding
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, // GIẢM kích thước
            height: 36,
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [_primaryColor, _secondaryColor]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 18), // GIẢM icon
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Companion',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  fontSize: 12, // GIẢM font size
                ),
              ),
              const SizedBox(height: 4), // GIẢM khoảng cách
              Row(
                children: [
                  _buildTypingDot(0),
                  _buildTypingDot(1),
                  _buildTypingDot(2),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 3), // GIẢM margin
      width: 6, // GIẢM kích thước
      height: 6,
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.6 + index * 0.2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24), // GIẢM padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, // GIẢM kích thước
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 35, color: Colors.red.shade400), // GIẢM icon
            ),
            const SizedBox(height: 16), // GIẢM khoảng cách
            Text(
              'Lỗi kết nối',
              style: TextStyle(
                fontSize: 20, // GIẢM font size
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8), // GIẢM khoảng cách
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, // GIẢM font size
                color: _textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20), // GIẢM khoảng cách
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initialize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // GIẢM padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14), // GIẢM font size
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeWidget() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // GIẢM padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, // GIẢM kích thước
              height: 100,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [_primaryColor, _secondaryColor]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 12, // GIẢM blur
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.psychology_rounded,
                  size: 45, color: Colors.white), // GIẢM icon
            ),
            const SizedBox(height: 20), // GIẢM khoảng cách
            Text(
              'AI Companion',
              style: TextStyle(
                fontSize: 24, // GIẢM font size
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8), // GIẢM khoảng cách
            Text(
              'Trợ lý thông minh hỗ trợ sức khỏe tinh thần',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, // GIẢM font size
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16), // GIẢM khoảng cách
            Container(
              padding: const EdgeInsets.all(12), // GIẢM padding
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded,
                      color: _accentColor, size: 20), // GIẢM icon
                  const SizedBox(width: 8), // GIẢM khoảng cách
                  Expanded(
                    child: Text(
                      'Hỏi về sức khỏe tinh thần, mẹo hàng ngày, hoặc trò chuyện thân mật!',
                      style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12), // GIẢM font size
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

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          16, 8, 16, 16), // ĐIỀU CHỈNH margin (giảm top)
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // GIẢM padding
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20), // GIẢM border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxHeight: 100), // GIẢM maxHeight
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                      color: _textSecondary, fontSize: 15), // GIẢM font size
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 4), // GIẢM padding
                ),
                enabled: _isInitialized,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87), // GIẢM font size
              ),
            ),
          ),
          const SizedBox(width: 6), // GIẢM khoảng cách
          Container(
            width: 40, // GIẢM kích thước
            height: 40,
            decoration: BoxDecoration(
              gradient: _isInitialized && !_loading
                  ? LinearGradient(colors: [_primaryColor, _secondaryColor])
                  : LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade500]),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: !_isInitialized || _loading ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18), // GIẢM icon
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // Các phương thức còn lại giữ nguyên...
  Widget _buildChatHistory() {
    final pinnedChats = _chatHistory.where((chat) => chat.isPinned).toList();
    final otherChats = _chatHistory.where((chat) => !chat.isPinned).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // GIẢM padding
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  // SỬA: Khi nhấn Back, quay lại và bắt đầu chat MỚI
                  setState(() {
                    _showHistory = false;
                    _messages.clear();
                    _currentChatId = null; // Xóa ID chat cũ
                    // Thêm lại tin nhắn chào
                    _messages.add({
                      'role': 'model',
                      'text':
                          'Xin chào! Tôi là AI Companion. Tôi có thể giúp gì cho bạn hôm nay?'
                    });
                  });
                },
                icon: Icon(Icons.arrow_back,
                    color: _primaryColor, size: 22), // GIẢM icon
              ),
              const SizedBox(width: 6), // GIẢM khoảng cách
              const Text(
                'Lịch sử trò chuyện',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87), // GIẢM font size
              ),
              const Spacer(),
              Text(
                '${_chatHistory.length} cuộc hội thoại',
                style: TextStyle(
                    color: _textSecondary, fontSize: 12), // GIẢM font size
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _historyScrollController,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6), // GIẢM padding
            children: [
              if (pinnedChats.isNotEmpty) ...[
                _buildHistorySectionHeader('Cuộc trò chuyện đã ghim'),
                ...pinnedChats.map((chat) => _buildHistoryItem(chat)),
                const SizedBox(height: 12), // GIẢM khoảng cách
              ],
              if (otherChats.isNotEmpty) ...[
                _buildHistorySectionHeader('Cuộc trò chuyện gần đây'),
                ...otherChats.map((chat) => _buildHistoryItem(chat)),
              ],
              if (_chatHistory.isEmpty) _buildEmptyHistory(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 6, horizontal: 4), // GIẢM padding
      child: Text(
        title,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textSecondary), // GIẢM font size
      ),
    );
  }

  Widget _buildHistoryItem(ChatHistory chat) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3), // GIẢM margin
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _loadChat(chat);
            setState(() => _showHistory = false);
          },
          child: Container(
            padding: const EdgeInsets.all(12), // GIẢM padding
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, // GIẢM kích thước
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.chat_bubble_outline,
                      color: _primaryColor, size: 18), // GIẢM icon
                ),
                const SizedBox(width: 10), // GIẢM khoảng cách
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14, // GIẢM font size
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.isPinned)
                            Icon(Icons.push_pin,
                                size: 14, color: _accentColor), // GIẢM icon
                        ],
                      ),
                      const SizedBox(height: 3), // GIẢM khoảng cách
                      Text(
                        chat.preview,
                        style: TextStyle(
                            color: _textSecondary,
                            fontSize: 12), // GIẢM font size
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3), // GIẢM khoảng cách
                      Text(
                        _formatDate(chat.createdAt),
                        style: TextStyle(
                            color: _textSecondary.withOpacity(0.7),
                            fontSize: 10), // GIẢM font size
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

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24), // GIẢM padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70, // GIẢM kích thước
              height: 70,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history,
                  color: _primaryColor, size: 35), // GIẢM icon
            ),
            const SizedBox(height: 12), // GIẢM khoảng cách
            Text(
              'Chưa có lịch sử trò chuyện',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary), // GIẢM font size
            ),
            const SizedBox(height: 6), // GIẢM khoảng cách
            Text(
              'Các cuộc trò chuyện của bạn sẽ xuất hiện ở đây',
              style: TextStyle(
                  color: _textSecondary.withOpacity(0.7),
                  fontSize: 12), // GIẢM font size
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

        // --- ĐÃ SỬA LẠI TOÀN BỘ LOGIC LƯU ---
        if (_currentChatId == null) {
          // Đây là một cuộc trò chuyện MỚI (chưa có ID)
          // Lưu nó và lấy ID mới
          final newId = await _saveNewChat();
          if (newId != null) {
            setState(() {
              _currentChatId =
                  newId; // Đặt ID để các tin nhắn sau sẽ là CẬP NHẬT
            });
          }
        } else {
          // Đây là cuộc trò chuyện HIỆN CÓ
          // Chỉ cần cập nhật nó
          await _updateExistingChat();
        }
        // --- KẾT THÚC LOGIC LƯU ---
      } else {
        _showError('Received an empty response from AI');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      Future.delayed(const Duration(milliseconds: 100), _scrollDown);
    }
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
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _loadChat(ChatHistory chat) {
    setState(() {
      _messages.clear();
      _messages.addAll(chat.messages);
      _currentChatId = chat.id; // <-- THÊM MỚI: Đặt ID của chat đang xem
    });
    _scrollDown();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';

    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;
  final Color primaryColor;
  final Color surfaceColor;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 6, horizontal: 12), // GIẢM margin
      child: Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser)
            Container(
              margin: const EdgeInsets.only(right: 6, top: 2), // GIẢM margin
              width: 32, // GIẢM kích thước
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 16), // GIẢM icon
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 14), // GIẢM padding
              decoration: BoxDecoration(
                color: isFromUser ? primaryColor : surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3), // GIẢM padding
                      child: Text(
                        'AI Companion',
                        style: TextStyle(
                          fontSize: 11, // GIẢM font size
                          fontWeight: FontWeight.w600,
                          color: isFromUser
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  Text(
                    text,
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 14, // GIẢM font size
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser)
            Container(
              margin: const EdgeInsets.only(left: 6, top: 2), // GIẢM margin
              width: 32, // GIẢM kích thước
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  color: Colors.white, size: 16), // GIẢM icon
            ),
        ],
      ),
    );
  }
}
