import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/model/LawyerModel.dart';
import 'request_consultation_view.dart';

class LawyerProfileView extends StatelessWidget {
  final LawyerModel lawyer;
  final String rating;
  final String reviewsCount;

  const LawyerProfileView({
    Key? key,
    required this.lawyer,
    this.rating = '4.9', 
    this.reviewsCount = '120',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String mainSpecialty = lawyer.specialties.isNotEmpty
        ? lawyer.specialties.join('، ')
        : 'مستشار قانوني';

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
                _buildCustomAppBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        _buildHeroProfileCard(mainSpecialty),
                        const SizedBox(height: 20),

                        if (lawyer.specialties.isNotEmpty) ...[
                          _buildSectionTitle('مجالات الاختصاص'),
                          const SizedBox(height: 10),
                          _buildSubSpecialtiesChips(lawyer.specialties),
                          const SizedBox(height: 24),
                        ],

                        _buildSectionTitle('⚖️ عن المحامي والخدمات'),
                        const SizedBox(height: 10),
                        _buildAboutLawyerCard(mainSpecialty),
                        const SizedBox(height: 24),

                        _buildSectionTitle('📜 المعلومات المهنية والتراخيص'),
                        const SizedBox(height: 10),
                        _buildCareerTimeline(),
                        const SizedBox(height: 24),

                        _buildReviewSectionHeader(),
                        const SizedBox(height: 12),
                        _buildClientReviewsList(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                _buildBottomActionBar(context, mainSpecialty),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textWhite,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'الملف الشخصي',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textWhite,
              size: 22,
            ),
            onPressed: () {},
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

  Widget _buildHeroProfileCard(String specialtyText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF121E31),
                  backgroundImage:
                      lawyer.avatarUrl != null && lawyer.avatarUrl!.isNotEmpty
                      ? NetworkImage(lawyer.avatarUrl!)
                      : null,
                  child: lawyer.avatarUrl == null || lawyer.avatarUrl!.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 55,
                          color: AppColors.primaryGold,
                        )
                      : null,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 6, right: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1F314D), width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            lawyer.name,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            specialtyText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.primaryGold,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$rating ($reviewsCount مراجعة)',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Divider(color: AppColors.textWhite.withOpacity(0.08), height: 1),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricItem(
                'الخبرة المهنية',
                '${lawyer.experienceYears} سنوات',
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.textWhite.withOpacity(0.1),
              ),
              _buildMetricItem(
                'تكلفة الاستشارة',
                '${lawyer.consultationPrice} د.أ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLightGray.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSpecialtiesChips(List<String> specialties) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: specialties.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textWhite.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.textWhite.withOpacity(0.08)),
          ),
          child: Text(
            item,
            style: const TextStyle(
              color: AppColors.textLightGray,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutLawyerCard(String specialtyText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'الأستاذ ${lawyer.name} مرخص ومعتمد بموجب رقم رخصة (${lawyer.licenseNumber}). من الكفاءات القانونية المتميزة المتخصصة في $specialtyText.\n\nيقدم الاستشارات والتمثيل القضائي ممتداً بخبرة مهنية تزيد عن ${lawyer.experienceYears} سنوات، ملتزماً بالسرية التامة وحماية مصالح الموكلين والسعي لإيجاد أنجح الحلول الودية والقضائية المتوافقة مع الأنظمة والتشريعات الحالية.',
        style: TextStyle(
          color: AppColors.textWhite.withOpacity(0.8),
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildCareerTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineNode(
            title: 'الوضع المهني الحالي',
            subtitle: 'مكتب المحاماة الخاص والاستشارات القانونية المرخصة',
            desc:
                'ممارس مسجل، يقدم الخدمات القانونية والتمثيل أمام مختلف درجات المحاكم بالتخصصات المذكورة.',
            isFirst: true,
          ),
          _buildTimelineNode(
            title: 'رقم القيد والترخيص المعتمد',
            subtitle: 'رقم الرخصة الموثقة: ${lawyer.licenseNumber}',
            desc:
                'حالة الترخيص: ساري ومعتمد ومصرح له بمزاولة أعمال المحاماة عبر منصة عدالة.',
            isLast:
                lawyer.licenseUrl == null &&
                lawyer.syndicateCardUrl ==
                    null, 
          ),

          if (lawyer.licenseUrl != null || lawyer.syndicateCardUrl != null) ...[
            _buildTimelineNode(
              title: 'الوثائق والشهادات الرسمية',
              subtitle: 'الشهادات المرفوعة والموثقة من قبل الإدارة',
              desc: 'اضغط على أي وثيقة أدناه لمعاينتها بشكل كامل:',
              isLast: true,
              content: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    if (lawyer.licenseUrl != null &&
                        lawyer.licenseUrl!.isNotEmpty)
                      Expanded(
                        child: _buildDocumentCard(
                          title: 'رخصة المزاولة',
                          imageUrl: lawyer.licenseUrl!,
                        ),
                      ),
                    if (lawyer.licenseUrl != null &&
                        lawyer.syndicateCardUrl != null)
                      const SizedBox(width: 12),
                    if (lawyer.syndicateCardUrl != null &&
                        lawyer.syndicateCardUrl!.isNotEmpty)
                      Expanded(
                        child: _buildDocumentCard(
                          title: 'بطاقة النقابة',
                          imageUrl: lawyer.syndicateCardUrl!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String subtitle,
    required String desc,
    bool isFirst = false,
    bool isLast = false,
    Widget? content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: content != null
                    ? 140
                    : 60, 
                color: AppColors.primaryGold.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: AppColors.textLightGray.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              if (content != null) content, 
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '💬 آراء الموكلين',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'عرض الكل',
            style: TextStyle(color: AppColors.primaryGold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildClientReviewsList() {
    return Column(
      children: [
        _buildSingleReviewCard(
          'عبدالله القحطاني',
          'تعامل راقٍ جداً واحترافية في العمل، ساعدني الأستاذ في إنهاء الإجراءات بسلاسة وسرعة غير متوقعة، أنصح به بشدة.',
          5,
        ),
        const SizedBox(height: 12),
        _buildSingleReviewCard(
          'سارة الشمري',
          'متمكن جداً ولديه رحابة صدر، شرح لي كل تفاصيل الموقف القانوني بصبر ووضوح تام.',
          4,
        ),
      ],
    );
  }

  Widget _buildSingleReviewCard(
    String clientName,
    String reviewText,
    int ratingStars,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clientName,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < ratingStars
                        ? AppColors.primaryGold
                        : Colors.white10,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reviewText,
            style: TextStyle(
              color: AppColors.textLightGray.withOpacity(0.8),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, String specialtyText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF121E31),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textWhite.withOpacity(0.1)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.textWhite,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  print("ssssssssss");
                  print(lawyer.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestConsultationView(
                        lawyer: lawyer,
                        lawyerRating: rating, 
                        lawyerReviews: reviewsCount, 
                      ),
                    ),
                  );
                },
                child: const Text(
                  'طلب استشارة قانونية',
                  style: TextStyle(
                    color: AppColors.backgroundNavy,
                    fontSize: 14,
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

  Widget _buildDocumentCard({required String title, required String imageUrl}) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _showImagePreview(
          context,
          title,
          imageUrl,
        ), 
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textWhite.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.fullscreen,
                      color: AppColors.primaryGold,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
