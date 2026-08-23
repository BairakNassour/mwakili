import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/model/ConsultationModel.dart';
import 'package:mwakili/view/lawer/chat/lawyer_chat_detail_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwakili/controller/ClientPendingController.dart';

class TaskDetailsView extends StatefulWidget {
  final ConsultationModel consultation;

  const TaskDetailsView({
    Key? key,
    required this.consultation,
  }) : super(key: key);

  @override
  State<TaskDetailsView> createState() => _TaskDetailsViewState();
}

class _TaskDetailsViewState extends State<TaskDetailsView> {
  bool _isLoading = false;
  final ClientPendingController _pendingController = ClientPendingController();

  Future<void> _markAsCompleted() async {
    setState(() => _isLoading = true);

    bool success = await _pendingController.updateRequestStatus(widget.consultation.id ?? 0, 'completed');

    setState(() => _isLoading = false);

    if (success) {
     
    } else {
      _showErrorSnackBar(context, 'حدث خطأ أثناء إنهاء الاستشارة، يرجى المحاولة لاحقاً');
    }
  }



  @override
  Widget build(BuildContext context) {
    final String clientName = widget.consultation.user?.name ?? 'اسم المستفيد غير متوفر';
    final String clientPhone = widget.consultation.user?.phone ?? 'لا يوجد رقم هاتف';
    final int clientid = widget.consultation.user?.id ?? 0;

    final bool hasAppointments = widget.consultation.appointments != null && widget.consultation.appointments!.isNotEmpty;
    final String sessionDate = hasAppointments ? widget.consultation.appointments!.first.appointmentDate : 'لم يحدد بعد';
    final String sessionTime = hasAppointments ? widget.consultation.appointments!.first.appointmentTime.substring(0, 5) : 'لم يحدد بعد';

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
                        _buildTaskHeaderCard(),
                        const SizedBox(height: 20),

                        _buildSectionTitle('👤 بيانات الزبون'),
                        const SizedBox(height: 10),
                        _buildClientInfoCard(clientName, clientPhone),
                        const SizedBox(height: 24),

                        _buildSectionTitle('⚖️ تفاصيل الجلسة والمواعيد المقررة'),
                        const SizedBox(height: 10),
                        _buildSessionDetailsCard(sessionDate, sessionTime, hasAppointments),
                        const SizedBox(height: 24),

                        _buildSectionTitle('الأوراق والمستندات المرفقة'),
                        const SizedBox(height: 10),
                        _buildAttachmentsList(context, widget.consultation.attachments),
                        const SizedBox(height: 30),

                        if (widget.consultation.status == 'active')
                          _buildCompleteButton(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                _buildBottomActionButtons(context, clientName, clientid,widget.consultation.user!.phone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: _isLoading ? null : _markAsCompleted,
        icon: _isLoading 
            ? const SizedBox.shrink() 
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        label: _isLoading
            ? const SizedBox(
                width: 24, height: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text(
                'تحديد كـ مكتملة وإنهاء',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
          const Text(
            'تفاصيل الاستشارة الكاملة',
            style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTaskHeaderCard() {
    Color statusColor;
    String statusText;

    switch (widget.consultation.status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'نشطة / جارية';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'مكتملة';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
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
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              Text('رقم الاستشارة: #${widget.consultation.id}', style: TextStyle(color: AppColors.textLightGray.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.consultation.title, style: const TextStyle(color: AppColors.textWhite, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            widget.consultation.details, 
            style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoCard(String name, String phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.textWhite.withOpacity(0.05),
            child: const Icon(Icons.person, color: AppColors.primaryGold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_android_rounded, color: AppColors.primaryGold.withOpacity(0.7), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: const TextStyle(color: AppColors.textLightGray, fontSize: 13, letterSpacing: 0.5),
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

  Widget _buildSessionDetailsCard(String date, String time, bool hasAppointments) {
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
          if (hasAppointments) ...[
            ...widget.consultation.appointments!.map((app) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    _buildSessionRowItem(Icons.calendar_today_rounded, 'تاريخ الموعد المجدول', app.appointmentDate),
                    const SizedBox(height: 8),
                    _buildSessionRowItem(Icons.access_time_rounded, 'وقت الحضور المقرر', app.appointmentTime.substring(0, 5)),
                    const SizedBox(height: 4),
                    _buildSessionRowItem(Icons.info_outline, 'حالة الموعد الجاري', app.status == 'scheduled' ? 'مؤكد ومجدول' : app.status),
                    const Divider(color: Colors.white10, height: 16),
                  ],
                ),
              );
            }).toList()
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  'لم يتم جدولة أي مواعيد لهذه الاستشارة حتى الآن.',
                  style: TextStyle(color: AppColors.textLightGray.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          _buildSessionRowItem(Icons.account_balance_rounded, 'جهة تقديم الخدمة', 'منصة مواكلي القانونية الرقمية'),
        ],
      ),
    );
  }

  Widget _buildSessionRowItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 17),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textLightGray.withOpacity(0.6), fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _openAttachment(BuildContext context, String urlString) async {
    if (urlString.isEmpty) {
      _showErrorSnackBar(context, 'رابط الملف غير صالح أو غير موجود');
      return;
    }

    final cleanUrl = urlString.trim();
    final Uri url = Uri.parse(cleanUrl);
    
    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _showErrorSnackBar(context, 'لا يمكن فتح هذا الملف، تأكد من سلامة الرابط');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildAttachmentsList(BuildContext context, List<dynamic>? files) {
    if (files == null || files.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F314D).withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'لا توجد ملفات أو مرفقات مرفوعة مع هذه الاستشارة',
            style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 12),
          ),
        ),
      );
    }

    return Column(
      children: files.map((file) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F314D).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textWhite.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_rounded, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName ?? 'ملف مرفق', 
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      file.fileSize ?? 'حجم غير معروف', 
                      style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined, color: AppColors.textWhite, size: 20),
                tooltip: 'تحميل / فتح الملف',
                onPressed: () {
                  _openAttachment(context, file.filePath ?? '');
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


Widget _buildBottomActionButtons(BuildContext context, String clientName, int clientId, String phoneNumber) {
  
  // دالة مسؤولة عن فتح تطبيق الاتصال بالهاتف
  Future<void> _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن إجراء الاتصال بهذا الرقم'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء محاولة الاتصال'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.phone_forwarded_rounded, color: Colors.green, size: 20),
            onPressed: () {
              // التحقق من أن رقم الهاتف متوفر وليست فارغاً قبل الاتصال
              if (phoneNumber.isNotEmpty) {
                _makePhoneCall(phoneNumber);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('رقم هاتف الزبون غير متوفر'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: AppColors.primaryGold, borderRadius: BorderRadius.circular(12)),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LawyerChatDetailView(clientName: clientName, isOnline: true, clientId: clientId)),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.backgroundNavy, size: 18),
              label: const Text(
                'إرسال رسالة للزبون',
                style: TextStyle(color: AppColors.backgroundNavy, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}