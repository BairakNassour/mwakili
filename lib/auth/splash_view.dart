import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwakili/auth/LoginView.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/view/GuestHomeView.dart';


class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }
  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    bool rememberMe = prefs.getBool('remember_me') ?? false;
    String? savedEmail = prefs.getString('saved_email');
    String? savedPassword = prefs.getString('saved_password');
    bool savedIsLawyer = prefs.getBool('saved_is_lawyer') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginView(
            rememberedEmail: savedEmail,
            rememberedPassword: savedPassword, isLawyer: savedIsLawyer,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GuestHomeView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 150, 
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.balance,
                    size: 100,
                    color: AppColors.primaryGold,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'تطبيق العدالة القانونية',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textLightGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}