import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  final FlutterTts _tts = FlutterTts();
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _currentlySpeakingId;

  GenerativeModel? _model;
  ChatSession? _chat;

  final List<String> _quickSuggestions = [
    "Tell me about Tutankhamun's gold mask",
    "What weapons are in the Roman collection?",
    "Explain the history of Apollo 11",
    "What is the oldest artifact here?",
    "කෞතුකාගාරයේ ඇති වැදගත්ම දේ මොනවාද?",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _currentlySpeakingId = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initializeAI() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('artifacts').get();
      String artifactData = snapshot.docs.map((doc) {
        final d = doc.data();
        return "- ${d['name']} (${d['period']}, ${d['section']}): ${d['description']}. Details: ${d['details']}";
      }).join('\n');

      final systemContext =
          "You are an esteemed, friendly, and knowledgeable AI Curator for ArtSphere Museum. "
          "You guide visitors about historical treasures, artifacts, dynasties, and ancient civilizations. "
          "You understand and can respond fluently in both English and Sinhala (සිංහල).\n"
          "Here is the museum collection directory:\n$artifactData\n"
          "Keep answers engaging, historically accurate, and informative.";

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConfig.geminiApiKey,
        systemInstruction: Content.system(systemContext),
      );
      _chat = _model!.startChat();
      _messages.add(
        _Message(
          id: 'welcome_msg',
          text: "Greetings, esteemed explorer! I am your AI Curator. Ask me about any artifact, era, or historical mystery within our galleries.",
          isUser: false,
        ),
      );
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _chat == null) return;
    final userText = text.trim();
    _controller.clear();
    setState(() {
      _messages.add(_Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: userText,
        isUser: true,
      ));
      _isLoading = true;
    });
    _scrollToBottom();
    try {
      final response = await _chat!.sendMessage(Content.text(userText));
      if (mounted) {
        setState(() {
          _messages.add(_Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: response.text ?? 'I am studying this historical detail. Please ask again.',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: "My apologies, I encountered a temporary connection issue. Please try again.",
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }
    _scrollToBottom();
  }

  Future<void> _speakMessage(String id, String text) async {
    if (_currentlySpeakingId == id) {
      await _tts.stop();
      if (mounted) setState(() => _currentlySpeakingId = null);
    } else {
      await _tts.stop();
      // Simple language detection for Sinhala characters (Unicode range 0D80-0DFF)
      final bool isSinhala = RegExp(r'[\u0D80-\u0DFF]').hasMatch(text);
      await _tts.setLanguage(isSinhala ? 'si-LK' : 'en-US');
      await _tts.setSpeechRate(0.5);
      if (mounted) setState(() => _currentlySpeakingId = id);
      await _tts.speak(text);
    }
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFCFAF7),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 20, color: Color(0xFFC9A84C)),
            SizedBox(width: 8),
            Text('AI CURATOR', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) return _buildTypingIndicator();
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
                if (_messages.length <= 2) _buildSuggestionsBar(),
                _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildSuggestionsBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _quickSuggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: const Color(0xFFC9A84C).withValues(alpha: 0.12),
              side: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              label: Text(
                suggestion,
                style: const TextStyle(fontSize: 12, color: Color(0xFFC9A84C), fontWeight: FontWeight.bold),
              ),
              onPressed: () => _sendMessage(suggestion),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(_Message message) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSpeakingThis = _currentlySpeakingId == message.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 10, top: 4),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF2C1810),
                radius: 16,
                child: Icon(Icons.auto_awesome, size: 16, color: Color(0xFFC9A84C)),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2C1810)
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFFC9A84C).withValues(alpha: 0.3)
                      : (isDark ? Colors.white10 : Colors.brown.shade50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => _speakMessage(message.id, message.text),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSpeakingThis ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                                  size: 18,
                                  color: const Color(0xFFC9A84C),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSpeakingThis ? 'Stop' : 'Listen',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFFC9A84C), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() => Padding(
        padding: const EdgeInsets.only(left: 44, bottom: 20),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC9A84C)),
            ),
            const SizedBox(width: 10),
            Text(
              'Curator is contemplating...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );

  Widget _buildInputBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask your Curator...',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: () => _sendMessage(_controller.text),
            icon: const Icon(Icons.send_rounded, size: 20, color: Color(0xFF2C1810)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFC9A84C),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String id;
  final String text;
  final bool isUser;
  _Message({required this.id, required this.text, required this.isUser});
}
