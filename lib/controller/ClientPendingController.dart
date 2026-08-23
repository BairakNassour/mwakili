import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientPendingController {
  
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> fetchPendingRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/client/pending-consultations'),
        headers: headers,
      );
      print(response.body);

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateRequestStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/client/consultations/$id/respond'),
        headers: headers,
        body: json.encode({'status': status}),
      );
     print(response.body);
      final responseData = json.decode(response.body);
      return response.statusCode == 200 && responseData['success'] == true;
    } catch (e) {
      return false;
    }
  }
}