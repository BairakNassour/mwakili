import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MessageModel.dart';

class ChatController extends ChangeNotifier {

  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;

  List<MessageModel> _messages = [];

  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  List<MessageModel> get messages => _messages;

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchMessages(BuildContext context, int otherUserId) async {
    _isLoadingMessages = true;
    notifyListeners();

    try {
      String? token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/chats/$otherUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          List data = jsonData['data'];
          _messages = data.map((msg) => MessageModel.fromJson(msg)).toList();
        }
      } else {
        _showSnackBar(context, "فشل في تحميل المحادثة من السيرفر");
      }
    } catch (e) {
      _showSnackBar(context, "حدث خطأ أثناء تحميل الرسائل: $e");
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required BuildContext context,
    required int receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return false;

    _isSendingMessage = true;
    notifyListeners();

    try {
      String? token = await _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/chats/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'receiver_id': receiverId,
          'message': text.trim(),
        }),
      );

      final jsonData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && jsonData['success'] == true) {
         MessageModel newMsg = MessageModel.fromJson(jsonData['data']);
        _messages.add(newMsg);
        return true;
      } else {
        _showSnackBar(context, jsonData['message'] ?? "فشل في إرسال الرسالة");
        return false;
      }
    } catch (e) {
      _showSnackBar(context, "خطأ في الاتصال بالشبكة: $e");
      return false;
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}