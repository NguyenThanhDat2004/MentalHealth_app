import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'widgets/glass_card.dart';
import 'widgets/liquid_background.dart';

// QUAN TRỌNG: Hãy dán API Key bạn đã lấy từ Google AI Studio vào đây.
const String _apiKey = 'AIzaSyBmzYAKh6SWVQefK5IeCCtMWESfLcUAn4Y';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late GenerativeModel _model;
  late ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  bool _isModelInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      // Khởi tạo với mô hình mặc định hoặc kiểm tra danh sách mô hình
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Cập nhật lên mô hình mới hơn
        apiKey: _apiKey,
      );
      _chat = _model.startChat();
      if (mounted) {
        setState(() {
          _isModelInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to initialize model: $e');
      }
    }
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
                  child: _apiKey.startsWith('YOUR_') || !_isModelInitialized
                      ? _buildApiKeyWarning()
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _chat.history.length,
                          itemBuilder: (context, index) {
                            final content = _chat.history.toList()[index];
                            final text = content.parts
                                .whereType<TextPart>()
                                .map<String>((e) => e.text)
                                .join('');
                            return MessageWidget(
                              text: text,
                              isFromUser: content.role == 'user',
                            );
                          },
                        ),
                ),
                if (_loading) const CircularProgressIndicator(),
                _buildTextInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyWarning() {
    return const Center(
      child: GlassCard(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Please add your Google API Key in `lib/ai_chat_screen.dart` to enable the chat feature.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              onPressed: !_isModelInitialized ? null : _sendMessage,
              icon: Icon(Icons.send, color: Theme.of(context).primaryColorDark),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty || _loading || !_isModelInitialized) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await _chat.sendMessage(
        Content.text(_textController.text),
      );
      final text = response.text;
      if (text == null) {
        _showError('No response from API.');
        return;
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      _showError('Error sending message: $e');
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollDown);
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
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
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isFromUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
