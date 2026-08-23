import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({Key? key}) : super(key: key);

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

     String apiUrl = '$baseUrl/change-password'; 
      final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('auth_token'); 
   
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'تم تحديث كلمة المرور بنجاح!', textAlign: TextAlign.center)),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 422) {
        String errorMessage = 'فشل التحديث، تحقق من البيانات';
        if (data['errors'] != null) {
          var firstError = data['errors'].values.first;
          errorMessage = firstError is List ? firstError.first : firstError.toString();
        }
        _showErrorSnackBar(errorMessage);
      } else {
        _showErrorSnackBar('حدث خطأ غير متوقع في السيرفر');
      }
    } catch (e) {
      _showErrorSnackBar('تعذر الاتصال بالخادم، تفقد الإنترنت');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18), 
                        onPressed: () => Navigator.pop(context)),
                    const Text('أمن الحساب والحماية', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'كلمة المرور الحالية', labelStyle: TextStyle(color: AppColors.primaryGold)),
                            validator: (value) => value!.isEmpty ? 'يرجى إدخال كلمة المرور الحالية' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة', labelStyle: TextStyle(color: AppColors.primaryGold)),
                            validator: (value) {
                              if (value!.isEmpty) return 'يرجى إدخال كلمة المرور الجديدة';
                              if (value.length < 8) return 'يجب أن لا تقل عن 8 أحرف';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                           TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة', labelStyle: TextStyle(color: AppColors.primaryGold)),
                            validator: (value) {
                              if (value!.isEmpty) return 'يرجى تأكيد كلمة المرور الجديدة';
                              if (value != _newPasswordController.text) return 'كلمتا المرور غير متطابقتين';
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                              onPressed: _isLoading ? null : _updatePassword,
                              child: _isLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.backgroundNavy, strokeWidth: 2))
                                  : const Text('تحديث كلمة المرور', style: TextStyle(color: AppColors.backgroundNavy, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}