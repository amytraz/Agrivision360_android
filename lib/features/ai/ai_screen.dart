import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/groq_service.dart';
import '../../core/routes/app_routes.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Initialize the Groq Service
  final GroqService _groqService = GroqService();

  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hello! I am your AgriVision AI Assistant. How can I help you with your farm today?",
      "isUser": false,
      "time": DateFormat('hh:mm a').format(DateTime.now()),
    },
  ];

  bool _isTyping = false;

  final List<String> _suggestions = [
    "Identify a disease",
    "Wheat market prices",
    "Irrigation schedule",
    "Fertilizer advice"
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = {
      "text": text,
      "isUser": true,
      "time": DateFormat('hh:mm a').format(DateTime.now()),
    };

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final String botResponse = await _groqService.sendMessageToGroq(text);

      setState(() {
        _messages.add({
          "text": botResponse,
          "isUser": false,
          "time": DateFormat('hh:mm a').format(DateTime.now()),
        });
        _isTyping = false;
      });
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
        _scrollToBottom();
      }
    }
  }

  void _showError(String error) {
    setState(() {
      _messages.add({
        "text": "⚠️ $error",
        "isUser": false,
        "time": DateFormat('hh:mm a').format(DateTime.now()),
      });
      _isTyping = false;
    });
  }

  void _redirectToHome() {
    // Navigates back to the Dashboard (MainNavigation) and resets the stack
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return WillPopScope(
      onWillPop: () async {
        _redirectToHome();
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Agri Intelligence", 
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: _redirectToHome,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1B5E20), const Color(0xFF0A1F0B), const Color(0xFF000000)]
                  : [const Color(0xFF2E7D32), const Color(0xFFF1F8E9), const Color(0xFFFFFFFF)],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(_messages[index], isDark);
                    },
                  ),
                ),
                if (_isTyping) _buildTypingIndicator(isDark),
                _buildQuickSuggestions(isDark),
                _buildInputArea(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message, bool isDark) {
    final bool isUser = message["isUser"];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser 
                    ? const Color(0xFF2E7D32) 
                    : (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
                border: isUser ? null : Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                message["text"],
                style: TextStyle(
                  color: isUser ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
              child: Text(
                message["time"],
                style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Text("AI is generating advice...", 
              style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions(bool isDark) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              label: Text(_suggestions[index]),
              backgroundColor: isDark ? Colors.white.withOpacity(0.15) : Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
              labelStyle: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1B5E20),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.green.withOpacity(0.3)),
              ),
              onPressed: () => _sendMessage(_suggestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF050F05) : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Ask Agri Intelligence...",
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
