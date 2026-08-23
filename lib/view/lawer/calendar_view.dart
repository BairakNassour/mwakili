import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/LawyerConsultationController.dart';
import 'package:mwakili/model/ConsultationModel.dart';
import 'package:mwakili/model/AppointmentModel.dart'; 
import 'package:mwakili/view/lawer/task_details_view.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class DayAppointmentItem {
  final AppointmentModel appointment;
  final ConsultationModel consultation;

  DayAppointmentItem({required this.appointment, required this.consultation});
}

class _CalendarViewState extends State<CalendarView> {
  final LawyerConsultationController _consultationController = LawyerConsultationController();
  
  DateTime _selectedDate = DateTime.now(); 
  late List<DateTime> _currentWeekDays;

@override
  void initState() {
    super.initState();
    
    initializeDateFormatting('ar', null).then((_) {
      if (mounted) {
        setState(() {
          _generateWeekDays(); 
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consultationController.fetchLawyerConsultations(context);
    });
  }

  void _generateWeekDays() {
    DateTime today = DateTime.now();
    _currentWeekDays = List.generate(7, (index) {
      return today.add(Duration(days: index - today.weekday + 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedSelectedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    List<DayAppointmentItem> matchingAppointments = [];
    
    for (var consultation in _consultationController.lawyerConsultations) {
      if (consultation.appointments != null) {
        for (var appointment in consultation.appointments!) {
          if (appointment.appointmentDate == formattedSelectedDate) {
            matchingAppointments.add(
              DayAppointmentItem(appointment: appointment, consultation: consultation)
            );
          }
        }
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              _buildCalendarHeader(), 
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'مواعيد وجلسات يوم ${DateFormat('dd MMMM yyyy', 'ar').format(_selectedDate)}',
                  style: const TextStyle(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _consultationController.isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                    : _buildAppointmentsList(matchingAppointments),
              ),
            ],
          ),
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
            'جدول المواعيد والروزنامة', 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _currentWeekDays.length,
        itemBuilder: (context, index) {
          DateTime day = _currentWeekDays[index];
          bool isSelected = DateFormat('yyyy-MM-dd').format(day) == DateFormat('yyyy-MM-dd').format(_selectedDate);
          
          String dayName = DateFormat('E', 'ar').format(day); 
          String dayNumber = DateFormat('dd').format(day);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGold : const Color(0xFF1F314D),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primaryGold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? AppColors.backgroundNavy : AppColors.textLightGray,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? AppColors.backgroundNavy : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(List<DayAppointmentItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.textLightGray.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            const Text(
              'لا توجد مواعيد مجدولة لهذا اليوم',
              style: TextStyle(color: AppColors.textLightGray, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final currentItem = items[index];
        final appointment = currentItem.appointment;
        final consultation = currentItem.consultation;

        return Card(
          color: const Color(0xFF1F314D),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(
              consultation.title, 
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (consultation.user != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppColors.textLightGray, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'العميل: ${consultation.user!.name}',
                          style: const TextStyle(color: AppColors.textLightGray, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.primaryGold, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        appointment.appointmentTime ?? '--:-- م', 
                        style: const TextStyle(color: AppColors.textLightGray, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryGold, size: 14),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => TaskDetailsView(consultation: consultation),
                ),
              );
            },
          ),
        );
      },
    );
  }
}