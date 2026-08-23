import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/AppointmentModel.dart';

class AppointmentController {
  bool isLoadingLawyer = false;
  bool isLoadingUser = false;
  bool isAddingAppointment = false;

  List<AppointmentModel> lawyerAppointments = [];
  List<AppointmentModel> userAppointments = [];

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchLawyerAppointments(BuildContext context) async {
    isLoadingLawyer = true;
    try {
      String? token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/lawyer/appointments'),
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
          lawyerAppointments = data.map((e) => AppointmentModel.fromJson(e)).toList();
        }
      } else {
        _showSnackBar(context, "فشل في جلب مواعيد المحامي من السيرفر");
      }
    } catch (e) {
      _showSnackBar(context, "حدث خطأ غير متوقع أثناء جلب مواعيد المحامي: $e");
    } finally {
      isLoadingLawyer = false;
    }
  }

  Future<void> fetchUserAppointments(BuildContext context) async {
    isLoadingUser = true;
    try {
      String? token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
       if (jsonData['success'] == true){
          List data = jsonData['data'];
          userAppointments = data.map((e) => AppointmentModel.fromJson(e)).toList();
        }
      } else {
        _showSnackBar(context, "فشل في جلب مواعيد المستخدم من السيرفر");
      }
    } catch (e) {
      _showSnackBar(context, "حدث خطأ غير متوقع أثناء جلب مواعيد المستخدم: $e");
    } finally {
      isLoadingUser = false;
    }
  }
  Future<bool> createAppointment({
    required BuildContext context,
    required int consultationId,
    required String date, 
    required String time, 
  }) async {
    isAddingAppointment = true;
    try {
      String? token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'consultation_id': consultationId,
          'appointment_date': date,
          'appointment_time': time,
        }),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201 && jsonData['status'] == true) {
        _showSnackBar(context, jsonData['message'] ?? "تم إضافة الموعد بنجاح", isSuccess: true);
        return true;
      } else {
        _showSnackBar(context, jsonData['message'] ?? "فشل في إضافة الموعد");
        return false;
      }
    } catch (e) {
      _showSnackBar(context, "حدث خطأ أثناء إضافة الموعد: $e");
      return false;
    } finally {
      isAddingAppointment = false;
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }
}