import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/glass_card.dart';
import 'widgets/liquid_background.dart';

// TEMPORARY WORKAROUND: Hardcode API key for testing
// Delete after testing!
const String _apiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'AIzaSyCcudhaJxV2IcW5dis-AEJxn5ybRni7z7I', // Key Api of your
);

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // API endpoints
  static const String _baseUrlV1 =
      'https://generativelanguage.googleapis.com/v1/models';
  static const String _baseUrlV1Beta =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // Danh sách models khả dụng (dựa trên API response)
  static const List<Map<String, String>> _modelsToTry = [
    {'name': 'gemini-2.0-flash', 'apiVersion': 'v1'},
    {'name': 'gemini-2.5-flash', 'apiVersion': 'v1'},
    {'name': 'gemini-2.0-flash-lite', 'apiVersion': 'v1'},
    {'name': 'gemini-2.5-flash-lite', 'apiVersion': 'v1'},
    {'name': 'gemini-2.5-pro', 'apiVersion': 'v1'},
  ];

  String? _workingModel;
  String? _workingApiVersion;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Debug: Check API key
    debugPrint(
        '🔑 API Key: ${_apiKey.substring(0, 20)}... (length: ${_apiKey.length})');

    if (_apiKey.startsWith('YOUR_')) {
      setState(() {
        _errorMessage = 'Please provide a valid API key';
      });
      return;
    }

    // Tự động thử các model cho đến khi tìm được model hoạt động
    for (final modelConfig in _modelsToTry) {
      try {
        debugPrint(
            '🤖 Trying model: ${modelConfig['name']} (${modelConfig['apiVersion']})');
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
            // Add initial AI greeting
            _messages.add({
              'role': 'model',
              'text':
                  'Hello! I am your AI Companion. How can I help you feel better today?'
            });
          });
          return; // Thành công, thoát khỏi vòng lặp
        }
      } catch (e) {
        debugPrint('FAILED ${modelConfig['name']}: $e');
        // Thử model tiếp theo
        continue;
      }
    }

    // Nếu không có model nào hoạt động
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
  }) async {
    try {
      final model = modelName ?? _workingModel ?? 'gemini-pro';
      final version = apiVersion ?? _workingApiVersion ?? 'v1beta';
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
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('AI Companion'),
        backgroundColor: const Color(0xffeaf2f2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: _errorMessage != null
                      ? _buildErrorWidget()
                      : !_isInitialized
                          ? _buildApiKeyWarning()
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return MessageWidget(
                                  text: message['text']!,
                                  isFromUser: message['role'] == 'user',
                                );
                              },
                            ),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                _buildTextInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: SingleChildScrollView(
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                    _initialize();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeyWarning() {
    return Center(
      child: SingleChildScrollView(
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'API Key Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'To use the AI Companion, you need to provide your Google Gemini API Key.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How to run with API Key:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SelectableText(
                    'flutter run --dart-define=GEMINI_API_KEY=your_key_here',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Get your free API key at:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                const SelectableText(
                  'https://aistudio.google.com/app/apikey',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GlassCard(
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150, // Giới hạn chiều cao tối đa
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    enabled: _isInitialized,
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null, // Cho phép nhiều dòng
                    minLines: 1, // Bắt đầu với 1 dòng
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: !_isInitialized ? null : _sendMessage,
              icon: Icon(
                Icons.send,
                color: _isInitialized
                    ? Theme.of(context).primaryColorDark
                    : Colors.grey,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutCirc,
          );
        }
      },
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isFromUser ? const Color(0xFF5DB075) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isFromUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
