import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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

  late final GenerativeModel _model;
  late final ChatSession _chat;

  final String _museumContext = '''
You are a friendly and knowledgeable museum guide assistant for ArtSphere Guide museum.
You help visitors learn about the museum artifacts and exhibitions.
Here are the artifacts in our museum:

ROMAN EMPIRE SECTION:
1. Augustus of Prima Porta (20 BC)
   - A marble statue of Emperor Augustus in military dress
   - Discovered in 1863 at the Villa of Livia at Prima Porta, near Rome
   - Standing 2.08 metres tall with right arm raised
   - Currently housed in the Vatican Museums

2. Augustus Sphinx Ring (30 BC - 14 AD)
   - A golden signet ring bearing the sphinx symbol of Augustus
   - Used to authenticate imperial documents and letters
   - Augustus used three different seals during his reign

3. Equestrian Statue of Marcus Aurelius (161-180 AD)
   - Bronze equestrian statue of Emperor Marcus Aurelius
   - One of the few surviving bronze statues from ancient Rome
   - Located on the Capitoline Hill in Rome

4. Mythological Reliefs (1st-2nd Century AD)
   - Stone relief carvings depicting Roman mythological scenes
   - Used to decorate temples, public buildings and sarcophagi

5. Portable Sundial (200-400 AD)
   - A small portable bronze sundial used by Roman travellers
   - Calibrated for different latitudes
   - Shows sophisticated Roman understanding of astronomy

6. Scutum (100 BC - 400 AD)
   - The large rectangular shield of Roman legionary soldiers
   - Made from sheets of wood covered with canvas and leather
   - Soldiers interlocked shields to form the famous testudo formation

7. Terra Sigillata (50 BC - 150 AD)
   - High quality red gloss Roman pottery
   - Premium tableware of the Roman world
   - Found at archaeological sites from Britain to the Middle East

ANCIENT SRI LANKA SECTION:
8. Kastane Sword (16th-17th Century)
   - Ceremonial sword of the Kandyan Kingdom
   - Richly engraved silver sword encrusted with rubies
   - Used as a ceremonial weapon symbolizing military and royal status

9. Nataraja Bronze (Polonnaruwa Period)
   - Represents the Hindu god Shiva in a cosmic dance
   - Reflects Hindu influences during the medieval Polonnaruwa period
   - Represents Shiva performing the cosmic dance of creation and destruction

10. Tholuwila Buddha (4th-5th Century AD)
    - A 1.75m crystalline limestone Buddha statue
    - Discovered in 1900
    - One of the most important Buddhist sculptures from Sri Lanka

11. Royal Crown of Sri Vikrama Rajasinha (Kandyan Kingdom)
    - Crown of the last king of the Kandyan Kingdom
    - Before British rule in Sri Lanka

12. Throne of the Kingdom of Kandy (Created in 1693)
    - Ceremonial throne gifted by the Dutch to King Wimaladharmasuriya II
    - Symbol of royal power in the Kandyan Kingdom

Museum sections: Roman Empire, Ancient Sri Lanka.
Always be friendly, informative and enthusiastic about history.
Keep answers concise and easy to understand for museum visitors.
If asked about something outside the museum, politely redirect to the exhibits.
Respond in the same language the visitor uses (English or Sinhala).
''';

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.system(_museumContext),
    );
    _chat = _model.startChat();
    _messages.add(_Message(
      text: 'Hello! 👋 I am your ArtSphere Guide assistant. Ask me anything about our exhibits — the Roman Empire collection or Ancient Sri Lanka artifacts. How can I help you today?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final reply = response.text ?? 'Sorry, I could not understand that.';
      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message(
          text: 'Sorry, I am having trouble connecting. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏛️ Museum Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.brown[700] : Colors.brown[50],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.brown[900],
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.brown[400],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask about our exhibits...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              onSubmitted: _sendMessage,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.brown[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}
