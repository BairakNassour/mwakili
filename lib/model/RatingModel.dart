class RatingModel {
  final int? id;
  final int userId;
  final int lawyerId;
  final int consultationId;
  final int rating;
  final String? review;

  RatingModel({
    this.id,
    required this.userId,
    required this.lawyerId,
    required this.consultationId,
    required this.rating,
    this.review,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      userId: json['user_id'],
      lawyerId: json['lawyer_id'],
      consultationId: json['consultation_id'],
      rating: json['rating'],
      review: json['review'],
    );
  }
}