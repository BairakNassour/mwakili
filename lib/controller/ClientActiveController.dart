import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:mwakili/model/ConsultationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientActiveController {
  
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ConsultationModel>> fetchActiveConsultations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/client/active-consultations'),
        headers: headers,
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> data = responseData['data'];
        return data.map((json) => ConsultationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching active consultations: $e");
      return [];
    }
  }

  Future<bool> bookAppointment({
    required BuildContext context,
    required int consultationId,
    required String date,
    required String time,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/client/consultations/$consultationId/book-appointment'),
        headers: headers,
        body: json.encode({
          'appointment_date': date,
          'appointment_time': time,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201 && responseData['success'] == true) {
        return true;
      } else {
        String errorMsg = responseData['message'] ?? 'حدث خطأ ما';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg, textAlign: TextAlign.center)),
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error booking appointment: $e");
      return false;
    }
  }
}