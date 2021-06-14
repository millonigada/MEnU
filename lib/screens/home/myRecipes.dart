import 'package:flutter/material.dart';
import 'package:menu/models/recipe.dart';
import 'package:menu/screens/home/upload.dart';
import 'package:menu/services/database.dart';
import 'package:menu/widgets/header.dart';
import 'package:menu/models/user.dart' as UserModel;
import 'package:menu/widgets/loading.dart';
import 'package:menu/widgets/recipeCard.dart';

class MyRecipesPage extends StatefulWidget {

  final UserModel.User currentUser;
  MyRecipesPage({this.currentUser});

  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {

  List<Recipe> recipesList = [];
  DatabaseService ds = DatabaseService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getMyRecipes();
  }

  getMyRecipes() async {
    setState(() {
      isLoading = true;
    });
    var temp = await ds.getMyRecipes(widget.currentUser.userId);
    setState(() {
      isLoading = false;
      recipesList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerWidget(
        headerText: 'My Recipes'
      ),
      body: ListView(
        children: [
          Container(
            height: 500,
            width: 345,
            child: isLoading ?
                circularLoadingWidget() :
            ListView.builder(
              itemCount: recipesList.length,
              itemBuilder: (context, index){
                return RecipeCard(recipeDetails: recipesList[index]);
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text("Upload"),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return UploadPage(currentUser: widget.currentUser);
                }));
              },
            ),
          ),
        ],
      )
    );
  }
}
