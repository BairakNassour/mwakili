import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:mwakili/auth/lawyer_verification_status_view.dart';
import 'package:mwakili/component/app_colors.dart'; 
import 'package:mwakili/controller/auth_controller.dart'; 
import 'package:mwakili/view/lawer/LawyerMainWrapper.dart'; 

class LawyerRegisterView extends StatefulWidget {
  const LawyerRegisterView({Key? key}) : super(key: key);

  @override
  State<LawyerRegisterView> createState() => _LawyerRegisterViewState();
}

class _LawyerRegisterViewState extends State<LawyerRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController(); 
  final ImagePicker _picker = ImagePicker(); 

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _priceController = TextEditingController(); 
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedExperience;
  final List<String> _experienceOptions = ['١ - ٣ سنوات', '٣ - ٥ سنوات', '٥ - ١٠ سنوات', 'أكثر من ١٠ سنوات'];
  
  final Map<String, bool> _specialties = {
    'قانون جنائي': false,
    'قانون مدني': false,
    'قضايا الأسرة': false,
    'قانون تجاري': false,
    'التحكيم الدولي': false,
  };

  File? _avatarFile;
  File? _licenseFile;
  File? _syndicateCardFile;

  bool _isLoading = false; 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _priceController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String type) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'avatar') _avatarFile = File(pickedFile.path);
        if (type == 'license') _licenseFile = File(pickedFile.path);
        if (type == 'syndicate') _syndicateCardFile = File(pickedFile.path);
      });
      _showSnackBar('تم إرفاق الملف بنجاح', AppColors.primaryGold);
    }
  }

  List<String> _getSelectedSpecialties() {
    List<String> selected = [];
    _specialties.forEach((key, value) {
      if (value == true) {
        selected.add(key);
      }
    });
    return selected;
  }

