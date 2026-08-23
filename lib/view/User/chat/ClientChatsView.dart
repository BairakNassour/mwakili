import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/component/general_url.dart';
import 'package:mwakili/view/User/chat/user_chat_detail_view.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class ClientChatsView extends StatefulWidget {
  const ClientChatsView({Key? key}) : super(key: key);

  @override
  State<ClientChatsView> createState() => _ClientChatsViewState();
}

class _ClientChatsViewState extends State<ClientChatsView> {
  bool _isLoading = false;
  List<dynamic> _activeChats = []; 

  @override
  void initState() {
    super.initState();
    _fetchActiveChats(); 
  }

  Future<void> _fetchActiveChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

    print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            _activeChats = jsonData['data'];
          });
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        _showErrorSnackBar("فشل في تحديث قائمة المحادثات");
         setState(() {
            _isLoading = false;
          });
      }
    } catch (e) {
      _showErrorSnackBar("حدث خطأ في الاتصال بالشبكة: $e");
       setState(() {
            _isLoading = false;
          });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: const Color(0xFF131F33),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الرسائل والمحادثات',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGold),
            tooltip: 'مساعد ذكي',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            onPressed: _fetchActiveChats,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                  )
                : _activeChats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 70,
                              color: AppColors.textLightGray.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد محادثات جارية حالياً',
                              style: TextStyle(
                                color: AppColors.textLightGray.withOpacity(0.6),
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        itemCount: _activeChats.length,
                        itemBuilder: (context, index) {
                          final chat = _activeChats[index];
                          
                          final int lawyerId = chat['id'] ?? 0;
                          final String lawyerName = chat['name'] ?? "المستشار القانوني";
                          final String lastMsg = chat['lastMsg'] ?? "";
                          final String time = chat['time'] ?? "";
                          final int unreadCount = chat['unreadCount'] ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F314D),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.textWhite.withOpacity(0.03),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF131F33),
                                child: Text(
                                  lawyerName.isNotEmpty ? lawyerName.substring(0, 1) : "م",
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lawyerName,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: AppColors.textLightGray.withOpacity(0.3),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMsg,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.textLightGray.withOpacity(0.5),
                                          fontSize: 12,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                    if (unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryGold,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: AppColors.backgroundNavy,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserChatDetailView(
                                      clientName: lawyerName,
                                      isOnline: chat['isOnline'] ?? false,
                                      lawyerId: lawyerId, 
                                    ),
                                  ),
                                ).then((_) => _fetchActiveChats()); 
                              },
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}

class AiChatView extends StatefulWidget {
  const AiChatView({Key? key}) : super(key: key);

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "مرحباً بك! أنا مساعدك الذكي الخاص بتطبيق موكلي.", "isMe": false}
  ];

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isMe": true});
    });
    _messageController.clear();

    String botResponse = "";
    String normalizedText = text.toLowerCase();
    
    if (normalizedText.contains("سلام") || 
        normalizedText.contains("مرحبا") || 
        normalizedText.contains("اهلا") || 
        normalizedText.contains("السلام عليكم")) {
      botResponse = "عليكم السلام تفضل انا موكلي";
    } else {
      botResponse = "يجب تفعيل مفتاح الذكاء لكي يعمل";
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({"text": botResponse, "isMe": false});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundNavy,
        appBar: AppBar(
          backgroundColor: const Color(0xFF131F33),
          title: const Text('بوت موكلي الذكي', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    bool isMe = msg['isMe'];
                    return Align(
                      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryGold : const Color(0xFF1F314D),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(0) : const Radius.circular(12),
                            bottomRight: isMe ? const Radius.circular(12) : const Radius.circular(0),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isMe ? AppColors.backgroundNavy : AppColors.textWhite,
                            fontFamily: 'Cairo',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: const Color(0xFF131F33),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالتك هنا...',
                          hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primaryGold),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}