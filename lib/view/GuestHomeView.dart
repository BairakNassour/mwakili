import 'package:flutter/material.dart';
import 'package:mwakili/auth/UserTypeView.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/ProfileController.dart'; 
import 'package:mwakili/model/LawyerModel.dart';

class GuestHomeView extends StatefulWidget {
  const GuestHomeView({Key? key}) : super(key: key);

  @override
  State<GuestHomeView> createState() => _GuestHomeViewState();
}

class _GuestHomeViewState extends State<GuestHomeView> {
  final ProfileController _profileController = ProfileController();

  List<LawyerModel> _lawyers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLawyers();
  }

  Future<void> _fetchLawyers() async {
    final result = await _profileController.getAllLawyers();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _lawyers = result['data'] as List<LawyerModel>;
          _errorMessage = null;
        } else {
          _errorMessage = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const UserTypeView();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يرجى تسجيل الدخول أولاً للوصول إلى هذه الميزة'),
        backgroundColor: AppColors.primaryGold,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildAppBar(context),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGold,
                          ),
                        )
                      : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _fetchLawyers();
                                },
                                child: const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(
                                    color: AppColors.backgroundNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _lawyers.isEmpty
                      ? const Center(
                          child: Text(
                            'لا يوجد محامون متاحون حالياً',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primaryGold,
                          onRefresh: _fetchLawyers,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                _buildHeaderTitle(),
                                const SizedBox(height: 16),
                                _buildSearchBar(context),
                                const SizedBox(height: 16),
                                _buildCategoryTags(context),
                                const SizedBox(height: 24),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _lawyers.length,
                                  itemBuilder: (context, index) {
                                    final lawyer = _lawyers[index];

                                    String specialtyText =
                                        (lawyer.specialties != null &&
                                            lawyer.specialties!.isNotEmpty)
                                        ? lawyer.specialties!.join(' ، ')
                                        : 'محامي عام';

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: _buildLawyerCard(
                                        context: context,
                                        name:
                                            'أ. ${lawyer.name}',
                                        specialty: specialtyText,
                                        experience:
                                            'خبرة ${lawyer.experienceYears} سنوات',
                                        rating: lawyer.averageRating
                                            .toString(), 
                                        reviewsCount: lawyer.reviewsCount
                                            .toString(), 
                                        imageUrl: lawyer.avatarUrl,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: AppColors.primaryGold, size: 24),
              const SizedBox(width: 8),
              const Text(
                'موكلي',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _navigateToLogin(context),
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.textWhite,
                  size: 28,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المحامون المتاحون',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ابحث عن أفضل الكفاءات القانونية لتمثيل قضاياك بكل ثقة',
          style: TextStyle(
            color: AppColors.textLightGray.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToLogin(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textWhite.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textWhite.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: AbsorbPointer(
          child: TextField(
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو التخصص...',
              hintStyle: TextStyle(
                color: AppColors.textLightGray.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textLightGray.withOpacity(0.6),
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.backgroundNavy,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTags(BuildContext context) {
    final categories = ['الكل', 'أحوال شخصية', 'قضايا عمالية'];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final title = categories[index];
          final isSelected = index == 0;

          return GestureDetector(
            onTap: () => _navigateToLogin(context),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.textWhite.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColors.textWhite.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.backgroundNavy
                        : AppColors.textLightGray,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLawyerCard({
    required BuildContext context,
    required String name,
    required String specialty,
    required String experience,
    required String rating,
    required String reviewsCount,
    required String? imageUrl,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: AppColors.textWhite.withOpacity(0.05),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundNavy.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.primaryGold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviewsCount)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  specialty,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppColors.textLightGray.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      experience,
                      style: TextStyle(
                        color: AppColors.textLightGray.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Divider(
                  color: AppColors.textWhite.withOpacity(0.08),
                  height: 1,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.7),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () => _navigateToLogin(context),
                          child: const Text(
                            'عرض الملف',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.textWhite.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.bookmark_border_rounded,
                          color: AppColors.textWhite,
                        ),
                        onPressed: () => _navigateToLogin(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.textWhite.withOpacity(0.05),
      child: const Icon(Icons.person, size: 80, color: AppColors.primaryGold),
    );
  }
}
