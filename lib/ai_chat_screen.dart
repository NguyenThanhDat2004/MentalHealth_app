import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'widgets/glass_card.dart';
import 'widgets/liquid_background.dart';

// IMPORTANT: Paste your Google AI Studio API Key here
const String _apiKey = '';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late GenerativeModel _model; // Google Generative AI model instance
  late ChatSession _chat; // Chat session with history
  final TextEditingController _textController =
      TextEditingController(); // For input field
  final ScrollController _scrollController =
      ScrollController(); // For auto-scroll chat
  bool _loading = false; // Loading indicator for API calls
  bool _isModelInitialized = false; // To check if model is ready

  @override
  void initState() {
    super.initState();
    _initializeModel(); // Initialize AI model on screen load
  }

  Future<void> _initializeModel() async {
    try {
      // Create a model instance (you can update to newer models)
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Model version
        apiKey: _apiKey,
      );
      _chat = _model.startChat(); // Start new chat session
      if (mounted) {
        setState(() {
          _isModelInitialized = true; // Mark initialization complete
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(
            'Failed to initialize model: $e'); // Show error if setup fails
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
          // Animated liquid background
          const LiquidBackground(),

          // Chat interface
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Chat history area
                Expanded(
                  child: _apiKey.startsWith('YOUR_') || !_isModelInitialized
                      ? _buildApiKeyWarning() // Show warning if API Key missing
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _chat.history.length,
                          itemBuilder: (context, index) {
                            final content = _chat.history.toList()[index];
                            // Extract text parts from history
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

                // Show loading spinner when waiting for AI response
                if (_loading) const CircularProgressIndicator(),

                // Input field for typing messages
                _buildTextInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget that shows a warning when API Key is missing
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

  /// Chat input bar (text field + send button)
  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GlassCard(
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            // Text input
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

            // Send button
            IconButton(
              onPressed: !_isModelInitialized ? null : _sendMessage,
              icon: Icon(Icons.send, color: Theme.of(context).primaryColorDark),
            )
          ],
        ),
      ),
    );
  }

  /// Handle sending message to AI
  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty || _loading || !_isModelInitialized) {
      return; // Prevent empty messages or multiple calls
    }

    setState(() {
      _loading = true;
    });

    try {
      // Send message to AI
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
      _textController.clear(); // Clear input
      Future.delayed(
          const Duration(milliseconds: 100), _scrollDown); // Auto-scroll
    }
  }

  /// Scroll chat to the latest message
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  /// Show error message in a snackbar
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

/// Widget to display each chat message bubble
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
