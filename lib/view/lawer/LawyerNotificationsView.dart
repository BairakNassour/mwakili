import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';

class LawyerNotificationsView extends StatefulWidget {
  const LawyerNotificationsView({Key? key}) : super(key: key);

  @override
  State<LawyerNotificationsView> createState() => _LawyerNotificationsViewState();
}

class _LawyerNotificationsViewState extends State<LawyerNotificationsView> with SingleTickerProviderStateMixin {
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
          'تنبيهات النظام والمستجدات',
          style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primaryGold, size: 22),
            tooltip: 'تعيين الكل كمقروء',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث جميع التنبيهات كمقروءة')),
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: 'الواردة مؤخراً'),
                      Tab(text: 'غير المقروءة'),
                    ],
                  ),
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLawyerNotificationsList(showAll: true),
                      _buildLawyerNotificationsList(showAll: false),
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

  Widget _buildLawyerNotificationsList({required bool showAll}) {
    final List<Map<String, dynamic>> lawyerNotifications = [
      {
        'id': '1',
        'title': 'إسناد استشارة جديدة طارئة',
        'body': 'تم حجز موعد استشارة جنائية طارئة جديدة من قِبل العميل. يرجى الاطلاع على تفاصيل الوقائع والمستندات المرفقة.',
        'time': 'منذ ١٠ دقائق',
        'isRead': false,
        'icon': Icons.gavel_rounded,
        'iconColor': const Color(0xFFE74C3C),
      },
      {
        'id': '2',
        'title': 'تم استلام دفعة مالية',
        'body': 'تم إيداع مبلغ 500 ر.س في حسابك الخاص بالفاتورة رقم #INV-9921 والمقدمة من العميل لاستشارة الأحوال الشخصية.',
        'time': 'منذ ساعة',
        'isRead': false,
        'icon': Icons.account_balance_wallet_rounded,
        'iconColor': const Color(0xFF2ECC71), 
      },
      {
        'id': '3',
        'title': 'تحديث في بوابة ناجز القضائية',
        'body': 'تم صدور قرار جديد من الدائرة القضائية بخصوص قضية تقسيم التركة رقم #2026/7120 الموكل بها.',
        'time': 'منذ ٥ ساعات',
        'isRead': true,
        'icon': Icons.account_balance_rounded,
        'iconColor': const Color(0xFF3498DB), 
      },
      {
        'id': '4',
        'title': 'تذكير بموعد جلسة قادمة',
        'body': 'تذكير: لديك موعد جلسة شيخ الطائفة والمثول عن بُعد غداً الساعة ٠٩:١٥ صباحاً.',
        'time': 'منذ يوم واحد',
        'isRead': true,
        'icon': Icons.event_note_rounded,
        'iconColor': AppColors.primaryGold, 
      },
    ];

    final List<Map<String, dynamic>> filteredList = showAll 
        ? lawyerNotifications 
        : lawyerNotifications.where((n) => !n['isRead']).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.textLightGray.withOpacity(0.15)),
            const SizedBox(height: 14),
            Text(
              'صندوق التنبيهات فارغ تماماً',
              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 13),
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
        color: item['isRead'] ? const Color(0xFF1F314D).withOpacity(0.5) : const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item['isRead'] ? Colors.transparent : AppColors.primaryGold.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Dismissible(
          key: Key(item['id']),
          direction: DismissDirection.startToEnd,
          background: Container(
            color: const Color(0xFFE74C3C).withOpacity(0.15),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFE74C3C)),
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
                      color: item['iconColor'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'], color: item['iconColor'], size: 20),
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
                                fontSize: 13.5,
                                fontWeight: item['isRead'] ? FontWeight.w500 : FontWeight.bold,
                              ),
                            ),
                            if (!item['isRead'])
                              Container(
                                width: 7,
                                height: 7,
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
                            color: AppColors.textLightGray.withOpacity(item['isRead'] ? 0.4 : 0.75),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.history_toggle_off_rounded, color: AppColors.textLightGray.withOpacity(0.25), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              item['time'],
                              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.25), fontSize: 10),
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