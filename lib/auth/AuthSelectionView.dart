import 'package:flutter/material.dart';
import 'package:mwakili/auth/LoginView.dart';
import 'package:mwakili/auth/lawyer_register_view.dart';
import 'package:mwakili/auth/register_view_user.dart';
import 'package:mwakili/component/app_colors.dart';

class AuthSelectionView extends StatelessWidget {
  final bool isLawyer;
  const AuthSelectionView({Key? key, required this.isLawyer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             SizedBox(height: 50),
            const Text(
              'موكلي',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 55,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'تطبيق العدالة القانونة',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF131F33),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 60),

            _buildAuthButton(
              context: context,
              text: 'تسجيل الدخول',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginView(isLawyer:isLawyer)));
              },
            ),
            const SizedBox(height: 20),
            _buildAuthButton(
              context: context,
              text: 'إنشاء حساب',
              onPressed: () {
                if (isLawyer) {
                  
                   Navigator.push(context, MaterialPageRoute(builder: (context) =>  LawyerRegisterView()));
                  
                } else {
                   Navigator.push(context, MaterialPageRoute(builder: (context) =>  RegisterViewUser()));
                  
                }
                
              },
            ),
            
            const Spacer(),
            // IconButton(
            //   onPressed: () {},
            //   icon: Image.asset(
            //    "assets/google.png",
            //     width: 35,
            //   ),
            // ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton({required BuildContext context, required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}