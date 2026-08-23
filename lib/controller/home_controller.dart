import 'package:flutter/material.dart';
import 'package:mwakili/auth/AuthSelectionView.dart';
import 'package:mwakili/auth/UserTypeView.dart';

class HomeController {
  bool isLoggedIn = false; 

 
  void runProtectedAction(BuildContext context, VoidCallback onAllowed) {
    if (isLoggedIn) {
      onAllowed();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تسجيل الدخول أولاً للوصول إلى هذه الميزة',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'MyCustomFont'),
          ),
          backgroundColor: Color(0xFF131F33),
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserTypeView()),
      );
    }
  }
}