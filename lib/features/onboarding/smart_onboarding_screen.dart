import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/groq_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/routes/app_routes.dart';

class SmartOnboardingScreen extends StatefulWidget {
  const SmartOnboardingScreen({super.key});

  @override
  State<SmartOnboardingScreen> createState() => _SmartOnboardingScreenState();
}

class _SmartOnboardingScreenState extends State<SmartOnboardingScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroqService _groqService = GroqService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _startConversation() async {
    setState(() => _isTyping = true);
    
    // Initial AI message
    const initialPrompt = "You are Agrivision AI assistant. Start a friendly onboarding conversation with a farmer. "
        "Introduce yourself briefly and ask them: 'I see you're starting your journey with Agrivision360. "
        "To help you better, could you tell me what crops you are currently growing and which city you are located in?'";
    
    try {
      final response = await _groqService.sendMessageToGroq(initialPrompt);
      if (mounted) {
        setState(() {
          _messages.add({"role": "assistant", "content": response});
          _isTyping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "assistant", "content": "Hello! I'm your Agrivision AI. Let's get your farm set up. What crops are you growing and where is your farm located?"});
          _isTyping = false;
        });
      }
    }
  }

  void _handleSendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _groqService.sendMessageToGroq(text);
      if (mounted) {
        setState(() {
          _messages.add({"role": "assistant", "content": response});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
       if (mounted) {
        setState(() {
          _messages.add({"role": "assistant", "content": "I'm having a little trouble connecting. But don't worry, we can continue setting up your profile!"});
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final isDark = Provider.of<ThemeService>(context).isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1B5E20), const Color(0xFF0A1F0B), Colors.black]
                : [const Color(0xFF2E7D32), const Color(0xFFF1F8E9), Colors.white],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildChatBubble(msg["content"], msg["role"] == "user", isDark);
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                      ),
                      SizedBox(width: 10),
                      Text("Agrivision AI is typing...", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              _buildInputArea(isDark),
              _buildSkipButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.greenAccent.withOpacity(0.2),
            child: const Icon(Icons.psychology, color: Colors.greenAccent),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Smart Setup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("AI Assistant", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser 
              ? Colors.green.shade700 
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            onPressed: _handleSendMessage,
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.send, color: Colors.green, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
      child: const Text(
        "Complete Setup & Enter Dashboard",
        style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
      ),
    );
  }
}
