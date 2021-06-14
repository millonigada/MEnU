import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu/models/recipe.dart';
import 'package:menu/services/database.dart';
import 'package:menu/widgets/header.dart';
import 'package:menu/widgets/loading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:menu/models/user.dart' as UserModel;
import 'package:menu/widgets/recipeCard.dart';

class SearchPage extends StatefulWidget {

  final UserModel.User currentUser;
  SearchPage({this.currentUser});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  
  DatabaseService ds = DatabaseService();
  Future<QuerySnapshot> titleSearchResultsFuture;
  TextEditingController titleSearchController = TextEditingController();
  List<RecipeCard> ingredientSearchResultsList = [];
  TextEditingController ingredientSearchController = TextEditingController();
  List<String> ingredientsList = [];
  List<String> recipeIds = [];
  List<Map> ingredientRecipeIdListMap = [];

  handleTitleSearch(String query){
    Future<QuerySnapshot> users = ds.usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      titleSearchResultsFuture = users;
    });
  }

  clearTitleSearch(){
    print("clearsearch called.");
    titleSearchResultsFuture = null;
    titleSearchController.clear();
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

  int countOccurences(List l, element){
    if(l==null||l.isEmpty){
      return 0;
    }
    var foundElements = l.where((e) => e == element);
    return foundElements.length;
  }

  handleIngredientSearch() {
    print("Handle Search Called");
    List allRecipeIdsList = [];
    ingredientRecipeIdListMap.forEach((element) {
      allRecipeIdsList+=(element['recipeIds']);
    });
    List distinctRecipeIds = allRecipeIdsList.toSet().toList();
    List recipeIdFrequency = [];
    for(int i=0;i<distinctRecipeIds.length;i++){
      recipeIdFrequency.add({
        "recipeId": distinctRecipeIds[i],
        "frequency": countOccurences(allRecipeIdsList, distinctRecipeIds[i])
      });
    }
    print("recipeIdFrequency: $recipeIdFrequency");
    recipeIdFrequency.sort((a,b) => (a["frequency"]).compareTo(b["frequency"]));
    List recipeIdFrequencySorted = List.from(recipeIdFrequency.reversed);
    List<RecipeCard> temp = [];
    recipeIdFrequencySorted.forEach((recipe) async {
      temp.add(RecipeCard(recipeDetails: Recipe.fromDocument(await ds.getRecipeById(recipe['recipeId'])), ingredientMatch: recipe['frequency'],));
    });
    setState(() {
      ingredientSearchResultsList = temp;
    });
  }

  Widget buildIngrediantsSearchField(){
    return Column(
      children: [
        TextFormField(
          controller: ingredientSearchController,
          decoration: InputDecoration(
              hintText: "Enter ingredients",
              filled: true,
              prefixIcon: Icon(
                Icons.receipt,
                size: 28.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: (){
                  setState(() {
                    ingredientsList.add(ingredientSearchController.text.toLowerCase());
                  });
                  ingredientSearchController.clear();
                },
              )
          ),
          //onFieldSubmitted: handleSearch(searchController.text),
        ),
        Container(
            height: 200.0,
            width: 350.0,
            child: ingredientsList.length==0 ?
            Center(child: Text("You haven't added any ingredients yet.")) :
            ListView.builder(
                itemCount: ingredientsList.length,
                itemBuilder: (context, index){
                  return Container(
                    padding: EdgeInsets.only(left: 15, right: 5,top: 5,bottom: 5),
                    margin: EdgeInsets.only(top: 10),
                    width: 200,
                    color: Colors.grey[100],
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(ingredientsList[index]),
                        Spacer(),
                        IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: (){
                              setState(() {
                                ingredientsList.removeAt(index);
                              });
                            }
                        )
                      ],
                    ),
                  );
                }
            )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
                onPressed: (){
                  ingredientsList.forEach((ingredient) async {
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
                    print("IngredientRecipeIdListMap: $ingredientRecipeIdListMap");
                  });
                  handleIngredientSearch();
                  setState(() {});
                },
                icon: Icon(Icons.search),
                label: Text("Search")
            ),
            SizedBox(width: 20),
            TextButton.icon(
                onPressed: () async {
                  await ds.savePreferencesByUserId(
                    id: widget.currentUser.userId,
                    ingredientKeys: ingredientsList
                  );
                  setState(() {
                    ingredientSearchController.clear();
                    ingredientSearchResultsList.clear();
                    ingredientRecipeIdListMap.clear();
                    ingredientsList.clear();
                  });
                },
                icon: Icon(Icons.clear),
                label: Text("Clear Results")
            )
          ],
        )
      ],
    );
  }

  Widget buildTitleSearchField(){
    return TextFormField(
      controller: titleSearchController,
      decoration: InputDecoration(
          hintText: "Search for a recipe",
          filled: true,
          prefixIcon: Icon(
            Icons.receipt,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: (){},
          )
      ),
      onFieldSubmitted: handleTitleSearch(titleSearchController.text),
    );
  }

  Widget buildTitleSearchResults(){
    return Container(
      child: FutureBuilder(
        future: titleSearchResultsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return circularLoadingWidget();
          }
          List<UserResult> searchResults = [];
          snapshot.data.docs.forEach((doc) {
            UserModel.User user = UserModel.User.fromDocument(doc);
            UserResult userResult = UserResult(user: user);
            searchResults.add(userResult);
          });
          return ListView(
            children: searchResults,
          );
        },
      ),
    );
  }

  Widget buildNoContent(){
    print("no content called.");
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        children: [
          Center(
            child: Text("You haven't searched for anything yet."),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerWidget(headerText: "Search"),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text("Search by recipe title or creator", style: Theme.of(context).textTheme.headline3),
              // SizedBox(
              //   height: 10,
              // ),
              // buildTitleSearchField(),
              SizedBox(
                height: 20,
              ),
              Text("Search by ingredients", style: Theme.of(context).textTheme.headline3),
              SizedBox(
                height: 10,
              ),
              buildIngrediantsSearchField(),
              ingredientSearchResultsList.length==0 ? Container() : Container(height: 330,child: ListView(children: ingredientSearchResultsList,))
            ],
          ),
        ),
      )
    );
  }
}

class UserResult extends StatefulWidget {

  final UserModel.User user;
  UserResult({this.user});

  @override
  _UserResultState createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: (){},
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.user.photoUrl),
              ),
              title: Text(widget.user.displayName),
              subtitle: Text(widget.user.username),
            ),
          ),
          Divider(
            height: 2.0,
          )
        ],
      ),
    );
  }
}

