import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingController {
 
  Future<bool> submitRating({
    required int consultationId,
    required int lawyerId,
    required int rating,
    String? review,
  }) async {
    try {
       final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('$baseUrl/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'consultation_id': consultationId,
          'lawyer_id': lawyerId,
          'rating': rating,
          'review': review,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('خطأ في التقييم: ${response.body}');
        return false;
      }
    } catch (e) {
      print('استثناء أثناء إرسال التقييم: $e');
      return false;
    }
  }

  Future<bool> checkConsultationRating(int consultationId) async {
    try {
       final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('$baseUrl/ratings/consultation/$consultationId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_rated'] ?? false;
      }
      return false;
    } catch (e) {
      print('خطأ في جلب حالة التقييم: $e');
      return false;
    }
  }
}