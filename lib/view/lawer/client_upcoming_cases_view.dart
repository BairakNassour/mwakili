import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/controller/ClientPendingController.dart';

class ClientUpcomingCasesView extends StatefulWidget {
  const ClientUpcomingCasesView({Key? key}) : super(key: key);

  @override
  State<ClientUpcomingCasesView> createState() => _ClientUpcomingCasesViewState();
}

class _ClientUpcomingCasesViewState extends State<ClientUpcomingCasesView> {
  final ClientPendingController _controller = ClientPendingController();
  List<dynamic> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final data = await _controller.fetchPendingRequests();
    setState(() {
      _pendingRequests = data;
      _isLoading = false;
    });
  }

  Future<void> _handleDecision(int id, String decision) async {
    print(decision);
    print(id);
  
    Navigator.pop(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
    );

    bool success = await _controller.updateRequestStatus(id, decision);
    
    Navigator.pop(context); 

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decision == 'active' ? 'تم قبول الطلب بنجاح وبدأ العمل عليه!' : 'تم رفض وإغلاق الطلب.'),
          backgroundColor: decision == 'active' ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
        ),
      );
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء معالجة الطلب، حاول مجدداً.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildTopHeaderAndSearch(),
                
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                      : _pendingRequests.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد أي طلبات معلقة حالياً لحسابك.',
                                style: TextStyle(color: AppColors.textLightGray, fontSize: 14),
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.primaryGold,
                              onRefresh: _loadRequests,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                                itemCount: _pendingRequests.length,
                                itemBuilder: (context, index) {
                                  final item = _pendingRequests[index];
                                  final lawyer = item['lawyer'] ?? {};
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (index == 0) ...[
                                        _buildSectionTitle('طلبات وإجراءات جديدة معلقة تحتاج قرارك'),
                                        const SizedBox(height: 12),
                                      ],
                                      _buildNewRequestCard(
                                        context: context,
                                        id: item['id'],
                                        caseNumber: '#CONS-${item['id']}',
                                        caseTitle: item['title'] ?? 'بدون عنوان',
                                        lawyerName: lawyer['name'] ?? 'محامي المنصة',
                                        requestType: item['details'] ?? '',
                                        timeAgo: 'طلب معلق',
                                        urgencyText: 'ينتهي قريباً',
                                        urgencyColor: const Color(0xFFE74C3C),
                                      ),
                                      const SizedBox(height: 14),
                                    ],
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeaderAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.primaryGold, size: 36),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1F314D), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textWhite.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, color: AppColors.textLightGray.withOpacity(0.4), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'البحث في الطلبات الجديدة المعلقة...',
                      hintStyle: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.search, color: AppColors.textLightGray.withOpacity(0.4), size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNewRequestCard({
    required BuildContext context,
    required int id,
    required String caseNumber,
    required String caseTitle,
    required String lawyerName,
    required String requestType,
    required String timeAgo,
    required String urgencyText,
    required Color urgencyColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.06), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _openRequestDetailsSheet(
            context,
            id,
            caseNumber,
            caseTitle,
            lawyerName,
            requestType,
          ),
          child: Stack(
            children: [
              Positioned(
                left: -15,
                top: 15,
                bottom: 15,
                child: Opacity(
                  opacity: 0.02,
                  child: const Icon(Icons.gavel_rounded, size: 130, color: AppColors.textWhite),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          caseNumber,
                          style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: urgencyColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            urgencyText,
                            style: TextStyle(color: urgencyColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Text(
                      caseTitle,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundNavy.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primaryGold, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'التفاصيل: $requestType',
                              style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المحامي: $lawyerName',
                          style: TextStyle(color: AppColors.textLightGray.withOpacity(0.7), fontSize: 12),
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: AppColors.textLightGray.withOpacity(0.4), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              timeAgo,
                              style: TextStyle(color: AppColors.textLightGray.withOpacity(0.4), fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    Divider(color: AppColors.textWhite.withOpacity(0.06), height: 1),
                    const SizedBox(height: 12),
                    
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اضغط لعرض كامل التفاصيل واتخاذ قرار',
                          style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryGold),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRequestDetailsSheet(
    BuildContext context,
    int id,
    String caseNumber,
    String caseTitle,
    String lawyerName,
    String requestType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF131F33),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textLightGray.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primaryGold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'تفاصيل الإجراء المطلوب $caseNumber',
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('الدعوى / الاستشارة المرتبطة:', style: TextStyle(color: AppColors.textLightGray, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(caseTitle, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                  
                  const SizedBox(height: 16),
                  
                  const Text('المحامي مرسل الطلب:', style: TextStyle(color: AppColors.textLightGray, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(lawyerName, style: const TextStyle(color: AppColors.textWhite, fontSize: 14)),
                  
                  const SizedBox(height: 16),
                  
                  const Text('تفاصيل الاستشارة الموجهة لك للقبول:', style: TextStyle(color: AppColors.textLightGray, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F314D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.textWhite.withOpacity(0.06)),
                    ),
                    child: Text(
                      requestType + '.\n\nيرجى مراجعة هذا الإجراء بعناية. عند ضغطك على قبول، سيتم توثيق موافقتك وإشعار المحامي فوراً لبدء تفعيل الاستشارة والعمل بموجبها.',
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13, height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () => _handleDecision(id, 'active'), 
                            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                            label: const Text('قبول واعتماد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () => _handleDecision(id, 'closed'),
                            icon: const Icon(Icons.cancel_outlined, color: Colors.white, size: 20),
                            label: const Text('رفض الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}