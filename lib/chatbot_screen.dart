import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGeminiModel();
    _addWelcomeMessage();
  }

  void _initializeGeminiModel() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyCtw2mj7hUUjzpfIai5uS4N1QnOkTRGEJM', // Replace with your actual API key
    );
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "Welcome to the Career Guidance Assistant! How can I help you with your career questions today?",
        isUser: false,
      ));
    });
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _textController.clear();

    try {
      final content = [
        Content.text("You are a career guidance assistant. Provide helpful advice for the following career-related question: $text")
      ];
      final response = await _model.generateContent(content);

      setState(() {
        _messages.add(ChatMessage(
          text: _formatResponse(response.text ?? 'No response'),
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again later.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  String _formatResponse(String response) {
    // Remove asterisks and other Markdown syntax
    return response.replaceAll(RegExp(r'\*{1,2}'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Guidance Assistant'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[_messages.length - 1 - index],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1.0),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _handleSubmitted,
              decoration: const InputDecoration.collapsed(hintText: 'Ask a career question...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: isUser ? Colors.blue : Colors.green,
              child: Icon(
                isUser ? Icons.person : Icons.work,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Career Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.blue : Colors.green,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}