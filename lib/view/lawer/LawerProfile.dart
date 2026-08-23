import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mwakili/auth/UserTypeView.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/LawyerConsultationController.dart';
import 'package:mwakili/controller/auth_controller.dart';
import 'package:mwakili/view/lawer/calendar_view.dart';
import 'package:mwakili/view/lawer/edit_profile_view.dart';
import 'package:mwakili/view/lawer/security_view.dart';
import 'package:mwakili/view/lawer/task_details_view.dart';
import 'package:mwakili/view/lawer/wallet_view.dart';
import 'package:mwakili/view/payment_settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mwakili/controller/ProfileController.dart';
import 'package:mwakili/model/LawyerModel.dart';

class LawyerProfileView extends StatefulWidget {
  const LawyerProfileView({Key? key}) : super(key: key);

  @override
  State<LawyerProfileView> createState() => _LawyerProfileViewState();
}

class _LawyerProfileViewState extends State<LawyerProfileView> {
  final ProfileController _profileController = ProfileController();
  final LawyerConsultationController _consultationController =
      LawyerConsultationController();

  @override
  void initState() {
    super.initState();
    _fetchActualData();
    _consultationController.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consultationController.fetchLawyerConsultations(context);
    });
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  LawyerModel? _lawyerData;
  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> _fetchActualData() async {
    final result = await _profileController.getLawyerProfile();

    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _lawyerData = LawyerModel.fromJson(result['data']);
          _errorMessage = '';
        } else {
          _errorMessage = result['message'] ?? 'فشل جلب بيانات المحامي';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  )
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            _fetchActualData();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildAppBar(context),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),

                              _buildMainLawyerInfoCard(context),
                              const SizedBox(height: 16),

                              _buildStatisticsSection(context),
                              const SizedBox(height: 24),

                              _buildSectionTitle('روابط سريعة'),
                              const SizedBox(height: 12),
                              _buildQuickLinks(context),
                              const SizedBox(height: 24),

                              _buildSectionTitle('الشهادات والتخصصات العملية'),
                              const SizedBox(height: 4),
                              Text(
                                'التخصصات الحالية المستلمة من الباكيند',
                                style: TextStyle(
                                  color: AppColors.textLightGray.withOpacity(
                                    0.5,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildCertificatesHorizontalList(),
                              const SizedBox(height: 24),

                              _buildSectionTitle('القضايا السابقة'),
                              const SizedBox(height: 12),
                              _buildPastCasesList(context),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle(
                                    'المواعيد والقضايا القادمة',
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CalendarView(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'عرض الكل',
                                      style: TextStyle(
                                        color: AppColors.primaryGold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildUpcomingAppointmentsList(context),
                              const SizedBox(height: 30),
                            ],
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

  Widget _buildAppBar(BuildContext context) {
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
                'Mwakili',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      backgroundColor: const Color(0xFF1F314D),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                        style: TextStyle(color: AppColors.textLightGray),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(color: Colors.white70),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'خروج',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.remove('auth_token');
                            await prefs.remove('remember_me');
                            await prefs.remove('saved_email');
                            await prefs.remove('saved_password');
                            await prefs.remove('saved_is_lawyer');

                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => UserTypeView(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textWhite,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // داخل الـ State الخاصة بك:
  final ImagePicker _picker = ImagePicker();
  final AuthController _authController = AuthController();
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    File imageFile = File(image.path);
    var result = await _authController.updateAvatar(imageFile);

    setState(() {
      _isUploadingImage = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      // هنا يمكنك تحديث بيانات الـ _lawyerData أو إعادة تحميل البيانات لتظهر الصورة الجديدة مباشرة
      setState(() {
        // _lawyerData = ... (قم بتحديث البيانات أو إعادة جلبها)
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildMainLawyerInfoCard(BuildContext context) {
    final imageProvider =
        (_lawyerData?.avatarUrl != null && _lawyerData!.avatarUrl!.isNotEmpty)
        ? NetworkImage(_lawyerData!.avatarUrl!) as ImageProvider
        : const AssetImage('assets/lawer.jpg');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.08),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(radius: 40, backgroundImage: imageProvider),
          ),
          // زر تعديل الصورة
          InkWell(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryGold,
              child: _isUploadingImage
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _lawyerData?.name ?? 'اسم المحامي',
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سنوات الخبرة: ${_lawyerData?.experienceYears ?? '0'} سنوات',
            style: TextStyle(
              color: AppColors.textLightGray.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 8),
              const SizedBox(width: 6),
              Text(
                'سعر الاستشارة: ${_lawyerData?.consultationPrice ?? 0.0} ر.س',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: SizedBox(
              width: 140,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A6021),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileView(),
                    ),
                  );
                },
                child: const Text(
                  'تعديل الملف',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      children: [
        // _buildTotalEarningsCard(context),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                title: 'رقم الرخصة',
                value: _lawyerData?.licenseNumber ?? 'لا يوجد',
                subtext: 'موثق رسمياً',
                icon: Icons.assignment_outlined,
                iconColor: AppColors.primaryGold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStatCard(
                title: 'الهاتف',
                value: _lawyerData?.phone ?? 'لا يوجد',
                subtext: 'رقم التواصل الأساسي',
                icon: Icons.phone_android,
                iconColor: const Color(0xFF3498DB),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalEarningsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletView()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1C40F).withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحفظة والمالية',
                  style: TextStyle(
                    color: AppColors.primaryGold.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      'عرض الحساب المعلق',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'اضغط لعرض تفاصيل المحفظة المالية كلياً',
                  style: TextStyle(
                    color: AppColors.textLightGray.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primaryGold,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textLightGray.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              color: iconColor.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      {
        'title': 'جدول زمني',
        'icon': Icons.calendar_today_outlined,
        'target': const CalendarView(),
      },
      // {'title': 'المعاملات المالية', 'icon': Icons.receipt_long_outlined, 'target': const WalletView()},
      // {'title': 'إعدادات الدفع', 'icon': Icons.credit_card_outlined, 'target': const PaymentSettingsView()},
      {
        'title': 'أمن الحساب',
        'icon': Icons.shield_outlined,
        'target': const SecurityView(),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: links.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppColors.textWhite.withOpacity(0.05), height: 1),
        itemBuilder: (context, index) {
          final item = links[index];
          return ListTile(
            dense: true,
            leading: Icon(
              item['icon'] as IconData,
              color: AppColors.primaryGold,
              size: 18,
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textLightGray.withOpacity(0.3),
              size: 12,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item['target'] as Widget,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCertificatesHorizontalList() {
    final specialtiesList = _lawyerData?.specialties ?? [];

    if (specialtiesList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'لا توجد تخصصات مسجلة حالياً',
          style: TextStyle(color: AppColors.textLightGray, fontSize: 12),
        ),
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialtiesList.length,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F314D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.textWhite.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.abc,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    specialtiesList[index],
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPastCasesList(BuildContext context) {
    final pastConsultations = _consultationController.lawyerConsultations
        .where((c) => c.status == 'completed' || c.status == 'closed')
        .toList();

    if (_consultationController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (pastConsultations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'لا توجد قضايا سابقة مسجلة',
            style: TextStyle(color: AppColors.textLightGray, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pastConsultations.length,
      itemBuilder: (context, index) {
        final consultation = pastConsultations[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TaskDetailsView(consultation: consultation),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1F314D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textWhite.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.title,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        consultation.details ?? 'لا يوجد وصف متاح',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textLightGray.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: consultation.status == 'completed'
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    consultation.status == 'completed' ? 'مكتملة' : 'مغلقة',
                    style: TextStyle(
                      color: consultation.status == 'completed'
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingAppointmentsList(BuildContext context) {
    final upcomingConsultations = _consultationController.lawyerConsultations
        .where((c) => c.status == 'active')
        .toList();

    if (_consultationController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (upcomingConsultations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text(
            'لا توجد مواعيد قادمة مجدولة',
            style: TextStyle(color: AppColors.textLightGray, fontSize: 12),
          ),
        ),
      );
    }

    final List<Color> avatarColors = [
      const Color(0xFF1A5276),
      const Color(0xFFBA4A00),
      const Color(0xFF117A65),
      const Color(0xFF7D6608),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingConsultations.length,
      itemBuilder: (context, index) {
        final consultation = upcomingConsultations[index];

        final hasAppointments =
            consultation.appointments != null &&
            consultation.appointments!.isNotEmpty;
        final firstAppointment = hasAppointments
            ? consultation.appointments!.first
            : null;

        String clientName = consultation.user?.name ?? 'عميل نظام';
        String avatarText = clientName.length >= 2
            ? clientName
                  .replaceAll('أ.', '')
                  .replaceAll('د.', '')
                  .trim()
                  .substring(0, 2)
            : 'عم';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F314D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textWhite.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: avatarColors[index % avatarColors.length],
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          consultation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textLightGray.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        firstAppointment?.appointmentTime ?? '--:-- م',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        firstAppointment?.appointmentDate ?? 'لم يحدد',
                        style: TextStyle(
                          color: AppColors.textLightGray.withOpacity(0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.textWhite.withOpacity(0.05), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailsView(consultation: consultation),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.analytics_outlined,
                          size: 16,
                          color: AppColors.backgroundNavy,
                        ),
                        label: const Text(
                          'مشاهدة التفاصيل',
                          style: TextStyle(
                            color: AppColors.backgroundNavy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
