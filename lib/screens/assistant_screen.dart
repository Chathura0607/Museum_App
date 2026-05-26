import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = false;
  bool _isInitializing = true;

  GenerativeModel? _model;
  ChatSession? _chat;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('artifacts').get();
      String artifactData = snapshot.docs.map((doc) => "- ${doc['name']} (${doc['period']}): ${doc['description']}").join('\n');
      final systemContext = "You are a friendly museum guide for ArtSphere. Only talk about these exhibits:\n$artifactData";
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: AppConfig.geminiApiKey, systemInstruction: Content.system(systemContext));
      _chat = _model!.startChat();
      _messages.add(_Message(text: "Greeting! I am your AI Curator. How can I assist your exploration today?", isUser: false));
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _chat == null) return;
    setState(() { _messages.add(_Message(text: text, isUser: true)); _isLoading = true; });
    _controller.clear();
    _scrollToBottom();
    try {
      final response = await _chat!.sendMessage(Content.text(text));
      if (mounted) setState(() { _messages.add(_Message(text: response.text ?? '...', isUser: false)); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _messages.add(_Message(text: "I encountered a connection glitch. Please try again.", isUser: false)); _isLoading = false; });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) { if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(title: const Text('AI CURATOR', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.w900))),
      body: _isInitializing ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) => index == _messages.length ? _buildTypingIndicator() : _buildMessageBubble(_messages[index]),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_Message message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) Container(margin: const EdgeInsets.only(right: 12), child: CircleAvatar(backgroundColor: const Color(0xFF2C1810), radius: 14, child: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFC9A84C)))),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF2C1810) : Colors.white,
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Text(message.text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() => Padding(padding: const EdgeInsets.only(left: 40, bottom: 20), child: Row(children: [Text('AI is reflecting...', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontStyle: FontStyle.italic))]));

  Widget _buildInputBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
    child: Row(children: [
      Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Ask your Curator...', filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20)))),
      const SizedBox(width: 12),
      IconButton.filled(onPressed: () => _sendMessage(_controller.text), icon: const Icon(Icons.send_rounded, size: 20, color: Color(0xFFC9A84C)), style: IconButton.styleFrom(backgroundColor: const Color(0xFF2C1810))),
    ]),
  );
}

class _Message { final String text; final bool isUser; _Message({required this.text, required this.isUser}); }
