import 'package:flutter/material.dart';
import 'package:menu/models/recipe.dart';
import 'package:menu/screens/home/recipePage.dart';
import 'package:menu/styles/themes.dart';

class RecipeCard extends StatefulWidget {

  final Recipe recipeDetails;
  int ingredientMatch=0;
  bool recommended = false;
  RecipeCard({this.recipeDetails, this.ingredientMatch, this.recommended});

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(recipe: widget.recipeDetails)));
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(left: 10),
        height: 150,
        width: 345,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: applyBoxShadow(context)
        ),
        child: Row(
          children: [
            Container(
              padding: (EdgeInsets.only(right: 10)),
              height: 105,
              width: 105,
              child: Image(
                image: NetworkImage(widget.recipeDetails.mediaUrl),
                fit: BoxFit.cover,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    widget.recipeDetails.recipeTitle,
                  style: Theme.of(context).textTheme.headline3,
                ),
                Flexible(
                    child: Container(
                        child: Text(
                          widget.recipeDetails.recipeDescription,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline5,
                        )
                    )
                ),
                Text(
                  "Creator: ${widget.recipeDetails.username}",
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  widget.ingredientMatch==0 || widget.ingredientMatch==null ? "" : "Ingredient Match: ${widget.ingredientMatch}",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 16
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
