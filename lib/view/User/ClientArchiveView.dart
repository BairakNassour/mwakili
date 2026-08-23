import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/model/ConsultationModel.dart';
import 'package:mwakili/controller/ClientArchiveController.dart';
import 'package:mwakili/view/User/client_consultation_details_view.dart';

class ClientArchiveView extends StatefulWidget {
  const ClientArchiveView({Key? key}) : super(key: key);

  @override
  State<ClientArchiveView> createState() => _ClientArchiveViewState();
}

class _ClientArchiveViewState extends State<ClientArchiveView> {
  final ClientArchiveController _controller = ClientArchiveController();

  List<ConsultationModel> _consultations = [];
  bool _isLoading = true;
  String? _errorMessage;

 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await _controller.getClientConsultations();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _consultations = List<ConsultationModel>.from(result['data'] ?? []);
          _errorMessage = null;
        } else {
          _errorMessage = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalItemsCount = _consultations.length;

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
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.02,
                          child: Icon(
                            Icons.balance_rounded,
                            size: MediaQuery.of(context).size.width * 0.75,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                              ),
                            )
                          : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGold,
                                    ),
                                    onPressed: () {
                                      setState(() => _isLoading = true);
                                      _loadData();
                                    },
                                    child: const Text(
                                      'إعادة المحاولة',
                                      style: TextStyle(
                                        color: AppColors.backgroundNavy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.primaryGold,
                              onRefresh: _loadData,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8,
                                ),
                                itemCount: totalItemsCount,
                                itemBuilder: (context, index) {
                                  if (index < _consultations.length) {
                                    return _buildConsultationCard(
                                      context,
                                      _consultations[index],
                                    );
                                  } 
                                },
                              ),
                            ),
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

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'أرشيف الاستشارات والوثائق',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F314D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.archive_outlined,
              color: AppColors.primaryGold,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(
    BuildContext context,
    ConsultationModel consultation,
  ) {
    Map<String, Map<String, dynamic>> statusMap = {
      'pending': {'text': 'قيد الانتظار', 'color': Colors.orange},
      'active': {'text': 'نشطة حالياً', 'color': Colors.blue},
      'completed': {'text': 'مكتملة', 'color': const Color(0xFF2ECC71)},
      'closed': {'text': 'مغلقة', 'color': Colors.grey},
    };

    var currentStatus =
        statusMap[consultation.status] ??
        {'text': consultation.status, 'color': Colors.grey};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F314D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (consultation.lawyer != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClientConsultationDetailsView(
                  consultation: consultation,
                  lawyer: consultation
                      .lawyer!,
                ),
              ),
            ).then((value) => _loadData());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'بيانات المحامي غير متوفرة لهذا الطلب',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      consultation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (currentStatus['color'] as Color).withOpacity(
                        0.12,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentStatus['text']!,
                      style: TextStyle(
                        color: currentStatus['color'],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'المرفقات الحالية: ${consultation.attachments.length} ملفات',
                style: TextStyle(
                  color: AppColors.textLightGray.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: AppColors.textWhite.withOpacity(0.05), height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.textLightGray.withOpacity(0.3),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    consultation.createdAt.split('T').first,
                    style: TextStyle(
                      color: AppColors.textLightGray.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.primaryGold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B1FA2).withOpacity(0.15),
            const Color(0xFFE74C3C).withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE74C3C).withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFFE74C3C),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'رقم الفاتورة: ${item['id']} • ${item['date']}',
                  style: TextStyle(
                    color: AppColors.textLightGray.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item['amount']!,
            style: const TextStyle(
              color: Color(0xFF2ECC71),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
