import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ConsultationModel.dart';

class LawyerConsultationController extends ChangeNotifier {

  bool _isLoading = false;
  bool _isAddingAppointmentLoading = false;

  List<ConsultationModel> _lawyerConsultations = [];

  bool get isLoading => _isLoading;
  bool get isAddingAppointmentLoading => _isAddingAppointmentLoading;
  List<ConsultationModel> get lawyerConsultations => _lawyerConsultations;

  Future<void> fetchLawyerConsultations(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); 
  
      final response = await http.get(
        Uri.parse('$baseUrl/lawyer/consultations'),
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
        _lawyerConsultations = data
              .map((consultation) => ConsultationModel.fromJson(consultation))
              .toList();
        }
      } else {
        _showSnackBar(context, "خطأ: فشل في جلب بيانات المحامي من السيرفر");
      }
    } catch (e) {
      _showSnackBar(context, "حدث خطأ غير متوقع: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  Future<bool> addAppointmentByLawyer({
    required BuildContext context,
    required int consultationId,
    required String date, 
    required String time, 
  }) async {
    _isAddingAppointmentLoading = true;
    notifyListeners();

    try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); 
  
      final response = await http.post(
        Uri.parse('$baseUrl/lawyer/consultations/$consultationId/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'appointment_date': date,
          'appointment_time': time,
        }),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201 && jsonData['success'] == true) {
        _showSnackBar(context, jsonData['message'] ?? "تم إضافة الموعد بنجاح", isSuccess: true);
        
        fetchLawyerConsultations(context);
        return true;
      } else {
        _showSnackBar(context, jsonData['message'] ?? "فشل في إضافة الموعد");
        return false;
      }
    } catch (e) {
      _showSnackBar(context, "حدث خطأ أثناء إضافة الموعد: $e");
      return false;
    } finally {
      _isAddingAppointmentLoading = false;
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}