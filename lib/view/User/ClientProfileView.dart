import 'package:flutter/material.dart';
import 'package:mwakili/auth/UserTypeView.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/ProfileController.dart';
import 'package:mwakili/model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientProfileView extends StatefulWidget {
  const ClientProfileView({Key? key}) : super(key: key);

  @override
  State<ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<ClientProfileView> {
  final ProfileController _profileController = ProfileController();
  
  UserModel? _user; 
  bool _isLoading = true;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isEditing = false; 
  bool _isSaving = false;  

  @override
  void initState() {
    super.initState();
    _fetchProfileData(); 
  }

  void _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _profileController.getUserProfile();
      if (result['success'] == true && result['data'] != null) {
        _user = result['data'];
        _nameController.text = _user!.name;
        _emailController.text = _user!.email;
        _phoneController.text = _user!.phone;
      } else {
        _errorMessage = result['message'] ?? 'فشل جلب البيانات';
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال بالشبكة';
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final result = await _profileController.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      setState(() => _isSaving = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
        );
        setState(() {
          _isEditing = false;
        });
        _fetchProfileData(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildTopAppBar(),
                if (_isSaving) const LinearProgressIndicator(color: AppColors.primaryGold),
                Expanded(
                  child: _buildBodyContent(),
                ),
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

    if (_errorMessage != null || _user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'فشل الاتصال بالخادم الداخلي',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            TextButton(
              onPressed: _fetchProfileData,
              child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.primaryGold)),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // _buildAdvancedAvatar(),
            const SizedBox(height: 16),
            
            Text(
              _user!.name,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'حساب عميل نشط',
              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 12),
            ),
            const SizedBox(height: 35),

            _buildEditableActionField(
              label: 'الاسم الكامل',
              controller: _nameController,
              leadingIcon: Icons.person_outline_rounded,
              validator: (value) => value!.isEmpty ? 'الاسم مطلوب' : null,
            ),
            _buildEditableActionField(
              label: 'البريد الإلكتروني',
              controller: _emailController,
              leadingIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => !value!.contains('@') ? 'البريد غير صالح' : null,
            ),
            _buildEditableActionField(
              label: 'رقم الهاتف الموثق',
              controller: _phoneController,
              leadingIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'رقم الهاتف مطلوب' : null,
            ),

            if (!_isEditing)
              _buildStaticActionField(
                label: 'المستندات والوثائق المرفوعة',
                value: 'ملفات الحساب نشطة',
                leadingIcon: Icons.folder_open_rounded,
                trailingIcon: Icons.arrow_forward_ios_rounded,
              ),
            
            const SizedBox(height: 30),
            
            _isEditing ? _buildEditingButtons() : _buildLogoutButton(context),
            
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'الملف الشخصي',
            style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (!_isEditing && !_isLoading && _user != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primaryGold, size: 22),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedAvatar() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.4), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1F314D),
            child: Icon(
              Icons.person_rounded,
              size: 55,
              color: AppColors.textLightGray.withOpacity(0.6),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.primaryGold,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: AppColors.backgroundNavy,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableActionField({
    required String label,
    required TextEditingController controller,
    required IconData leadingIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isEditing ? AppColors.primaryGold.withOpacity(0.6) : AppColors.textWhite.withOpacity(0.05), 
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: _isEditing, 
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 12),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticActionField({
    required String label,
    required String value,
    required IconData leadingIcon,
    IconData trailingIcon = Icons.arrow_forward_ios_rounded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(
            trailingIcon,
            color: AppColors.textLightGray.withOpacity(0.2),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildEditingButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving ? null : _saveProfileChanges,
              child: const Text('حفظ التغييرات', style: TextStyle(color: AppColors.backgroundNavy, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textLightGray),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _isEditing = false;
                        if (_user != null) {
                          _nameController.text = _user!.name;
                          _emailController.text = _user!.email;
                          _phoneController.text = _user!.phone;
                        }
                      });
                    },
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textWhite)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.2)),
      ),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: const Color(0xFF1F314D),
                  title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                  content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من الحساب؟', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
                      child: const Text('خروج', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('remember_me');
                        await prefs.remove('saved_email');
                        await prefs.remove('saved_password');
                        await prefs.remove('saved_is_lawyer');
                        await prefs.remove('auth_token');

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const UserTypeView(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE74C3C), size: 18),
            SizedBox(width: 8),
            Text(
              'تسجيل الخروج من الحساب',
              style: TextStyle(color: Color(0xFFE74C3C), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}