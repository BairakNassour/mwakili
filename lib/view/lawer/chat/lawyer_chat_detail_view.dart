import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/component/general_url.dart';
import 'package:mwakili/model/MessageModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LawyerChatDetailView extends StatefulWidget {
  final String clientName;
  final bool isOnline;
  final int clientId;

  const LawyerChatDetailView({
    Key? key,
    required this.clientName,
    required this.isOnline,
    required this.clientId,
  }) : super(key: key);

  @override
  State<LawyerChatDetailView> createState() => _LawyerChatDetailViewState();
}

class _LawyerChatDetailViewState extends State<LawyerChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> _messages = [];
  bool _isLoadingMessages = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchChatMessages();
  }

  Future<void> _fetchChatMessages() async {
    setState(() {
      _isLoadingMessages = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

       final response = await http.get(
        Uri.parse('$baseUrl/chats/${widget.clientId}?receiver_type=user'),
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
          List data = jsonData['data'];
          setState(() {
            _messages = data.map((msg) => MessageModel.fromJson(msg)).toList();
          });
          _scrollToBottom();
        }
      } else {
        _showSnackBar("فشل في تحميل المحادثة");
      }
    } catch (e) {
      _showSnackBar("حدث خطأ أثناء تحميل الرسائل: $e");
    } finally {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/chats/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'receiver_id': widget.clientId,
          'receiver_type': 'user',
          'message': text,
        }),
      );

      final jsonData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && jsonData['success'] == true) {
        setState(() {
          _messages.add(MessageModel.fromJson(jsonData['data']));
          _messageController.clear();
        });
        _scrollToBottom();
      } else {
        _showSnackBar(jsonData['message'] ?? "فشل في إرسال الرسالة");
      }
    } catch (e) {
      _showSnackBar("خطأ في الاتصال بالشبكة: $e");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildChatAppBar(context),
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.025,
                          child: const Icon(Icons.balance, size: 280, color: AppColors.textWhite),
                        ),
                      ),
                      _isLoadingMessages
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return _buildMessageBubble(msg.text, msg.isMe, msg.time);
                              },
                            ),
                    ],
                  ),
                ),
                _buildMessageInputField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131F33),
        border: Border(bottom: BorderSide(color: AppColors.textWhite.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1F314D),
            child: Text(
              widget.clientName.isNotEmpty ? widget.clientName.substring(0, 1) : "ع",
              style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.clientName, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 2),
                Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: widget.isOnline ? const Color(0xFF2ECC71) : Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      widget.isOnline ? 'متصل الآن' : 'غير متصل',
                      style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11, fontFamily: 'Cairo'),
                    ),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_in_talk_outlined, color: AppColors.primaryGold, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textWhite, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1B4F72) : const Color(0xFF1F314D),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isMe ? Radius.zero : const Radius.circular(14),
            bottomRight: isMe ? const Radius.circular(14) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, height: 1.4, fontFamily: 'Cairo')),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                time,
                style: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131F33),
        border: Border(top: BorderSide(color: AppColors.textWhite.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1F314D),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.sentiment_satisfied_alt_outlined, color: AppColors.textLightGray.withOpacity(0.4)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك القانونية هنا...',
                        hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 13, fontFamily: 'Cairo'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.attach_file_rounded, color: AppColors.textLightGray.withOpacity(0.4)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundNavy)),
                    )
                  : const Icon(Icons.send_rounded, color: AppColors.backgroundNavy, size: 20),
              onPressed: _sendMessage,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}