void _handleLawyerRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExperience == null) {
      _showSnackBar('الرجاء اختيار سنوات الخبرة', Colors.orange);
      return;
    }

    List<String> selectedSpecialties = _getSelectedSpecialties();
    if (selectedSpecialties.isEmpty) {
      _showSnackBar('الرجاء اختيار تخصص قانوني واحد على الأقل', Colors.orange);
      return;
    }

    if (_licenseFile == null || _syndicateCardFile == null || _avatarFile == null) {
      _showSnackBar('الرجاء إرفاق جميع الوثائق المهنية المطلوبة الموضحة أدناه', Colors.orange);
      return;
    }

    setState(() => _isLoading = true); 

    double consultationPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;

    var result = await _authController.registerLawyer(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      consultationPrice: consultationPrice,
      experienceYears: _selectedExperience!,
      specialties: selectedSpecialties,
      password: _passwordController.text.trim(),
      avatarFile: _avatarFile,
      licenseFile: _licenseFile,
      syndicateCardFile: _syndicateCardFile,
    );

    setState(() => _isLoading = false); 

    if (result['success']) {
      String isVerified = result['is_verified_panel'] ??"0";
       
      if (isVerified == "1") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LawyerMainWrapper()),
          (route) => false,
        );
      } else {
         Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LawyerVerificationStatusView(status: isVerified, email:_emailController.text , password: _passwordController.text,)),
          (route) => false,
        );
      }
    } else {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor, duration: const Duration(seconds: 2)),
    );
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
                          const SizedBox(height: 10),
                          _buildHeaderSection(),
                          const SizedBox(height: 24),

                          _buildFieldLabel('الاسم الكامل'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController, 
                            hintText: 'أدخل اسمك الثلاثي المعتمد', 
                            icon: Icons.person_outline_rounded,
                            validator: (value) => value == null || value.trim().isEmpty ? 'الرجاء إدخال الاسم الكامل' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('البريد الإلكتروني المهني'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController, 
                            hintText: 'example@law.com', 
                            icon: Icons.mail_outline_rounded, 
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'الرجاء إدخال بريد صحيح';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('رقم الهاتف النقال'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController, 
                            hintText: '05XXXXXXXX', 
                            icon: Icons.phone_android_outlined, 
                            keyboardType: TextInputType.phone,
                            validator: (value) => value == null || value.trim().isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('رقم القيد بالنقابة (الرخصة المهنية)'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _licenseController, 
                            hintText: 'رقم الرخصة المهنية المعتمد', 
                            icon: Icons.badge_outlined,
                            validator: (value) => value == null || value.trim().isEmpty ? 'الرجاء إدخال رقم الرخصة' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('سعر الاستشارة القانونية'),
                          const SizedBox(height: 8),
                          _buildPriceField(),
                          const SizedBox(height: 16),

                          _buildFieldLabel('كلمة المرور المهنية'),
                          const SizedBox(height: 8),
                          _buildPasswordTextField(),
                          const SizedBox(height: 16),

                          _buildFieldLabel('سنوات الخبرة'),
                          const SizedBox(height: 8),
                          _buildExperienceDropdown(),
                          const SizedBox(height: 16),

                          _buildFieldLabel('التخصص القانوني'),
                          const SizedBox(height: 8),
                          _buildSpecialtiesChips(),
                          const SizedBox(height: 20),

                          _buildFieldLabel('الوثائق المهنية المطلوبة'),
                          const SizedBox(height: 8),
                          _buildUploadSection(),
                          const SizedBox(height: 32),

                          _buildSubmitButton(),
                          const SizedBox(height: 20),

                          _buildFooter(context),
                          const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F314D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.balance_rounded, color: AppColors.primaryGold, size: 24),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إنشاء حساب محامي جديد',
          style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'انضم إلى المنصة وقدم خدماتك القانونية بمرونة وبشكل احترافي',
          style: TextStyle(color: AppColors.textLightGray, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500));
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
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.35), fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.textLightGray.withOpacity(0.4), size: 18),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.redAccent),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.08), width: 1.2),
      ),
      child: TextFormField(
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'الرجاء تحديد سعر الاستشارة';
          if (double.tryParse(value.trim()) == null) return 'الرجاء إدخال رقم صحيح';
          return null;
        },
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'حدد تكلفة الاستشارة بالساعة',
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.35), fontSize: 13),
          prefixIcon: Icon(Icons.payments_outlined, color: AppColors.textLightGray.withOpacity(0.4), size: 18),
          suffixIcon: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Text('ر.س', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.redAccent),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
        validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال كلمة المرور الخاص بك' : (value.length < 6 ? 'يجب أن لا تقل عن 6 خانات' : null),
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.35), fontSize: 13),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textLightGray.withOpacity(0.4), size: 18),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textLightGray.withOpacity(0.5), size: 18,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.redAccent),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildExperienceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.08), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedExperience,
          hint: Text('اختر سنوات الخبرة', style: TextStyle(color: AppColors.textLightGray.withOpacity(0.35), fontSize: 13)),
          dropdownColor: const Color(0xFF1F314D),
          icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.textLightGray.withOpacity(0.6), size: 30),
          isExpanded: true,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
          items: _experienceOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedExperience = newValue),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _specialties.keys.map((String key) {
        final isSelected = _specialties[key]!;
        return GestureDetector(
          onTap: () => setState(() => _specialties[key] = !isSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGold : AppColors.textWhite.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.transparent : AppColors.textWhite.withOpacity(0.1)),
            ),
            child: Text(
              key,
              style: TextStyle(
                color: isSelected ? AppColors.backgroundNavy : AppColors.textLightGray,
                fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.textWhite.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, color: AppColors.textLightGray.withOpacity(0.5), size: 40),
              const SizedBox(height: 8),
              Text('انقر على المستند المخصص لرفعه بشكل صحيح', style: TextStyle(color: AppColors.textLightGray.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniUploadButton('رخصة المحاماة', _licenseFile != null, () => _pickDocument('license'), Icons.picture_as_pdf_rounded),
                  _buildMiniUploadButton('البطاقة النقابية', _syndicateCardFile != null, () => _pickDocument('syndicate'), Icons.credit_card_rounded),
                  _buildMiniUploadButton('الصورة الشخصية', _avatarFile != null, () => _pickDocument('avatar'), Icons.account_box_rounded),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniUploadButton(String label, bool isUploaded, VoidCallback onTap, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isUploaded ? Colors.green.withOpacity(0.2) : const Color(0xFF1F314D),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isUploaded ? Colors.green : AppColors.textWhite.withOpacity(0.1)),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: isUploaded ? Colors.green : AppColors.primaryGold),
      label: Text(label, style: TextStyle(color: isUploaded ? Colors.green : AppColors.textWhite, fontSize: 11)),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _handleLawyerRegister,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppColors.backgroundNavy, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('إنشاء الحساب المهني', style: TextStyle(color: AppColors.backgroundNavy, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.backgroundNavy, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟ ', style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(color: AppColors.primaryGold, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}