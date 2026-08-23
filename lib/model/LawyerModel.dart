class LawyerModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final double consultationPrice;
  final String experienceYears;
  final List<String> specialties;
  final String? avatarUrl;
  final String? licenseUrl;
  final String? syndicateCardUrl;
  
  final double averageRating;
  final int reviewsCount;

  LawyerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.consultationPrice,
    required this.experienceYears,
    required this.specialties,
    this.avatarUrl,
    this.licenseUrl,
    this.syndicateCardUrl,
    this.averageRating = 0.0,
    this.reviewsCount = 0,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      consultationPrice: json['consultation_price'] is String 
          ? (double.tryParse(json['consultation_price']) ?? 0.0) 
          : (json['consultation_price']?.toDouble() ?? 0.0),
      experienceYears: json['experience_years'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      avatarUrl: json['avatar_url'],
      licenseUrl: json['license_url'],
      syndicateCardUrl: json['syndicate_card_url'],
      
      averageRating: json['average_rating'] is String 
          ? (double.tryParse(json['average_rating']) ?? 0.0) 
          : (json['average_rating']?.toDouble() ?? 0.0),
      reviewsCount: json['reviews_count'] is String
          ? (int.tryParse(json['reviews_count']) ?? 0)
          : (json['reviews_count']?.toInt() ?? 0),
    );
  }
}