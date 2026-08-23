import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestConsultationController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  List<File> selectedFiles = [];
  bool isLoading = false;

  Future<void> pickFiles(VoidCallback onStateChanged) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      selectedFiles = result.paths.map((path) => File(path!)).toList();
      onStateChanged(); 
    }
  }

  void removeFile(File file, VoidCallback onStateChanged) {
    selectedFiles.remove(file);
    onStateChanged();
  }

  Future<void> submitConsultation({
    required BuildContext context,
    required int lawyerId,
    required VoidCallback onLoadingChanged,
  }) async {
    if (titleController.text.isEmpty || detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء ملء جميع الحقول المطلوبة',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    isLoading = true;
    onLoadingChanged();

    try {
      Dio dio = Dio();
      String url = "$baseUrl/consultations";

      List<MultipartFile> attachments = [];
      for (var file in selectedFiles) {
        attachments.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      FormData formData = FormData.fromMap({
        "lawyer_id": lawyerId,
        "title": titleController.text,
        "details": detailsController.text,
        "attachments[]": attachments,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
      print(response.data);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إرسال طلب الاستشارة الرسمية بنجاح!',
              textAlign: TextAlign.center,
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('eeeeeeee');
      if (e is DioException && e.response != null) {
       print("الخطأ الحقيقي من السيرفر: ${e.response?.data}");
      } else {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ داخلي في السيرفر 500',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } finally {
      isLoading = false;
      onLoadingChanged(); 
    }
  }

  void dispose() {
    titleController.dispose();
    detailsController.dispose();
  }
}
