import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu/models/user.dart';
import 'package:menu/screens/home/profile.dart';
import 'package:menu/screens/home/search.dart';
import 'favourites.dart';
import 'homepage.dart';
import 'myRecipes.dart';

class Home extends StatefulWidget {
  final Function logoutFunction;
  final User currentUser;
  Home({this.logoutFunction, this.currentUser});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  PageController _pageViewController;
  int pageIndex = 0;

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    _pageViewController.jumpToPage(pageIndex);
  }

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(
      initialPage: 0
    );
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageViewController,
        children: [
          HomePage(currentUser: widget.currentUser),
          SearchPage(currentUser: widget.currentUser),
          MyRecipesPage(currentUser: widget.currentUser),
          MyProfilePage(currentUser: widget.currentUser, logout: widget.logoutFunction,)
        ],
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person)
          ),
        ],
      ),
    );
  }
}
