import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/register/user",
        data: {
          "name": name,
          "email": email,
          "fcm_token": phone.toString(),
          "phone": phone,
          "password": password,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 201) {
        String token = response.data['token'];
        await _saveSession(token, "user"); 
        return {"success": true, "data": response.data};
      }
      return {"success": false, "message": "حدث خطأ غير متوقع"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> registerLawyer({
    required String name,
    required String email,
    required String phone,
    required String licenseNumber,
    required double consultationPrice,
    required String experienceYears,
    required List<String> specialties,
    required String password,
    File? avatarFile,
    File? licenseFile,
    File? syndicateCardFile,
  }) async {
    try {
      Map<String, dynamic> dataMap = {
        "name": name,
        "email": email,
        "phone": phone,
        "fcm_token": phone.toString(),
        "license_number": licenseNumber,
        "consultation_price": consultationPrice,
        "experience_years": experienceYears,
        "password": password,
      };

      for (int i = 0; i < specialties.length; i++) {
        dataMap["specialties[$i]"] = specialties[i];
      }

      if (avatarFile != null) {
        dataMap["avatar"] = await MultipartFile.fromFile(avatarFile.path, filename: "avatar.jpg");
      }
      if (licenseFile != null) {
        dataMap["license_file"] = await MultipartFile.fromFile(licenseFile.path, filename: "license.pdf");
      }
      if (syndicateCardFile != null) {
        dataMap["syndicate_card"] = await MultipartFile.fromFile(syndicateCardFile.path, filename: "syndicate.jpg");
      }

      FormData formData = FormData.fromMap(dataMap);

      Response response = await _dio.post(
        "$baseUrl/register/lawyer",
        data: formData,
        options: Options(headers: {"Accept": "application/json"}),
      );
      print(response.data);
      if (response.statusCode == 201) {
        String token = response.data['token'];
        await _saveSession(token, "lawyer"); 
        return {"success": true, "data": response.data};
      }
      return {"success": false, "message": "حدث خطأ غير متوقع"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required bool isLawyer, 
  }) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/login",
        data: {
          "email": email,
          "password": password,
          "is_lawyer": isLawyer ? 1 : 0,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );
      print(response.data);
      if (response.statusCode == 200) {
        String token = response.data['token'];
        String role = response.data['role']; 
        await _saveSession(token, role);
        return {"success": true, "role": role, "data": response.data};
      }
      return {"success": false, "message": "فشل تسجيل الدخول"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required bool isLawyer,
  }) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/forgot-password",
        data: {
          "email": email,
          "is_lawyer": isLawyer ? 1 : 0,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": response.data['message']};
      }
      return {"success": false, "message": "فشل إرسال كود التحقق"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/verify-code",
        data: {
          "email": email,
          "code": code,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": response.data['message']};
      }
      return {"success": false, "message": "الكود المدخل غير صحيح"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
    required bool isLawyer,
  }) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/reset-password",
        data: {
          "email": email,
          "code": code,
          "password": password,
          "password_confirmation": passwordConfirmation,
          "is_lawyer": isLawyer ? 1 : 0,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": response.data['message']};
      }
      return {"success": false, "message": "فشل تعيين كلمة المرور الجديدة"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<void> _saveSession(String token, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setString("user_role", role);
  }

  Map<String, dynamic> _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      print(e.response);
      if (e.response?.statusCode == 422) {
        Map<String, dynamic> errors = e.response?.data['errors'];
        String firstError = errors.values.first[0].toString();
        return {"success": false, "message": firstError};
      }
      if (e.response?.data['message'] != null) {
        return {"success": false, "message": e.response?.data['message']};
      }
    }
    return {"success": false, "message": "خطأ في الاتصال بالسيرفر، تحقق من الإنترنت"};
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_role");
  }

  // دالة لتحديث الصورة الشخصية
  Future<Map<String, dynamic>> updateAvatar(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      FormData formData = FormData.fromMap({
        "avatar": await MultipartFile.fromFile(
          imageFile.path,
          filename: "avatar.jpg",
        ),
      });

      Response response = await _dio.post(
        "$baseUrl/update-avatar",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": response.data['data'], "message": response.data['message']};
      }
      return {"success": false, "message": "حدث خطأ غير متوقع"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // 1. تابع حذف حساب المستخدم العادي
  Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      Response response = await _dio.delete(
        "$baseUrl/user/delete-account",
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        await logout(); // مسح البيانات المخزنة محلياً عند نجاح الحذف
        return {"success": true, "message": response.data['message']};
      }
      return {"success": false, "message": "فشل حذف الحساب"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // 2. تابع حذف حساب المحامي
  Future<Map<String, dynamic>> deleteLawyerAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      Response response = await _dio.delete(
        "$baseUrl/lawyer/delete-account",
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        await logout(); // مسح البيانات المخزنة محلياً عند نجاح الحذف
        return {"success": true, "message": response.data['message']};
      }
      return {"success": false, "message": "فشل حذف الحساب"};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }
}