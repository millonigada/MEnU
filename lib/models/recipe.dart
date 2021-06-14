import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {

  final String recipeId;
  final String userId;
  final String username;
  final String recipeDescription;
  final String recipeTitle;
  final String mediaUrl;
  final String ingredientIds;
  final String steps;
  final dynamic likes;

  Recipe({
    this.ingredientIds,
    this.likes,
    this.mediaUrl,
    this.recipeDescription,
    this.recipeId,
    this.recipeTitle,
    this.steps,
    this.userId,
    this.username
  });

  getLikeCount(){
    if(likes == null){
      return 0;
    }
    int count = 0;
  }

  factory Recipe.fromDocument(DocumentSnapshot doc){
    Map recipeData = doc.data();
    return Recipe(
      ingredientIds: recipeData['ingredientIds'],
      likes: recipeData['likes'],
      mediaUrl: recipeData['mediaUrl'],
      recipeDescription: recipeData['recipeDescription'],
      recipeId: recipeData['recipeId'],
      recipeTitle: recipeData['recipeTitle'],
      steps: recipeData['steps'],
      userId: recipeData['userId'],
      username: recipeData['username']
    );
  }

}