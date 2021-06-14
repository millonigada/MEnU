import 'package:flutter/material.dart';
import 'package:menu/models/recipe.dart';
import 'package:menu/services/database.dart';
import 'package:menu/widgets/header.dart';

class RecipePage extends StatefulWidget {

  final Recipe recipe;
  RecipePage({this.recipe});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {

  List<Container> ingredientsList = [];
  List<String> stepsList = [];
  DatabaseService ds = DatabaseService();

  generateIngredients() {
    int index=0;
    String ingredientsString = widget.recipe.ingredientIds;
    List ingredientQuantityRawList = ingredientsString.split(',');
    print("ingredientQuantityRawList: $ingredientQuantityRawList");
    print("ingredientQuantityRawList[1]: ${ingredientQuantityRawList[1]}");
    List cleanIngredientQuantityRawList = ingredientQuantityRawList;
    cleanIngredientQuantityRawList.removeAt(0);
    print("cleanIngredientQuantityRawList: $ingredientQuantityRawList");

    cleanIngredientQuantityRawList.forEach((rawIngredientString) {
      print("index: $index");
      List tempList = rawIngredientString.split(' - ');
      print("tempList: $tempList");
      ds.getIngredientById(tempList[0]).then((doc){
        setState(() {
          ingredientsList.add(ingredientListTile(index: (index+1), textWidget: Text("${ds.getIngredientName(doc)} - ${tempList[1]}")));
        });
      });
      print("ingredientsList: $ingredientsList");
      index++;
    });
    setState(() {
      stepsList = widget.recipe.steps.split(',');
    });
    print("Ingredients List: $ingredientsList");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerWidget(
        headerText: widget.recipe.recipeTitle
      ),
      body: ListView(
        children: [
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.recipe.mediaUrl),
                      )
                  ),
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              widget.recipe.recipeDescription,
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Divider(),
          ListTile(
            title: Text("INGREDIENTS", style: Theme.of(context).textTheme.headline3),
          ),
          ListTile(
            title: Column(
              children: ingredientsList,
            ),
          ),
          Divider(),
          ListTile(
            title: Text("STEPS", style: Theme.of(context).textTheme.headline3),
          ),
          stepsList.length==0 ? Container() : ListTile(
            title: Container(
              height: 300,
              child: ListView.builder(
                itemCount: stepsList.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      //padding: EdgeInsets.all(10),
                      leading: CircleAvatar(
                        child: Text(index.toString()),
                      ),
                      title: Text("${stepsList[index]}", maxLines: 15,),
                    );
                  }
              ),
            )
          ),
          TextButton(
            child: Text("View More"),
            onPressed: () async {
              await generateIngredients();
            },
          )
        ],
      ),
    );
  }

  Widget ingredientListTile({index, textWidget}){
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: 15,),
          Container(
            child: textWidget,
          )
        ],
      ),
    );
  }

}
