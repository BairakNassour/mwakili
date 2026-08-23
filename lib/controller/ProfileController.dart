import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:mwakili/model/LawyerModel.dart';
import 'package:mwakili/model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController {

  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); 
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _getPublicHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشل تحديث البيانات'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير متوقع: $e'};
    }
  }
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        UserModel user = UserModel.fromJson(responseData['data']);
        return {'success': true, 'data': user};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشل جلب البيانات'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال بالسيرفر: $e'};
    }
  }


Future<Map<String, dynamic>> updateLawyerProfile({
  required String name,
  required String title,
  required String phone,
  required String email,
}) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$baseUrl/lawyer/profile/update'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'title': title,
        'phone': phone,
        'email': email,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      return {'success': true, 'message': responseData['message']};
    } else {
      return {'success': false, 'message': responseData['message'] ?? 'فشل تحديث البيانات'};
    }
  } catch (e) {
    return {'success': false, 'message': 'حدث خطأ غير متوقع: $e'};
  }
}
Future<Map<String, dynamic>> getLawyerProfile() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/lawyer/profile'), 
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    return responseData;
  } catch (e) {
    print("Error fetching profile: $e"); 
    return {'success': false, 'message': 'خطأ في معالجة البيانات من السيرفر'};
  }
}

  Future<Map<String, dynamic>> getAllLawyers() async {
    try {
      final headers = _getPublicHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lawyers'),
        headers: headers,
      );
      print(response.body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<LawyerModel> lawyers = (responseData['data'] as List)
            .map((item) => LawyerModel.fromJson(item))
            .toList();
            
        return {'success': true, 'data': lawyers};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'فشل جلب قائمة المحامين'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال بالسيرفر: $e'};
    }
  }
}