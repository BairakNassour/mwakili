import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';

class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {
        'title': 'استلام رسوم استشارة',
        'subtitle': 'من العميل: عبدالله القحطاني',
        'date': 'اليوم، 02:30 م',
        'amount': '+350.00 ر.س',
        'isIncome': true,
      },
      {
        'title': 'سحب رصيد للحساب البنكي',
        'subtitle': 'بنك الراجحي - ينتهي بـ 4321',
        'date': 'أمس، 11:15 ص',
        'amount': '-1,200.00 ر.س',
        'isIncome': false,
      },
      {
        'title': 'استلام رسوم قضية',
        'subtitle': 'مذكرة دفاع رئيسية - سارة الأحمد',
        'date': '28 مايو 2026',
        'amount': '+2,500.00 ر.س',
        'isIncome': true,
      },
      {
        'title': 'شحن المحفظة (إعلانات)',
        'subtitle': 'عبر بطاقة مدى مدى',
        'date': '25 مايو 2026',
        'amount': '+150.00 ر.س',
        'isIncome': true,
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildAppBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        _buildBalanceCard('3,850.00'),
                        const SizedBox(height: 24),

                        _buildQuickActionsRow(),
                        const SizedBox(height: 28),

                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'سجل العمليات الأخيرة',
                              style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('عرض الكل', style: TextStyle(color: AppColors.primaryGold, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildTransactionsList(transactions),
                        
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textWhite, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'المحفظة الرقمية',
                style: TextStyle(color: AppColors.textWhite, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textWhite, size: 22),
            onPressed: () {
             },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGold, Color(0xFFD4AF37), Color(0xFF9A7B1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الرصيد المتاح حالياً',
                style: TextStyle(color: AppColors.backgroundNavy.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.backgroundNavy.withOpacity(0.6), size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                balance,
                style: const TextStyle(color: AppColors.backgroundNavy, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'sans-serif'),
              ),
              const SizedBox(width: 6),
              const Text(
                'ر.س',
                style: TextStyle(color: AppColors.backgroundNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '• رقم الحساب الافتراضي المرتبط محمي بالكامل',
            style: TextStyle(color: AppColors.backgroundNavy.withOpacity(0.5), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        _buildActionButton(
          label: 'شحن الرصيد',
          icon: Icons.add_card_rounded,
          onTap: () {
          },
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          label: 'سحب الأرباح',
          icon: Icons.account_balance_rounded,
          onTap: () {
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F314D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textWhite.withOpacity(0.04)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tx = items[index];
        final bool isIncome = tx['isIncome'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F314D).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textWhite.withOpacity(0.02)),
          ),
          child: Row(
            children: [
               Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green.withOpacity(0.1) : AppColors.textWhite.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isIncome ? Colors.green : AppColors.textLightGray.withOpacity(0.6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'],
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx['subtitle'],
                      style: TextStyle(color: AppColors.textLightGray.withOpacity(0.5), fontSize: 11),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx['amount'],
                    style: TextStyle(
                      color: isIncome ? Colors.green : AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx['date'],
                    style: TextStyle(color: AppColors.textLightGray.withOpacity(0.3), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}