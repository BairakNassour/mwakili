import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio_package;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart'; 
import 'package:mwakili/model/ConsultationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientArchiveController {
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getClientConsultations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/consultations'),
        headers: headers,
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        List<ConsultationModel> consultations = (responseData['data'] as List)
            .map((item) => ConsultationModel.fromJson(item))
            .toList();
        return {'success': true, 'data': consultations};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل جلب الأرشيف',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال بالسيرفر: $e'};
    }
  }

  Future<File?> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<bool> uploadNewAttachment({
    required BuildContext context,
    required int consultationId,
    required File file,
  }) async {
    print('--- [بدء عملية الرفع] ---');
    print('رابط الطلب: $baseUrl/consultations/add-attachment');
    print('رقم الاستشارة المرسل: $consultationId');
    print('مسار الملف المحلي: ${file.path}');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      dio_package.Dio dio = dio_package.Dio();

      dio_package.FormData formData = dio_package.FormData.fromMap({
        "consultation_id": consultationId,
        "file": await dio_package.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      dio_package.Response response = await dio.post(
        "$baseUrl/consultations/$consultationId/attachments",
        data: formData,
        options: dio_package.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print('=== [نجاح الطلب من السيرفر] ===');
      print('كود الحالة (Status Code): ${response.statusCode}');
      print('جسم الاستجابة (Response Data): ${response.data}');
      print('=================================');

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم رفع المستند الجديد بنجاح!',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return true;
      }
      return false;
    } on dio_package.DioException catch (dioError) {
      print('❌❌❌ [خطأ شبكة DioException] ❌❌❌');
      print('نوع خطأ Dio: ${dioError.type}');
      if (dioError.response != null) {
        print('كود حالة الخطأ (Status Code): ${dioError.response?.statusCode}');
        print(
          'بيانات الخطأ من السيرفر (Response Error Data): ${dioError.response?.data}',
        );
        print('هيدرز الخطأ (Response Headers): ${dioError.response?.headers}');
      } else {
        print('الرسالة (Message): ${dioError.message}');
      }
      print('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ من السيرفر: ${dioError.response?.data['message'] ?? dioError.message}',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return false;
    } catch (e) {
      print('⚠️⚠️⚠️ [خطأ عام غير متوقع] ⚠️⚠️⚠️');
      print(e);
      print('⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء رفع الملف: $e', textAlign: TextAlign.center),
        ),
      );
      return false;
    }
  }
}
