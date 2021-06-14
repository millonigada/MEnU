import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu/models/recipe.dart';

class DatabaseService{

  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  var usersRef = FirebaseFirestore.instance.collection("users");
  var recipesRef = FirebaseFirestore.instance.collection("recipes");
  var ingredientsRef = FirebaseFirestore.instance.collection("ingredients");
  var cuisinesRef = FirebaseFirestore.instance.collection("cuisines");

  // DatabaseService(){
  //   _usersRef = _firestoreInstance.collection('users');
  // }

  getUserById(String id) async {
    DocumentSnapshot doc = await usersRef.doc(id).get();
    return doc;
  }

  getRecipeById(String id) async {
    DocumentSnapshot doc = await recipesRef.doc(id).get();
    return doc;
  }

  getIngredientById(String id) async {
    DocumentSnapshot doc = await ingredientsRef.doc(id).get();
    return doc;
  }

  getCuisineById(String id) async {
    DocumentSnapshot doc = await cuisinesRef.doc(id).get();
    return doc;
  }

  String getIngredientName(DocumentSnapshot doc){
    Map data = doc.data();
    return data['ingredientName'];
  }

  Future<Map> getPreferencesByUserId(String id) async {
    DocumentSnapshot doc = await usersRef.doc(id).get();
    Map data = doc.data();
    if(data['preferences']!=null||data['preferences']!={}){
      return data['preferences'];
    }
    else{
      return {};
    }
  }

  savePreferencesByUserId({String id, List<String> ingredientKeys}) async {
    Map temp = await getPreferencesByUserId(id);
    ingredientKeys.forEach((key) {
      if(temp.containsKey(key)){
        temp[key]+=1;
      } else {
        temp[key]=1;
      }
    });
    await usersRef.doc(id).update({
      "preferences": temp
    });
  }

  getIngredientByName(String ingredient) async {
    QuerySnapshot snapshot = await ingredientsRef.where('ingredientName',isEqualTo: ingredient).get();
    if(snapshot.docs.isEmpty){
      return "";
    }
    else{
      String recipeIds = "";
      snapshot.docs.forEach((doc) {
        Map data = doc.data();
        recipeIds = data['recipeIds'];
      });
      return recipeIds;
    }
  }

  Future<List> getIngredientsList() async {
    QuerySnapshot snapshot = await ingredientsRef.get();
    List<Map> ingredientsList = [];
    snapshot.docs.forEach((doc) {
      Map data = doc.data();
      ingredientsList.add(
        {
          "ingredientId": data["ingredientId"],
          "ingredientName": data["ingredientName"],
          "recipeIds": data["recipeIds"]
        }
      );
    });
    return ingredientsList;
  }

  Future<List> getCuisinesList() async {
    QuerySnapshot snapshot = await cuisinesRef.orderBy('cuisineName').get();
    List<Map> cuisinesList = [];
    snapshot.docs.forEach((doc) {
      Map data = doc.data();
      cuisinesList.add(
          {
            "cuisineId": data["cuisineId"],
            "cuisineName": data["cuisineName"],
            "recipeIds": data["recipeIds"]
          }
      );
    });
    return cuisinesList;
  }

  Future<List> getMyRecipes(String userId) async {
    QuerySnapshot snapshot = await recipesRef.where('userId',isEqualTo: userId).get();
    List<Recipe> recipesList = [];
    snapshot.docs.forEach((doc) {
      Map data = doc.data();
      recipesList.add(
          Recipe.fromDocument(doc)
      );
    });
    print("myRecipesList in Database: $recipesList");
    return recipesList;
  }

  Future<List> getAllRecipes(String userId) async {
    QuerySnapshot snapshot = await recipesRef.where('userId',isNotEqualTo: userId).get();
    List<Recipe> recipesList = [];
    snapshot.docs.forEach((doc) {
      Map data = doc.data();
      recipesList.add(
          Recipe.fromDocument(doc)
      );
    });
    return recipesList;
  }

}