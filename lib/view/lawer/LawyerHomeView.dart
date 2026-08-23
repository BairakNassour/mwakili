import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mwakili/component/app_colors.dart'; 
import 'package:mwakili/controller/LawyerDashboardController.dart';
import 'package:mwakili/model/LawyerDashboardModel.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwakili/component/general_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwakili/model/RatingModel.dart';

class LawyerHomeView extends StatefulWidget {
  const LawyerHomeView({Key? key}) : super(key: key);

  @override
  State<LawyerHomeView> createState() => _LawyerHomeViewState();
}

class _LawyerHomeViewState extends State<LawyerHomeView> {
  final LawyerDashboardController _dashboardController = LawyerDashboardController();
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  late Future<List<RatingModel>> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _dashboardController.fetchDashboardData();
    _ratingsFuture = _fetchLawyerRatings();
  }

  Future<List<RatingModel>> _fetchLawyerRatings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/lawyer/ratings'), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("ssssssssss");
      print(response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List data = responseData['data'] ?? [];
        return data.map((e) => RatingModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('خطأ في جلب التقييمات: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildTopAppBar(),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _dashboardDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGold),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null || snapshot.data!['success'] == false) {
                        String errorMessage = snapshot.data?['message'] ?? 'حدث خطأ أثناء جلب البيانات';
                        return Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                          ),
                        );
                      }

                      final LawyerDashboardModel dashboardData = snapshot.data!['data'];

                      return RefreshIndicator(
                        color: AppColors.primaryGold,
                        onRefresh: () async {
                          setState(() {
                            _dashboardDataFuture = _dashboardController.fetchDashboardData();
                            _ratingsFuture = _fetchLawyerRatings();
                          });
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              _buildAdvancedChartCard(dashboardData),
                              const SizedBox(height: 24),

                              _buildSectionTitle('المهام الحالية'),
                              const SizedBox(height: 12),
                              
                              if (dashboardData.currentTasks.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('لا توجد مهام حالية حالياً', style: TextStyle(color: AppColors.textLightGray, fontSize: 12)),
                                )
                              else
                                ...dashboardData.currentTasks.map((task) {
                                  bool isChecked = task.status == 'completed' || task.status == 'تمت بنجاح';
                                  Color accentColor = isChecked 
                                      ? const Color(0xFF2ECC71) 
                                      : (task.status == 'pending' ? AppColors.primaryGold : const Color(0xFF3498DB));
                                  
                                  return _buildModernTaskCard(task.title, task.details, accentColor, isChecked);
                                }).toList(),
                                
                              const SizedBox(height: 24),

                              _buildSectionTitle('حالة وجاهزية المكتب'),
                              const SizedBox(height: 12),
                              _buildOfficeStatusGrid(dashboardData),
                              const SizedBox(height: 24),

                              _buildSectionTitle('آراء وتقييمات العملاء'),
                              const SizedBox(height: 12),
                              _buildRatingsSection(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1F314D), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryGold, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('الرئيسية', style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF1F314D), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_none_outlined, color: AppColors.textWhite, size: 22),
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

  Widget _buildAdvancedChartCard(LawyerDashboardModel data) {
    double completed = data.statsPercentages['completed'] ?? 0.0;
    double active = data.statsPercentages['active'] ?? 0.0;
    double pending = data.statsPercentages['pending'] ?? 0.0;
    double closed = data.statsPercentages['closed'] ?? 0.0;

    int totalCases = (data.counters['active_cases_count'] ?? 0) + (data.counters['completed_cases_count'] ?? 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.06), width: 1.2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 42, 
                    startDegreeOffset: 270,
                    sections: [
                      if (completed == 0 && active == 0 && pending == 0 && closed == 0)
                        PieChartSectionData(color: Colors.grey.withOpacity(0.2), value: 100, title: '', radius: 14)
                      else ...[
                        if (completed > 0) PieChartSectionData(color: const Color(0xFF2ECC71), value: completed, title: '', radius: 14),
                        if (active > 0) PieChartSectionData(color: AppColors.primaryGold, value: active, title: '', radius: 14),
                        if (pending > 0) PieChartSectionData(color: const Color(0xFF3498DB), value: pending, title: '', radius: 14),
                        if (closed > 0) PieChartSectionData(color: const Color(0xFFE74C3C), value: closed, title: '', radius: 14),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$totalCases', style: const TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('قضية', style: TextStyle(color: AppColors.textLightGray, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('قضايا منتهية (${completed.toStringAsFixed(0)}%)', const Color(0xFF2ECC71)),
              const SizedBox(height: 8),
              _buildLegendItem('قضايا جارية (${active.toStringAsFixed(0)}%)', AppColors.primaryGold),
              const SizedBox(height: 8),
              _buildLegendItem('قضايا معلقة (${pending.toStringAsFixed(0)}%)', const Color(0xFF3498DB)),
              const SizedBox(height: 8),
              _buildLegendItem('قضايا مغلقة (${closed.toStringAsFixed(0)}%)', const Color(0xFFE74C3C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: AppColors.textLightGray.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildModernTaskCard(String title, String status, Color accentColor, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isChecked ? const Color(0xFF2ECC71).withOpacity(0.15) : AppColors.textWhite.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isChecked ? const Color(0xFF2ECC71) : AppColors.textLightGray.withOpacity(0.4),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: AppColors.textLightGray.withOpacity(0.4),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(
              status,
              style: TextStyle(color: accentColor == AppColors.primaryGold ? AppColors.primaryGold : accentColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeStatusGrid(LawyerDashboardModel data) {
    String activeCases = (data.counters['active_cases_count'] ?? 0).toString();
    String completedCases = (data.counters['completed_cases_count'] ?? 0).toString();
    String totalConsultations = data.totalConsultationsCount.toString();
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatBox('القضايا الجارية', activeCases, const Color(0xFF3498DB)),
        _buildStatBox('تمت بنجاح', completedCases, const Color(0xFF2ECC71)),
        _buildStatBox('إجمالي الاستشارات', totalConsultations, AppColors.primaryGold),
        _buildStatBox('مهمات قيد الحركة', '${data.recentMovingCases.length}', const Color(0xFFE74C3C)),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textLightGray.withOpacity(0.6), fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    return FutureBuilder<List<RatingModel>>(
      future: _ratingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: AppColors.primaryGold)));
        }
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('لا توجد تقييمات أو مراجعات حالياً', style: TextStyle(color: AppColors.textLightGray, fontSize: 12)),
          );
        }

        final ratingsList = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ratingsList.length,
          itemBuilder: (context, index) {
            final ratingItem = ratingsList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1F314D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textWhite.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'استشارة رقم #${ratingItem.consultationId}',
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < ratingItem.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.primaryGold,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  if (ratingItem.review != null && ratingItem.review!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      ratingItem.review!,
                      style: TextStyle(color: AppColors.textLightGray.withOpacity(0.8), fontSize: 12),
                    ),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }
}