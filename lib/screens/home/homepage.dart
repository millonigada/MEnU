import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:menu/models/recipe.dart';
import 'package:menu/services/database.dart';
import 'package:menu/styles/themes.dart';
import 'package:menu/widgets/cuisineCard.dart';
import 'package:menu/widgets/header.dart';
import 'package:menu/models/user.dart' as UserModel;
import 'package:menu/widgets/loading.dart';
import 'package:menu/widgets/recipeCard.dart';

class HomePage extends StatefulWidget {

  final UserModel.User currentUser;
  HomePage({this.currentUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DatabaseService ds = DatabaseService();
  List<RecipeCard> recommendedRecipes = [];
  List<String> ingredientPreferences = [];
  List<Map> ingredientRecipeIdListMap = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //configurePreferences();
  }

  configurePreferences() async {
    print("methodCalled");
    print("userId: ${widget.currentUser.userId}");
    setState(() {
      isLoading = true;
    });
    var preferenceMap = await ds.getPreferencesByUserId(widget.currentUser.userId);
    print("preferenceMap: $preferenceMap");
    if(preferenceMap=={}||preferenceMap==null){
      print("if called");
      List<Recipe> temp = await ds.getAllRecipes(widget.currentUser.userId);
      print("temp: $temp");
      List<RecipeCard> temp2 = [];
      temp.forEach((element) {
        temp2.add(RecipeCard(recipeDetails: element));
      });
      setState(() {
        isLoading = false;
        recommendedRecipes = temp2;
      });
    } else {
      List keys = preferenceMap.keys.toList();
      print("Keys: $keys");
      keys.sort((a,b) => (preferenceMap[a]).compareTo(preferenceMap[b]));
      print("Keys after sorting: $keys");
      List tempKeys = keys;
      print("temp: $tempKeys");
      setState(() {
        ingredientPreferences = tempKeys;
      });
      print("Ingredient preferences: $ingredientPreferences");
      //List<Map> ingredientRecipeIdListMap = [];
      await ingredientPreferences.forEach((ingredient) async {
        print("Ingredient: $ingredient");
        String temp = await ds.getIngredientByName(ingredient);
        print("temp $temp");
        if(temp==""){
          setState(() {
            ingredientRecipeIdListMap.add(
                {
                  "ingredientName": ingredient,
                  "recipeIds": []
                }
            );
          });
        }
        else{
          setState(() {
            ingredientRecipeIdListMap.add(
                {
                  "ingredientName": ingredient,
                  "recipeIds": getRecipeIdsFromString(temp)
                }
            );
          });
        }
        print("Ingredient Recipe Id List Map: $ingredientRecipeIdListMap");
      });
      //generateRecipes();
      setState(() {
        isLoading = false;
        //recommendedRecipes = tempList;
      });
      // print("Search Called");
      // List allRecipeIdsList = [];
      // // ingredientRecipeIdListMap.forEach((element) {
      // //   print("element: $element");
      // //   allRecipeIdsList+=(element['recipeIds']);
      // // });
      // for(int i=0;i<ingredientRecipeIdListMap.length;i++){
      //   print("ingredientRecipeIdListMapItem: ${ingredientRecipeIdListMap[i]}");
      //   allRecipeIdsList+=ingredientRecipeIdListMap[i]['recipeIds'];
      // }
      // print("all recipe ids list. $allRecipeIdsList");
      // List distinctRecipeIds = allRecipeIdsList.toSet().toList();
      // print("distinct recipe ids list. $distinctRecipeIds");
      // List recipeIdFrequency = [];
      // for(int i=0;i<distinctRecipeIds.length;i++){
      //   print("Inside for loop");
      //   recipeIdFrequency.add({
      //     "recipeId": distinctRecipeIds[i],
      //     "frequency": countOccurences(allRecipeIdsList, distinctRecipeIds[i])
      //   });
      // }
      // print("recipeIdFrequency: $recipeIdFrequency");
      // recipeIdFrequency.sort((a,b) => (a["frequency"]).compareTo(b["frequency"]));
      // List recipeIdFrequencySorted = List.from(recipeIdFrequency.reversed);
      // List<RecipeCard> tempList = [];
      // recipeIdFrequencySorted.forEach((recipe) async {
      //   tempList.add(RecipeCard(recipeDetails: Recipe.fromDocument(await ds.getRecipeById(recipe['recipeId'])), ingredientMatch: recipe['frequency'],));
      // });
      // setState(() {
      //   isLoading = false;
      //   recommendedRecipes = tempList;
      // });
    }
  }

  generateRecipes(){
    print("Search Called");
    List allRecipeIdsList = [];
    // ingredientRecipeIdListMap.forEach((element) {
    //   print("element: $element");
    //   allRecipeIdsList+=(element['recipeIds']);
    // });
    for(int i=0;i<ingredientRecipeIdListMap.length;i++){
      print("ingredientRecipeIdListMapItem: ${ingredientRecipeIdListMap[i]}");
      allRecipeIdsList+=ingredientRecipeIdListMap[i]['recipeIds'];
    }
    print("all recipe ids list. $allRecipeIdsList");
    List distinctRecipeIds = allRecipeIdsList.toSet().toList();
    print("distinct recipe ids list. $distinctRecipeIds");
    List recipeIdFrequency = [];
    for(int i=0;i<distinctRecipeIds.length;i++){
      print("Inside for loop");
      recipeIdFrequency.add({
        "recipeId": distinctRecipeIds[i],
        "frequency": countOccurences(allRecipeIdsList, distinctRecipeIds[i])
      });
    }
    print("recipeIdFrequency: $recipeIdFrequency");
    recipeIdFrequency.sort((a,b) => (a["frequency"]).compareTo(b["frequency"]));
    List recipeIdFrequencySorted = List.from(recipeIdFrequency.reversed);
    print("recipeIdFrequencySorted: $recipeIdFrequencySorted");
    // List<RecipeCard> tempList = [];
    // recipeIdFrequencySorted.forEach((recipe) async {
    //   tempList.add(RecipeCard(recipeDetails: Recipe.fromDocument(await ds.getRecipeById(recipe['recipeId'])), ingredientMatch: recipe['frequency'],));
    // });
    // setState(() {
    //   isLoading = false;
    //   recommendedRecipes = tempList;
    // });
    getRecipes(recipeIdFrequencySorted);
  }

  getRecipes(List recipeIdFrequencySorted){
    print("Inside Set Recommendations: $recipeIdFrequencySorted");
    RecipeCard tempCard;
    recipeIdFrequencySorted.forEach((recipe) async {
      tempCard = RecipeCard(recipeDetails: Recipe.fromDocument(await ds.getRecipeById(recipe['recipeId'])));
      print("tempCard: $tempCard");
      setState(() {
        recommendedRecipes.add(tempCard);
      });
      print("recommendedRecipes: $recommendedRecipes");
    });
    // print("tempList: $tempList");
    // setState(() {
    //   isLoading = false;
    //   recommendedRecipes = tempList;
    // });
    //setRecommendations(tempList);
  }

  getRecipesByCuisine(List recipeIdFrequencySorted){
    print("Inside Sedbckdshns: $recipeIdFrequencySorted");
    RecipeCard tempCard;
    recipeIdFrequencySorted.forEach((recipe) async {
      tempCard = RecipeCard(recipeDetails: Recipe.fromDocument(await ds.getRecipeById(recipe)));
      print("tempCard: $tempCard");
      setState(() {
        recommendedRecipes.add(tempCard);
      });
      print("recommendedRecipes: $recommendedRecipes");
    });
    // print("tempList: $tempList");
    // setState(() {
    //   isLoading = false;
    //   recommendedRecipes = tempList;
    // });
    //setRecommendations(tempList);
  }

  // setRecommendations(List tempList){
  //   print("tempList: $tempList");
  //   setState(() {
  //     isLoading = false;
  //     recommendedRecipes = tempList;
  //   });
  // }

  int countOccurences(List l, element){
    if(l==null||l.isEmpty){
      return 0;
    }
    var foundElements = l.where((e) => e == element);
    return foundElements.length;
  }

  getRecipeIdsFromString(String recipeIdsString){
    List recipeIdsList;
    if(recipeIdsString==""){
      recipeIdsList=[];
    } else {
      recipeIdsList = recipeIdsString.split(',');
      if(recipeIdsList[0]==null||recipeIdsList[0] == ""){
        recipeIdsList.removeAt(0);
      }
    }
    return recipeIdsList;
  }

  @override
  Widget build(BuildContext context) {
    print("recommendedRecipes: $recommendedRecipes");
    return Scaffold(
      appBar: headerWidget(
          headerText: 'Homepage'
      ),
      body: isLoading ? circularLoadingWidget() :
      Container(
        margin: EdgeInsets.only(left: 32, right: 15, top: 15),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl)
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                          widget.currentUser.displayName,
                          style: Theme.of(context).textTheme.headline3
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 25),
                      child: Text(
                          widget.currentUser.username,
                          style: Theme.of(context).textTheme.headline5
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 15),
            FutureBuilder(
                future: ds.getCuisinesList(),
              builder: (context, AsyncSnapshot<List> snapshot){
                if (snapshot.connectionState == ConnectionState.done && snapshot.data!=null){
                  return Container(
                    height: 100,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index){
                          return GestureDetector(
                            onTap: (){
                              print("ontap getting called.");
                              setState(() {
                                recommendedRecipes = [];
                              });
                              getRecipesByCuisine(getRecipeIdsFromString(snapshot.data[index]['recipeIds']));
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.8),
                                //boxShadow: applyBoxShadow(context),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(child: Text(snapshot.data[index]['cuisineName'], style: TextStyle(color: Colors.white),)),
                            ),
                          );
                        }
                    ),
                  );
                }
                else{
                  return Container();
                }
              },
            ),
            recommendedRecipes.length==0 || recommendedRecipes == null ?
                Container(
                  height: 40,
                    child: Center(
                  child: ElevatedButton(
                    child: Text("Start Browsing!"),
                    onPressed: ()async{await configurePreferences();},
                  )
                )) :
                Column(children: recommendedRecipes),
            recommendedRecipes.length==0 || recommendedRecipes == null ?
            Container(
                height: 40,
                child: Center(
                    child: ElevatedButton(
                      child: Text("View Recipes!"),
                      onPressed: ()async{await generateRecipes();},
                    )
                )) :
            Container()
          ],
        ),
      ),
    );
  }
}
