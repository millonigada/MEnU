import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu/models/user.dart' as UserModel;
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:menu/services/database.dart';
import 'package:menu/services/storage.dart';
import 'package:menu/widgets/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {

  final UserModel.User currentUser;
  UploadPage({this.currentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override

  TextEditingController recipeTitleController = TextEditingController();
  TextEditingController recipeDescriptionController = TextEditingController();
  TextEditingController cuisineController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController stepsController = TextEditingController();
  List<Map> ingredientsList = [];
  List<Map> allIngredientsList = [];
  List<Map> allCuisinesList = [];
  String ingredientIds = "";
  List stepsList = [];
  String stepsString = "";
  File file;
  bool isUploading = false;
  ImagePicker picker = ImagePicker();
  String postId = Uuid().v4();
  DatabaseService ds = DatabaseService();
  StorageService ss = StorageService();

  @override
  void initState(){
    super.initState();
    getAllIngredients();
    getAllCuisines();
  }

  getAllIngredients() async {
    allIngredientsList = await ds.getIngredientsList();
  }

  getAllCuisines() async {
    allCuisinesList = await ds.getCuisinesList();
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    var pickedImage = await picker.getImage(source: ImageSource.camera, maxWidth: 960, maxHeight: 675);
    File file = File(pickedImage.path);
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    var pickedImage = await picker.getImage(source: ImageSource.gallery, maxWidth: 960, maxHeight: 675);
    File file = File(pickedImage.path);
    setState(() {
      this.file = file;
    });
  }

  selectImage(BuildContext parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text("Create Post"),
            children: [
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: ()=>Navigator.pop(context),
              )
            ],
          );
        }
    );
  }

  Widget buildSplashScreen(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/upload.svg', height: 260),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () => selectImage(context),
              child: Text("Select an Image"),
            ),
          )
        ],
      ),
    );
  }

  clearImage(){
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    var tempDir = await getTemporaryDirectory();
    var path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    File compressedFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedFile;
    });
  }

  Future<String> uploadImage(File file) async {
    TaskSnapshot snapshot = await ss.storageRef.child("post_$postId.jpg").putFile(file);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String recipeTitle, String recipeDescription}){
    ds.recipesRef.doc(postId).set({
      "recipeId": postId,
      "userId": widget.currentUser.userId,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "recipeTitle": recipeTitle,
      "recipeDescription": recipeDescription,
      "ingredientIds": ingredientIds,
      "steps": stepsString,
      "timestamp": DateTime.now(),
      "likes": {}
    });
  }

  appendRecipeIdsInCuisine(String cuisineId, String recipeIds) async {
    await ds.cuisinesRef.doc(cuisineId).update({
      "recipeIds": recipeIds
    });
  }

  appendRecipeIdsInIngredient(String ingredientId, String recipeIds) async {
    await ds.ingredientsRef.doc(ingredientId).update({
      "recipeIds": recipeIds
    });
  }

  putIngredientsInFirestore() async {
    bool flag = false;
    for(int i=0;i<ingredientsList.length;i++){
      flag = false;
      for(int j=0;j<allIngredientsList.length;j++){
        if(ingredientsList[i]["ingredientName"].toLowerCase()==allIngredientsList[j]["ingredientName"].toLowerCase()){
          flag=true;
          setState(() {
            ingredientIds = ingredientIds+",${allIngredientsList[j]["ingredientId"]} - ${ingredientsList[i]["quantity"]}";
          });
          await appendRecipeIdsInIngredient(
              allIngredientsList[j]["ingredientId"],
              (allIngredientsList[j]["recipeIds"]+",$postId")
          );
          break;
        }
      }
      if(flag==false){
        String newIngredientId = Uuid().v4();
        ds.ingredientsRef.doc(newIngredientId).set({
          "ingredientId": newIngredientId,
          "ingredientName": ingredientsList[i]["ingredientName"],
          "recipeIds": postId
        });
        setState(() {
          ingredientIds = ingredientIds+",$newIngredientId - ${ingredientsList[i]["quantity"]}";
        });
      }
    }
  }

  putCuisineInFirestore() async {
    String cuisine = cuisineController.text;
    bool flag = false;
    for(int i=0;i<allCuisinesList.length;i++){
      if(cuisine==allCuisinesList[i]["cuisineName"]){
        flag=true;
        await appendRecipeIdsInCuisine(
            allCuisinesList[i]["cuisineId"],
            (allCuisinesList[i]["recipeIds"]+",$postId")
        );
        break;
      }
    }
    if(flag==false){
      String newCuisineId = Uuid().v4();
      ds.cuisinesRef.doc(newCuisineId).set({
        "cuisineId": newCuisineId,
        "cuisineName": cuisineController.text,
        "recipeIds": postId
      });
    }
  }

  convertStepsListToString(){
    String temp = stepsList[0];
    for(int i=1;i<stepsList.length;i++){
      temp = temp + ",${stepsList[i]}";
    }
    setState(() {
      stepsString = temp;
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    await putIngredientsInFirestore();
    await putCuisineInFirestore();
    convertStepsListToString();
    createPostInFirestore(
      mediaUrl: mediaUrl,
      recipeDescription: recipeDescriptionController.text,
      recipeTitle: recipeTitleController.text
    );
    recipeTitleController.clear();
    recipeDescriptionController.clear();
    cuisineController.clear();
    ingredientsController.clear();
    quantityController.clear();
    stepsController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Widget buildUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: clearImage,
        ),
        title: Text("Input your Recipe."),
        actions: [
          TextButton(
              onPressed: isUploading ? null : () => handleSubmit(),
              child: Text("Post")
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearLoadingWidget() : Text(""),
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
                      image: FileImage(file),
                    )
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  (widget.currentUser.photoUrl),
              ),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: recipeTitleController,
                decoration: InputDecoration(
                  hintText: "Enter Recipe Title",
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.menu_book_outlined),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: recipeDescriptionController,
                decoration: InputDecoration(
                    hintText: "Enter Recipe Description",
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.fastfood_outlined),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: cuisineController,
                decoration: InputDecoration(
                    hintText: "Enter Cuisine",
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.fastfood_sharp),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                setState(() {
                  ingredientsList.add({
                    "ingredientName": ingredientsController.text,
                    "quantity": quantityController.text
                  });
                });
                ingredientsController.clear();
                quantityController.clear();
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 250.0,
                  child: TextField(
                    controller: ingredientsController,
                    decoration: InputDecoration(
                        hintText: "Enter Ingredients",
                        border: InputBorder.none
                    ),
                  ),
                ),
                Container(
                  width: 250.0,
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                        hintText: "Enter Quantity",
                        border: InputBorder.none
                    ),
                  ),
                ),
                Container(
                  height: 200.0,
                  width: 250.0,
                  child: ingredientsList.length==0 ?
                      Center(child: Text("You haven't added any ingredients yet.")) :
                    ListView.builder(
                      itemCount: ingredientsList.length,
                      itemBuilder: (context, index){
                        return Container(
                          padding: EdgeInsets.all(10),
                          width: 200,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${ingredientsList[index]["ingredientName"]} - ${ingredientsList[index]["quantity"]}"),
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
              ],
            )
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.format_list_numbered),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: (){
                  setState(() {
                    stepsList.add(stepsController.text);
                    stepsController.clear();
                  });
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 250.0,
                    child: TextField(
                      controller: stepsController,
                      decoration: InputDecoration(
                          hintText: "Enter Steps",
                          border: InputBorder.none
                      ),
                    ),
                  ),
                  Container(
                      height: 200.0,
                      width: 250.0,
                      child: stepsList.length==0 ?
                      Center(child: Text("You haven't added any steps yet.")) :
                        ListView.builder(
                          itemCount: stepsList.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${index+1}'),
                              ),
                              trailing: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: (){
                                    setState(() {
                                      stepsList.removeAt(index);
                                    });
                                  }
                              ),
                              title: Text("${stepsList[index]}"),
                            );
                          }
                      )
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
