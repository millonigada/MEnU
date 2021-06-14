import 'package:flutter/material.dart';

Widget headerWidget({String headerText, bool removeBackButton = false}){
  return AppBar(
    automaticallyImplyLeading: !removeBackButton,
    backgroundColor: Colors.white,
    title: Text(headerText, style: TextStyle(color: Colors.orange),),
    centerTitle: true,
  );
}