class LawyerDashboardModel {
  final int totalConsultationsCount;
  final Map<String, double> statsPercentages;
  final Map<String, int> counters;
  final List<DashboardTaskModel> currentTasks;
  final List<DashboardTaskModel> recentMovingCases;

  LawyerDashboardModel({
    required this.totalConsultationsCount,
    required this.statsPercentages,
    required this.counters,
    required this.currentTasks,
    required this.recentMovingCases,
  });

  factory LawyerDashboardModel.fromJson(Map<String, dynamic> json) {
    return LawyerDashboardModel(
      totalConsultationsCount: json['total_consultations_count'] ?? 0,
      statsPercentages: {
        'completed': (json['stats_percentages']['completed'] as num?)?.toDouble() ?? 0.0,
        'active': (json['stats_percentages']['active'] as num?)?.toDouble() ?? 0.0,
        'pending': (json['stats_percentages']['pending'] as num?)?.toDouble() ?? 0.0,
        'closed': (json['stats_percentages']['closed'] as num?)?.toDouble() ?? 0.0,
      },
      counters: Map<String, int>.from(json['counters'] ?? {}),
      currentTasks: (json['current_tasks'] as List? ?? [])
          .map((e) => DashboardTaskModel.fromJson(e))
          .toList(),
      recentMovingCases: (json['recent_moving_cases'] as List? ?? [])
          .map((e) => DashboardTaskModel.fromJson(e))
          .toList(),
    );
  }
}

class DashboardTaskModel {
  final int id;
  final String title;
  final String details;
  final String status;
  final String createdAt;

  DashboardTaskModel({
    required this.id,
    required this.title,
    required this.details,
    required this.status,
    required this.createdAt,
  });

  factory DashboardTaskModel.fromJson(Map<String, dynamic> json) {
    return DashboardTaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }
}