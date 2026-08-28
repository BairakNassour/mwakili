import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart'; 
import 'package:mwakili/controller/auth_controller.dart'; 
import 'package:mwakili/view/User/main_wrapper.dart'; 

class RegisterViewUser extends StatefulWidget {
  const RegisterViewUser({Key? key}) : super(key: key);

  @override
  State<RegisterViewUser> createState() => _RegisterViewUserState();
}

class _RegisterViewUserState extends State<RegisterViewUser> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final AuthController _authController = AuthController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على شروط الخدمة وسياسة الخصوصية'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    var result = await _authController.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
       Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient, 
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl, 
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeaderSection(),
                          const SizedBox(height: 32),

                          _buildFieldLabel('الاسم الكامل'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'أدخل اسمك الثلاثي',
                            icon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال الاسم الكامل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildFieldLabel('البريد الإلكتروني'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'example@legal.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال البريد الإلكتروني';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return 'الرجاء إدخال بريد إلكتروني صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildFieldLabel('رقم الهاتف'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: '+966 5X XXX XXXX',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                           
                          ),
                          const SizedBox(height: 20),

                          _buildFieldLabel('كلمة المرور'),
                          const SizedBox(height: 8),
                          _buildPasswordTextField(),
                          const SizedBox(height: 20),

                          _buildTermsCheckbox(),
                          const SizedBox(height: 32),

                          _buildRegisterButton(),
                          const SizedBox(height: 24),

                          _buildFooterSection(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 8),
              const Text(
                'موكلي',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ابدأ رحلتك القانونية مع نخبة الخبراء والمحامين',
          style: TextStyle(
            color: AppColors.textLightGray.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textWhite,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.08), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.35), fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textLightGray.withOpacity(0.4), size: 20),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.redAccent),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.08), width: 1.2),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال كلمة المرور';
          }
          if (value.length < 6) {
            return 'يجب أن لا تقل كلمة المرور عن 6 أحرف';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.35), fontSize: 14),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textLightGray.withOpacity(0.4), size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textLightGray.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.redAccent),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Theme(
          data: ThemeData(unselectedWidgetColor: AppColors.textLightGray.withOpacity(0.4)),
          child: Checkbox(
            value: _acceptTerms,
            activeColor: AppColors.primaryGold,
            checkColor: AppColors.backgroundNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
          ),
        ),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'أوافق على ',
                style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 13),
              ),
              GestureDetector(
                onTap: () {/* افتح شروط الخدمة */},
                child: const Text(
                  'شروط الخدمة',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                ' و ',
                style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 13),
              ),
              GestureDetector(
                onTap: () {/* افتح سياسة الخصوصية */},
                child: const Text(
                  'سياسة الخصوصية',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          shadowColor: AppColors.primaryGold.withOpacity(0.3),
        ),
        onPressed: _isLoading ? null : _handleRegister, 
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.backgroundNavy,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'إنشاء حسابي',
                style: TextStyle(
                  color: AppColors.backgroundNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لديك حساب بالفعل؟ ',
              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Divider(color: AppColors.textWhite.withOpacity(0.05), height: 1),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.textLightGray.withOpacity(0.3), size: 22),
            const SizedBox(width: 24),
            Icon(Icons.language_rounded, color: AppColors.textLightGray.withOpacity(0.3), size: 22),
          ],
        ),
      ],
    );
  }
}