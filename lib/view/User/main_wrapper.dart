import 'package:flutter/material.dart';
import 'package:mwakili/component/app_colors.dart';
import 'package:mwakili/view/User/ClientArchiveView.dart';
import 'package:mwakili/view/User/NotificationsView.dart';
import 'package:mwakili/view/User/chat/ClientChatsView.dart';
import 'package:mwakili/view/User/ClientProfileView.dart';
import 'package:mwakili/view/User/HomeView.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 3;

  final List<Widget> _pages = [
    const ClientChatsView(),
    const ClientArchiveView(),
    const ClientProfileView(),
    const HomeView(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        
        title: Padding(
          padding: const EdgeInsets.only(right: 4.0), 
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.gavel, 
                color: AppColors.primaryGold, 
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'موكلي',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo', 
                ),
              ),
            ],
          ),
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0), 
            child: Stack(
              clipBehavior: Clip.none, 
              children: [
                 IconButton(icon: 
                  Icon(Icons.notifications_none_outlined),
                  color: AppColors.textWhite,onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  NotificationsView()));
                  
                    
                  },
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.textWhite.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF132239), 
          selectedItemColor: AppColors.primaryGold,
          unselectedItemColor: AppColors.textLightGray.withOpacity(0.4),
          showSelectedLabels: false, 
          showUnselectedLabels: false,
          iconSize: 24, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'محادثة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_rounded),
              label: 'ملفاتي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'حسابي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'الرئيسية',
            ),
          ],
        ),
      ),
    );
  }
}