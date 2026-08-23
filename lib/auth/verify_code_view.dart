import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/auth_controller.dart';
import 'reset_password_view.dart';

class VerifyCodeView extends StatefulWidget {
  final String email;
  final bool isLawyer;

  const VerifyCodeView({Key? key, required this.email, required this.isLawyer}) : super(key: key);

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authController.verifyCode(
      email: widget.email,
      code: _codeController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordView(
            email: widget.email,
            code: _codeController.text.trim(),
            isLawyer: widget.isLawyer,
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
                      const Text('تأكيد رمز التحقق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 20),
                    Text('تم إرسال رمز إلى \n${widget.email}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 6),
                      decoration: const InputDecoration(hintText: '******', hintStyle: TextStyle(color: Colors.grey), labelText: 'أدخل رمز الـ OTP', labelStyle: TextStyle(color: AppColors.primaryGold)),
                      validator: (value) => value!.isEmpty ? 'يرجى إدخال الكود' : null,
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
                            : const Text('التحقق من الرمز', style: TextStyle(color: AppColors.backgroundNavy, fontWeight: FontWeight.bold)),
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