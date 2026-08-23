import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/ClientArchiveController.dart';
import 'package:mwakili/controller/RatingController.dart';
import 'package:mwakili/model/ConsultationModel.dart'; 
import 'package:mwakili/model/LawyerModel.dart';
import 'package:mwakili/view/User/chat/ClientChatsView.dart';

class ClientConsultationDetailsView extends StatefulWidget {
  final ConsultationModel consultation;
  final LawyerModel lawyer; 

  const ClientConsultationDetailsView({
    Key? key,
    required this.consultation,
    required this.lawyer,
  }) : super(key: key);

  @override
  State<ClientConsultationDetailsView> createState() => _ClientConsultationDetailsViewState();
}

class _ClientConsultationDetailsViewState extends State<ClientConsultationDetailsView> {
  late List<AttachmentModel> _currentAttachments;
  bool _isUploading = false;

  final RatingController _ratingController = RatingController();
  bool _isRated = false;
  bool _isCheckingRating = false;

  @override
  void initState() {
    super.initState();
    _currentAttachments = List.from(widget.consultation.attachments);
    
    if (widget.consultation.status == 'completed') {
      _checkIfConsultationIsRated();
    }
  }

  Future<void> _checkIfConsultationIsRated() async {
    setState(() => _isCheckingRating = true);
    
    bool isRated = await _ratingController.checkConsultationRating(widget.consultation.id);
    
    setState(() {
      _isRated = isRated;
      _isCheckingRating = false;
    });
  }

  void _pickAndUploadNewFile(String type, int consultationId) async {
    Navigator.pop(context); 
    
    FilePickerResult? result = await FilePicker.pickFiles(
      type: type == 'pdf' ? FileType.custom : FileType.image,
      allowedExtensions: type == 'pdf' ? ['pdf'] : null,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      _uploadFileToBackend(file, consultationId);
    }
  }

  void _uploadFileToBackend(File file, int consultationId) async {
    setState(() => _isUploading = true);
    ClientArchiveController archiveController = ClientArchiveController();
    
    bool success = await archiveController.uploadNewAttachment(
      context: context, 
      consultationId: consultationId, 
      file: file
    );

    if (success) {
      setState(() {
        _currentAttachments.add(
          AttachmentModel(
            id: 0, 
            fileName: file.path.split('/').last, 
            filePath: '', 
            fileSize: 'جاري التحديث...'
          )
        );
      });
    }
    setState(() => _isUploading = false);
  }

