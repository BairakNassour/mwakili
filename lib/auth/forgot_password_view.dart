import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/auth_controller.dart';
import 'verify_code_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLawyer = false;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authController.forgotPassword(
      email: _emailController.text.trim(),
      isLawyer: _isLawyer,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'تم إرسال الرمز بنجاح!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCodeView(
            email: _emailController.text.trim(),
            isLawyer: _isLawyer,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text('نسيت كلمة المرور', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني', labelStyle: TextStyle(color: AppColors.primaryGold)),
                      validator: (value) => value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('هل أنت محامي؟', style: TextStyle(color: Colors.white)),
                      value: _isLawyer,
                      activeColor: AppColors.primaryGold,
                      onChanged: (bool value) => setState(() => _isLawyer = value),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.backgroundNavy, strokeWidth: 2))
                            : const Text('إرسال كود التحقق', style: TextStyle(color: AppColors.backgroundNavy, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}