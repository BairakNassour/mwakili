import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/ProfileController.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController _profileController = ProfileController();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true; 
  bool _isSaving = false;  
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLawyerData();
  }

void _loadLawyerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _profileController.getLawyerProfile();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _titleController.text = data['experience_years'] ?? ''; 
      } else {
        _errorMessage = result['message'] ?? 'فشل تحميل بيانات المحامي';
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء الاتصال بالخادم';
    }

    setState(() => _isLoading = false);
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final result = await _profileController.updateLawyerProfile(
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      setState(() => _isSaving = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
            child: Column(
              children: [
                _buildAppBar(context),
                if (_isSaving) const LinearProgressIndicator(color: AppColors.primaryGold),
                Expanded(
                  child: _buildBodyContent(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            TextButton(
              onPressed: _loadLawyerData,
              child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.primaryGold)),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45, 
              backgroundImage: AssetImage('assets/lawer.jpg'),
            ),
            TextButton(
              onPressed: () {
              }, 
              child: const Text('تغيير الصورة الشخصية', style: TextStyle(color: AppColors.primaryGold)),
            ),
            const SizedBox(height: 20),
            
            _buildTextField(
              label: 'الاسم الكامل', 
              controller: _nameController,
              validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            _buildTextField(
              label: 'المسمى الوظيفي', 
              controller: _titleController,
              validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            _buildTextField(
              label: ' (اختياري)رقم الهاتف', 
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              label: 'البريد الإلكتروني', 
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => !val!.contains('@') ? 'البريد الإلكتروني غير صالح' : null,
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                onPressed: _isSaving ? null : _updateProfile,
                child: const Text(
                  'حفظ التعديلات', 
                  style: TextStyle(color: AppColors.backgroundNavy, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18), 
            onPressed: () => Navigator.pop(context),
          ), 
          const Text(
            'تعديل الحساب الشخصي للمحامي', 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primaryGold),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGold)),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}