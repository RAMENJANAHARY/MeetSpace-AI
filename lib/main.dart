
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Model for a single chat message
class ChatMessage {
  final String content;
  final bool isUser;

  ChatMessage({required this.content, required this.isUser});

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        content: json['content'],
        isUser: json['isUser'],
      );
}

// Manages the state of the chat
class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final String _groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    loadHistory();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    saveHistory();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    addMessage(ChatMessage(content: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {'role': 'user', 'content': text}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        addMessage(ChatMessage(content: content, isUser: false));
      } else {
        addMessage(ChatMessage(content: 'Error: ${response.body}', isUser: false));
      }
    } catch (e) {
      addMessage(ChatMessage(content: 'Error: $e', isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('chat_history', history);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chat_history');
    if (history != null) {
      _messages.clear();
      _messages.addAll(history.map((m) => ChatMessage.fromJson(jsonDecode(m))));
    } else {
        _messages.add(ChatMessage(content: "Hello! I'm MeetSpace AI.\nHow can I help you today?", isUser: false));
    }
    notifyListeners();
  }
  
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    _messages.clear();
    _messages.add(ChatMessage(content: "Chat history cleared ✓\nLet's start a new conversation!", isUser: false));
    notifyListeners();
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeetSpace AI',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF9d4edd),
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a2e),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1a1a2e),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeetSpace AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => chatProvider.clearHistory(),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                return ChatMessageWidget(message: message);
              },
            ),
          ),
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(context, chatProvider),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask MeetSpace AI anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  chatProvider.sendMessage(value);
                  _controller.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                chatProvider.sendMessage(text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF2a1a3a) : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              message.isUser ? 'You' : 'MeetSpace AI',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF9d4edd),
              ),
            ),
            const SizedBox(height: 5),
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              )
            ),
          ],
        ),
      ),
    );
  }
}
