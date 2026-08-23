import 'ConsultationModel.dart';

class AppointmentModel {
  final int id;
  final int consultationId;
  final String appointmentDate;
  final String appointmentTime;
  final String status; 
  final ConsultationModel? consultation; 

  AppointmentModel({
    required this.id,
    required this.consultationId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.consultation,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] is String ? (int.tryParse(json['id']) ?? 0) : (json['id'] ?? 0),
      consultationId: json['consultation_id'] is String ? (int.tryParse(json['consultation_id']) ?? 0) : (json['consultation_id'] ?? 0),
      
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      status: json['status'] ?? 'scheduled',
      consultation: json['consultation'] != null 
          ? ConsultationModel.fromJson(json['consultation']) 
          : null,
    );
  }
}