import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/model/ConsultationModel.dart';
import 'package:mwakili/controller/AppointmentController.dart';
import 'package:mwakili/controller/LawyerConsultationController.dart';
import 'package:mwakili/view/lawer/task_details_view.dart' show TaskDetailsView;

class LawyerAppointmentsView extends StatefulWidget {
  const LawyerAppointmentsView({Key? key}) : super(key: key);

  @override
  State<LawyerAppointmentsView> createState() => _LawyerAppointmentsViewState();
}

class _LawyerAppointmentsViewState extends State<LawyerAppointmentsView> {
  final AppointmentController _appointmentController = AppointmentController();
  final LawyerConsultationController _consultationController = LawyerConsultationController();

  bool _isLoadingData = false;
  List<ConsultationModel> _consultationsList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
    });

    await _consultationController.fetchLawyerConsultations(context);

    setState(() {
      _consultationsList = _consultationController.lawyerConsultations;
      _isLoadingData = false;
    });
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
            child: Column(
              children: [
                _buildTopSearchBar(),

                Expanded(
                  child: _isLoadingData
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                          ),
                        )
                      : _consultationsList.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد استشارات متاحة حالياً',
                                style: TextStyle(color: AppColors.textWhite, fontSize: 14),
                              ),
                            )
                          : ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                              children: [
                                _buildSectionHeader(
                                  'الاستشارات والطلبات الحالية',
                                  '${_consultationsList.length} استشارة',
                                ),
                                const SizedBox(height: 12),

                                ..._consultationsList.map((consultation) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _buildConsultationWithAppointmentsCard(
                                      context: context,
                                      consultation: consultation,
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.balance, color: AppColors.primaryGold, size: 36),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1F314D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textWhite.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: AppColors.textLightGray.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'بحث في الاستشارات والمواعيد...',
                      hintStyle: TextStyle(
                        color: AppColors.textLightGray.withOpacity(0.3),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: AppColors.textLightGray.withOpacity(0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationWithAppointmentsCard({
    required BuildContext context,
    required ConsultationModel consultation,
  }) {
    Color statusColor;
    String statusText;

    switch (consultation.status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'نشطة';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'مكتملة';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
    }

    String displayDate = consultation.createdAt.contains('T')
        ? consultation.createdAt.split('T')[0]
        : consultation.createdAt;

    String clientName = consultation.lawyer?.name ?? 'اسم المستفيد غير متوفر';

    bool hasAppointments = consultation.appointments != null && consultation.appointments!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.06),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'استشارة قانونية',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 0.8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'الموضوع: ${consultation.title}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              consultation.details,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textLightGray.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

             if (hasAppointments) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131F33),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.event_available, color: AppColors.primaryGold, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'المواعيد والجلسات المقررة لها:',
                          style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...consultation.appointments!.map((app) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '• التاريخ: ${app.appointmentDate}',
                              style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
                            ),
                            Text(
                              'الوقت: ${app.appointmentTime.substring(0, 5)}',
                              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text('لم يتم جدولة مواعيد لهذه الاستشارة بعد.'),
              ),
            ],
           
            const SizedBox(height: 10),
            Divider(color: AppColors.textWhite.withOpacity(0.06), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.primaryGold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      clientName,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.textLightGray.withOpacity(0.4), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      displayDate,
                      style: TextStyle(
                        color: AppColors.textLightGray.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A6021),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsView(consultation: consultation,),
                          ),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.white),
                      label: const Text(
                        'عرض التفاصيل',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryGold, Color(0xFFD4AC0D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        onPressed: () => _showAddAppointmentBottomSheet(context),
        child: const Icon(Icons.add, color: AppColors.backgroundNavy, size: 28),
      ),
    );
  }

  void _showAddAppointmentBottomSheet(BuildContext context) {
    ConsultationModel? selectedConsultation;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF131F33),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.textWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'إضافة موعد جديد مرتبط باستشارة',
                          style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'اختر الاستشارة المستهدفة بالموعد',
                          style: TextStyle(color: AppColors.textLightGray, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F314D),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.textWhite.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedConsultation?.id,
                              hint: const Text(
                                'اختر من قائمة استشاراتك المفتوحة',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              dropdownColor: const Color(0xFF1F314D),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGold),
                              items: _consultationsList.map((ConsultationModel item) {
                                return DropdownMenuItem<int>(
                                  value: item.id,
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (num? targetId) {
                                if (targetId != null) {
                                  setModalState(() {
                                    selectedConsultation = _consultationsList.firstWhere((element) => element.id == targetId);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPickerButton(
                                icon: Icons.calendar_today,
                                text: selectedDate == null
                                    ? 'اختر التاريخ'
                                    : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedDate = picked);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPickerButton(
                                icon: Icons.access_time,
                                text: selectedTime == null
                                    ? 'اختر الوقت'
                                    : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                                onTap: () async {
                                  final TimeOfDay? picked = await showTimePicker(
                                    context: context, initialTime:TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedTime = picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: _isSubmitting
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                                        ),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryGold,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async {
                                          if (selectedConsultation == null || selectedDate == null || selectedTime == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('الرجاء تعبئة كافة البيانات المذكورة')),
                                            );
                                            return;
                                          }

                                          setModalState(() => _isSubmitting = true);

                                          String formattedDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
                                          String formattedTime = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                                          bool success = await _appointmentController.createAppointment(
                                            context: context,
                                            consultationId: selectedConsultation!.id,
                                            date: formattedDate,
                                            time: formattedTime,
                                          );

                                          setModalState(() => _isSubmitting = false);

                                          if (success) {
                                            Navigator.pop(context);
                                            _loadInitialData();
                                          }
                                        },
                                        child: const Text(
                                          'جدولة الموعد وحفظه',
                                          style: TextStyle(color: AppColors.backgroundNavy, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPickerButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.08)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: AppColors.textLightGray.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              Icon(icon, color: AppColors.primaryGold, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}