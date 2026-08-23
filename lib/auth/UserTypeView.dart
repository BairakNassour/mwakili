import 'package:flutter/material.dart';
import 'package:mwakili/auth/AuthSelectionView.dart';
import 'package:mwakili/component/app_colors.dart';

class UserTypeView extends StatelessWidget {
  const UserTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('موكلي', style: TextStyle(color: AppColors.primaryGold, fontSize: 45, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Icon(Icons.balance, color: AppColors.primaryGold.withOpacity(0.8), size: 45),
            const SizedBox(height: 50),
            
            _buildTypeCard(
              context: context,
              title: 'محامي',
              icon: Icons.person_pin_rounded, 
              onTap: () => _navigateToNext(context,true),
            ),
            const SizedBox(height: 25),
            
            _buildTypeCard(
              context: context,
              title: 'عميل',
              icon: Icons.person_outline_rounded,
              onTap: () => _navigateToNext(context,false),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context,isLawyer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AuthSelectionView(isLawyer:isLawyer)),
    );
  }

  Widget _buildTypeCard({required BuildContext context, required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          color: const Color(0xFF16253D).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white70, size: 45),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}