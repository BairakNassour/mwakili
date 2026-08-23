import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/RequestConsultationController.dart';
import 'package:mwakili/model/LawyerModel.dart';

class RequestConsultationView extends StatefulWidget {
  final LawyerModel lawyer; 
  final String lawyerRating;
  final String lawyerReviews;

  const RequestConsultationView({
    Key? key,
    required this.lawyer,
    required this.lawyerRating,
    required this.lawyerReviews,
  }) : super(key: key);

  @override
  State<RequestConsultationView> createState() => _RequestConsultationViewState();
}

class _RequestConsultationViewState extends State<RequestConsultationView> {

  final RequestConsultationController _controller = RequestConsultationController();

  @override
  void dispose() {
    _controller.dispose(); 
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAutoFilledLawyerHeader(),
                        const SizedBox(height: 24),
                        
                        const Text('عنوان موضوع الاستشارة', style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildTitleInputField(),
                        const SizedBox(height: 20),

                        const Text('تفاصيل وقائع الاستشارة القانونية', style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildDetailsInputField(),
                        const SizedBox(height: 20),
                        
                        GestureDetector(
                          onTap: () => _controller.pickFiles(() => setState(() {})),
                          child: _buildAttachmentZone(),
                        ),
                        if (_controller.selectedFiles.isNotEmpty) _buildSelectedFilesList(),
                      ],
                    ),
                  ),
                ),
                _buildSubmitAction(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('إنشاء طلب استشارة جديد', style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAutoFilledLawyerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryGold.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.gavel_rounded, color: AppColors.primaryGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المستشار المختار: الأستاذ ${widget.lawyer.name}',
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(widget.lawyer.specialties.isNotEmpty ? widget.lawyer.specialties.first : "مستشار", style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 14),
                    const SizedBox(width: 2),
                    Text('${widget.lawyerRating} (${widget.lawyerReviews})', style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller.titleController, 
        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'مثال: قضية نزاع عقاري، استشارة حول عقود عمل...',
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDetailsInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.04)),
      ),
      child: TextField(
        controller: _controller.detailsController, 
        maxLines: 6,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'فضلاً، قم بسرد وقائع المشكلة القانونية بالتفصيل لسهيل المراجعة...',
          hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 12, height: 1.5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAttachmentZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.01),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.1), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_outlined, color: AppColors.primaryGold.withOpacity(0.7), size: 32),
          const SizedBox(height: 8),
          const Text('رفع المستندات الثبوتية أو لوائح الدعوى', style: TextStyle(color: AppColors.textWhite, fontSize: 13)),
          const SizedBox(height: 4),
          Text('الملفات المدعومة: PDF, PNG, JPG بحد أقصى 10 ميجابايت', style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: _controller.selectedFiles.map((file) {
          return ListTile(
            leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryGold),
            title: Text(file.path.split('/').last, style: const TextStyle(color: Colors.white, fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
              onPressed: () => _controller.removeFile(file, () => setState(() {})),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(color: AppColors.primaryGold, borderRadius: BorderRadius.circular(12)),
        child: TextButton(
          onPressed: _controller.isLoading 
              ? null 
              : () => _controller.submitConsultation(
                    context: context,
                    lawyerId: widget.lawyer.id,
                    onLoadingChanged: () => setState(() {}),
                  ),
          child: _controller.isLoading 
            ? const CircularProgressIndicator(color: AppColors.backgroundNavy)
            : const Text('إرسال طلب الاستشارة الرسمية', style: TextStyle(color: AppColors.backgroundNavy, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}