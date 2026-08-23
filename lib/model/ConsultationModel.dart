import 'package:mwakili/model/AppointmentModel.dart';
import 'package:mwakili/model/LawyerModel.dart';
import 'package:mwakili/model/UserModel.dart';

class ConsultationModel {
  final int id;
  final int userId;
  final int lawyerId;
  final String title;
  final String details;
  final String status;
  final String createdAt;
  final List<AttachmentModel> attachments;
  final List<AppointmentModel>? appointments;
  final LawyerModel? lawyer; 
  final UserModel? user; 

  ConsultationModel({
    required this.id,
    required this.userId,
    required this.lawyerId,
    required this.title,
    required this.details,
    required this.status,
    required this.createdAt,
    required this.attachments,
    this.appointments, 
    this.lawyer, 
    this.user,
  });

 factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ConsultationModel(
        id: json['id'] is String ? (int.tryParse(json['id']) ?? 0) : (json['id'] ?? 0),
        userId: json['user_id'] is String ? (int.tryParse(json['user_id']) ?? 0) : (json['user_id'] ?? 0),
        lawyerId: json['lawyer_id'] is String ? (int.tryParse(json['lawyer_id']) ?? 0) : (json['lawyer_id'] ?? 0),
        title: json['title'] ?? '',
        details: json['details'] ?? '',
        status: json['status'] ?? 'pending',
        createdAt: json['created_at'] ?? '',
        
        attachments: json['attachments'] is List
            ? (json['attachments'] as List).map((e) => AttachmentModel.fromJson(e)).toList()
            : [],
        
        appointments: json['appointments'] is List
            ? (json['appointments'] as List).map((e) => AppointmentModel.fromJson(e)).toList()
            : [],

        lawyer: json['lawyer'] != null ? LawyerModel.fromJson(json['lawyer']) : null, 
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null, 
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}

class AttachmentModel {
  final int id;
  final String fileName;
  final String filePath;
  final String fileSize;

  AttachmentModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileSize: json['file_size'] ?? '0 MB',
    );
  }
}