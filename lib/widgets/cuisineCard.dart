import 'package:flutter/material.dart';
import 'package:menu/styles/themes.dart';

class CuisineCard extends StatefulWidget {
  @override
  _CuisineCardState createState() => _CuisineCardState();
}

class _CuisineCardState extends State<CuisineCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Container(
        margin: EdgeInsets.all(10),
        height: 122,
        width: 122,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: applyBoxShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Image(
                image: AssetImage(
                  'assets/images/ringStockImage.jpg',
                ),
                fit: BoxFit.contain,
                height: 94,
              ),
            ),
            Text('Category', style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}
