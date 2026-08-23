import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/view/User/lawyer_profile_view.dart';
import 'package:mwakili/controller/ProfileController.dart';
import 'package:mwakili/model/LawyerModel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String selectedCategory = 'الكل';
  String searchQuery = '';

  final ProfileController _profileController = ProfileController();
  late Future<Map<String, dynamic>> _lawyersFuture;

  @override
  void initState() {
    super.initState();
    _lawyersFuture = _profileController.getAllLawyers();
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeaderTitle(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildCategoryTags(),
                        const SizedBox(height: 24),

                        FutureBuilder<Map<String, dynamic>>(
                          future: _lawyersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError ||
                                (snapshot.hasData &&
                                    snapshot.data!['success'] == false)) {
                              String errorMsg =
                                  snapshot.data?['message'] ??
                                  'حدث خطأ أثناء تحميل البيانات';
                              return Center(
                                child: Text(
                                  errorMsg,
                                  style: TextStyle(color: Colors.red[300]),
                                ),
                              );
                            } else if (!snapshot.hasData) {
                              return const Center(
                                child: Text(
                                  'لا توجد بيانات متاحة',
                                  style: TextStyle(color: AppColors.textWhite),
                                ),
                              );
                            }

                            List<LawyerModel> allLawyers =
                                snapshot.data!['data'] as List<LawyerModel>;

                            if (allLawyers.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا يوجد محامون مسجلون حالياً',
                                  style: TextStyle(color: AppColors.textWhite),
                                ),
                              );
                            }

                            final filteredLawyers = allLawyers.where((lawyer) {
                              final matchesCategory =
                                  selectedCategory == 'الكل' ||
                                  lawyer.specialties.contains(selectedCategory);

                              final matchesSearch =
                                  lawyer.name.contains(searchQuery) ||
                                  lawyer.specialties.any(
                                    (spec) => spec.contains(searchQuery),
                                  );

                              return matchesCategory && matchesSearch;
                            }).toList();

                            if (filteredLawyers.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد نتائج تطابق خيارات البحث',
                                  style: TextStyle(
                                    color: AppColors.textLightGray,
                                  ),
                                ),
                              );
                            }

                             return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredLawyers.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final lawyer = filteredLawyers[index];
                                return _buildLawyerCard(lawyer: lawyer);
                              },
                            );
                          },
                        ),

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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.textWhite),
        onChanged: (value) {
          setState(() {
            searchQuery = value; 
          });
        },
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
    );
  }

  Widget _buildCategoryTags() {
    final categories = ['الكل', 'أحوال شخصية', 'قضايا عمالية'];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final title = categories[index];
          final isSelected = selectedCategory == title;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = title;
              });
            },
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

  Widget _buildLawyerCard({required LawyerModel lawyer}) {
    final String specialtiesText = lawyer.specialties.join('، ');

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
                child: lawyer.avatarUrl != null && lawyer.avatarUrl!.isNotEmpty
                    ? Image.network(
                        lawyer.avatarUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderAvatar(),
                      )
                    : _buildPlaceholderAvatar(),
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
                    children:  [
                      Icon(Icons.star, color: AppColors.primaryGold, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '${lawyer.averageRating} (${lawyer.reviewsCount})', 
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
                  lawyer.name,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  specialtiesText.isEmpty ? 'مستشار قانوني' : specialtiesText,
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
                      'خبرة ${lawyer.experienceYears} سنوات',
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LawyerProfileView(
                                  lawyer: lawyer,
                                  rating: lawyer.averageRating.toString(),
                                  reviewsCount: lawyer.reviewsCount.toString(),
                                ),
                              ),
                            );
                          },
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
                        onPressed: () {},
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

  Widget _buildPlaceholderAvatar() {
    return Container(
      height: 200,
      color: AppColors.textWhite.withOpacity(0.05),
      child: const Center(
        child: Icon(Icons.person, size: 80, color: AppColors.primaryGold),
      ),
    );
  }
}
