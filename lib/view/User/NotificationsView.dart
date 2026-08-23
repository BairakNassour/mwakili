import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      appBar: AppBar(
        backgroundColor: const Color(0xFF131F33),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الإشعارات',
          style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primaryGold, size: 22),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F314D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: AppColors.backgroundNavy,
                    unselectedLabelColor: AppColors.textLightGray.withOpacity(0.6),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'الكل'),
                      Tab(text: 'غير المقروء'),
                    ],
                  ),
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsList(showAll: true),
                      _buildNotificationsList(showAll: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList({required bool showAll}) {
    final List<Map<String, dynamic>> allNotifications = [
      {
        'id': '1',
        'title': 'طلب إجراء جديد معلق',
        'body': 'قام المحامي أ. سارة المنصور بإرسال طلب تسوية مقترحة في القضية رقم #2026/7120 بانتظار موافقتك.',
        'time': 'منذ ٢٠ دقيقة',
        'isRead': false,
        'icon': Icons.pending_actions_rounded,
        'iconColor': const Color(0xFFF1C40F),
      },
      {
        'id': '2',
        'title': 'تم تحديث ملف القضية',
        'body': 'أضاف الدكتور عبد الله العمري مستنداً جديداً (لائحة الدعوى المعدلة) في قضية تقسيم التركة.',
        'time': 'منذ ساعتين',
        'isRead': false,
        'icon': Icons.description_rounded,
        'iconColor': const Color(0xFF3498DB),
      },
      {
        'id': '3',
        'title': 'تذكير بموعد استشارة',
        'body': 'لديك موعد استشارة قانونية قادم غداً الساعة ١١:٣٠ صباحاً مع المكتب القانوني.',
        'time': 'منذ يوم واحد',
        'isRead': true,
        'icon': Icons.access_alarm_rounded,
        'iconColor': AppColors.primaryGold,
      },
      {
        'id': '4',
        'title': 'تم إلغاء الجلسة المقترحة',
        'body': 'تم إلغاء موعد الاجتماع الذي كان مقرراً اليوم بناءً على طلب الطرف الآخر.',
        'time': 'منذ يومين',
        'isRead': true,
        'icon': Icons.cancel_schedule_send_rounded,
        'iconColor': const Color(0xFFE74C3C),
      },
    ];

    final List<Map<String, dynamic>> filteredList = showAll 
        ? allNotifications 
        : allNotifications.where((n) => !n['isRead']).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textLightGray.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات حالياً',
              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return _buildNotificationCard(item);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item['isRead'] ? const Color(0xFF1F314D).withOpacity(0.6) : const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item['isRead'] 
              ? Colors.transparent 
              : AppColors.primaryGold.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Dismissible(
          key: Key(item['id']),
          direction: DismissDirection.startToEnd,
          background: Container(
            color: const Color(0xFFE74C3C).withOpacity(0.2),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE74C3C)),
          ),
          onDismissed: (direction) {
          },
          child: InkWell(
            onTap: () {
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item['iconColor'].withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'], color: item['iconColor'], size: 22),
                  ),
                  const SizedBox(width: 14),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 14,
                                fontWeight: item['isRead'] ? FontWeight.w500 : FontWeight.bold,
                              ),
                            ),
                            if (!item['isRead'])
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['body'],
                          style: TextStyle(
                            color: AppColors.textLightGray.withOpacity(item['isRead'] ? 0.5 : 0.8),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: AppColors.textLightGray.withOpacity(0.3), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              item['time'],
                              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}