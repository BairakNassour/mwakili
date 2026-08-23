import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/component/general_url.dart';
import 'package:mwakili/view/lawer/chat/lawyer_chat_detail_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LawyerChatsListView extends StatefulWidget {
  const LawyerChatsListView({Key? key}) : super(key: key);

  @override
  State<LawyerChatsListView> createState() => _LawyerChatsListViewState();
}

class _LawyerChatsListViewState extends State<LawyerChatsListView> {
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

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            _activeChats = jsonData['data'];
          });
        }
      } else {
        _showErrorSnackBar("فشل في تحديث قائمة المحادثات");
      }
    } catch (e) {
      _showErrorSnackBar("حدث خطأ في الاتصال بالشبكة: $e");
    } finally {
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
          'محادثات الموكلين',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        actions: [
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
                              'لا توجد محادثات نشطة مع موكلين حالياً',
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
                          
                          final int clientId = chat['id'] ?? 0;
                          final String clientName = chat['name'] ?? "موكل نشط";
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
                                  clientName.isNotEmpty ? clientName.substring(0, 1) : "ع",
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
                                    clientName,
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
                                    builder: (context) => LawyerChatDetailView(
                                      clientName: clientName,
                                      isOnline: chat['isOnline'] ?? false,
                                      clientId: clientId, 
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