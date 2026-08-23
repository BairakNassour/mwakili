import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart'; 
import 'package:mwakili/model/LawyerDashboardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LawyerDashboardController {
  
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); 
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lawyer/dashboard'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        LawyerDashboardModel data = LawyerDashboardModel.fromJson(responseData['data']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشل جلب بيانات لوحة التحكم'};
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }
}