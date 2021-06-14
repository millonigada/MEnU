import 'package:flutter/material.dart';
import 'package:menu/widgets/header.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerWidget(
          headerText: 'Favourites'
      ),
      body: Center(
        child: Text('My Favourite Recipes'),
      ),
    );;
  }
}
