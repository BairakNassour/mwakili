import 'package:flutter/material.dart';
import 'package:mwakili/view/lawer/LawerProfile.dart';
import 'package:mwakili/view/lawer/LawyerHomeView.dart';
import 'package:mwakili/view/lawer/chat/lawyer_chats_list_view.dart';
import 'package:mwakili/view/lawer/client_upcoming_cases_view.dart';
import 'package:mwakili/view/lawer/lawyer_appointments_view.dart';

class LawyerMainWrapper extends StatefulWidget {
  const LawyerMainWrapper({Key? key}) : super(key: key);

  @override
  State<LawyerMainWrapper> createState() => _LawyerMainWrapperState();
}

class _LawyerMainWrapperState extends State<LawyerMainWrapper> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const LawyerChatsListView(),
    const ClientUpcomingCasesView(),
    const LawyerHomeView(), 
    const LawyerProfileView(),
    const LawyerAppointmentsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF131F33),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.chat_bubble_outline, 'المحادثات'),
              _buildNavItem(1, Icons.assignment_outlined, 'المهام'),
              _buildNavItem(2, Icons.home_outlined, 'الرئيسية'),
              _buildNavItem(3, Icons.person_outline, 'الحساب'),
              _buildNavItem(4, Icons.balance, 'القضايا'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent, 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white38,
              size: isActive ? 26 : 22,
            ),
            const SizedBox(height: 4),
            if (isActive)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }
}