  void _showUploadMenu(int consultationId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF131F33),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة مستند أو مرفق جديد للاستشارة',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildUploadOptionItem(
                        icon: Icons.description_rounded,
                        label: 'رفع ملف PDF',
                        color: const Color(0xFFE74C3C),
                        onTap: () => _pickAndUploadNewFile('pdf', consultationId),
                      ),
                      _buildUploadOptionItem(
                        icon: Icons.image_rounded,
                        label: 'صورة من المعرض',
                        color: const Color(0xFF3498DB),
                        onTap: () => _pickAndUploadNewFile('image', consultationId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadOptionItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textLightGray, fontSize: 12)),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    int currentRating = 5;
    TextEditingController reviewController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F314D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Center(
                child: Text(
                  'تقييم الاستشارة',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تم إنهاء الاستشارة بنجاح، يرجى تقييم الخدمة المقدمة لك:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textLightGray, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.primaryGold,
                          size: 36,
                        ),
                        onPressed: isSubmitting ? null : () {
                          setDialogState(() {
                            currentRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    enabled: !isSubmitting,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'اكتب رأيك هنا (اختياري)...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setDialogState(() => isSubmitting = true);

                            bool success = await _ratingController.submitRating(
                              consultationId: widget.consultation.id,
                              lawyerId: widget.lawyer.id,
                              rating: currentRating,
                              review: reviewController.text.trim(),
                            );

                            setDialogState(() => isSubmitting = false);

                            if (success) {
                              Navigator.pop(dialogContext);
                              
                              setState(() {
                                _isRated = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('شكرًا لتقييمك!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('حدث خطأ أثناء الإرسال، الرجاء المحاولة مرة أخرى'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: isSubmitting 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: AppColors.backgroundNavy, strokeWidth: 2)
                          )
                        : const Text(
                            'إرسال التقييم',
                            style: TextStyle(color: AppColors.backgroundNavy, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                if (!isSubmitting)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('تخطي', style: TextStyle(color: AppColors.textLightGray)),
                  )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRatingSection() {
    if (widget.consultation.status != 'completed' || _isRated) {
      return const SizedBox.shrink();
    }

    if (_isCheckingRating) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Text(
            'هذه الاستشارة مكتملة، ما رأيك في أداء المستشار؟',
            style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.backgroundNavy,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _showRatingDialog,
            icon: const Icon(Icons.star_rounded),
            label: const Text('قيّم المحامي الآن', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                        _buildConsultationHeaderCard(),
                        const SizedBox(height: 20),

                        _buildSectionTitle('⚖️ المستشار القانوني الموكل'),
                        const SizedBox(height: 10),
                        _buildLawyerProfileCard(),
                        const SizedBox(height: 24),

                        _buildRatingSection(),

                        _buildSectionTitle('📝 تفاصيل وقائع الاستشارة'),
                        const SizedBox(height: 10),
                        _buildDetailsContentCard(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('📅 المواعيد المرتبطة بالاستشارة'),
                        const SizedBox(height: 10),
                        _buildAppointmentsSection(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('📁 المستندات والوثائق المرفقة'),
                        const SizedBox(height: 10),
                        _buildProminentUploadButton(),
                        const SizedBox(height: 12),
                        _buildDocumentsList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildBottomActionBar(context),
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
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textWhite, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('تفاصيل الاستشارة', style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold));
  }

  Widget _buildConsultationHeaderCard() {
    Map<String, Map<String, dynamic>> statusStyle = {
      'pending': {'text': 'قيد الانتظار', 'color': Colors.orange},
      'active': {'text': 'نشطة حالياً', 'color': Colors.blue},
      'completed': {'text': 'مكتملة ومغلقة', 'color': Colors.green},
    };

    var currentStatus = statusStyle[widget.consultation.status] ?? {'text': widget.consultation.status, 'color': Colors.grey};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (currentStatus['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(currentStatus['text'], style: TextStyle(color: currentStatus['color'], fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              Text(widget.consultation.createdAt.split('T').first, style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.consultation.title, style: const TextStyle(color: AppColors.textWhite, fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLawyerProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white10,
            backgroundImage: widget.lawyer.avatarUrl != null ? NetworkImage(widget.lawyer.avatarUrl!) : null,
            child: widget.lawyer.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primaryGold) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الأستاذ ${widget.lawyer.name}', style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.lawyer.specialties.join('، '), style: const TextStyle(color: AppColors.primaryGold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.consultation.details,
        style: TextStyle(color: AppColors.textWhite.withOpacity(0.8), fontSize: 13, height: 1.6),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    if (widget.consultation.appointments == null || widget.consultation.appointments!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F314D).withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('لا يوجد مواعيد مجدولة لهذه الاستشارة حتى الآن', style: TextStyle(color: AppColors.textLightGray, fontSize: 12)),
        ),
      );
    }

    return Column(
      children: widget.consultation.appointments!.map((appointment) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F314D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGold, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التاريخ: ${appointment.appointmentDate}', style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('التوقيت: ${appointment.appointmentTime}', style: TextStyle(color: AppColors.textLightGray.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: appointment.status == 'scheduled' ? Colors.blue.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  appointment.status == 'scheduled' ? 'مجدول' : 'مكتمل',
                  style: TextStyle(color: appointment.status == 'scheduled' ? Colors.blue : Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProminentUploadButton() {
    return InkWell(
      onTap: _isUploading ? null : () => _showUploadMenu(widget.consultation.id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A283E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.4), width: 1.5),
        ),
        child: _isUploading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('جاري رفع المستند الجديد وسيعاد التحديث...', style: TextStyle(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, color: AppColors.primaryGold, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'اضغط هنا لرفع مستند أو وثيقة جديدة للملف',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_currentAttachments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('لا يوجد مستندات مرفوعة حالياً', style: TextStyle(color: AppColors.textLightGray, fontSize: 12))),
      );
    }

    return Column(
      children: _currentAttachments.map((doc) {
        bool isPdf = doc.fileName.toLowerCase().endsWith('.pdf');
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F314D).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(isPdf ? Icons.picture_as_pdf_rounded : Icons.image, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.fileName, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(doc.fileSize, style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, color: AppColors.textWhite, size: 20),
                onPressed: () {
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF121E31),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(color: AppColors.primaryGold, borderRadius: BorderRadius.circular(12)),
        child: TextButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientChatsView()));
          },
          icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.backgroundNavy, size: 18),
          label: const Text('فتح محادثة المستشار', style: TextStyle(color: AppColors.backgroundNavy, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}