import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shop/home/pages/chat.dart';
import 'package:shop/home/pages/order.dart';
import 'package:shop/home/pages/profile.dart';
import 'package:shop/home/pages/wallet.dart';
import 'package:shop/home/pages/home.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  
  @override
  State<BottomNav> createState() => _BottomNav();
}

class _BottomNav extends State<BottomNav> {
  int currentTabIndex=0;

  late List<Widget> pages;
  late Widget currentPage;
  late Home homePage;
  late Profile profile;
  late Order order;
  late Wallet wallet;
  late Chat chat;

  @override
  void initState() {
    homePage=const Home();
    order=const Order();
    profile=const Profile();
    wallet=const Wallet();
    chat=const Chat();
    pages =[homePage, order, wallet, chat, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.orange,
        onTap: (int index){
          setState(() {
            currentTabIndex=index;
          });
        },
        items: const [
          Icon(Icons.home_outlined, color: Colors.orange,),
          Icon(Icons.shopping_bag_outlined, color: Colors.orange,),
          Icon(Icons.wallet_outlined, color: Colors.orange,),
          Icon(Icons.message_outlined, color: Colors.orange,),
          Icon(Icons.person_2_outlined, color: Colors.orange,),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}