import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';

class PaymentSettingsView extends StatelessWidget {
  const PaymentSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context)), const Text('إعدادات الدفع والبطاقات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ListTile(
                        tileColor: const Color(0xFF1F314D),
                        leading: const Icon(Icons.credit_card, color: AppColors.primaryGold),
                        title: const Text('مدى ينتهي بـ 5432', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('البطاقة الأساسية للخصم والشحن', style: TextStyle(color: AppColors.textLightGray, fontSize: 11)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGold)),
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: AppColors.primaryGold),
                        label: const Text('إضافة بطاقة دفع جديدة', style: TextStyle(color: AppColors.primaryGold)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}