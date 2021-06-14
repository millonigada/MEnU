import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu/screens/authentication/createAccount.dart';
import 'package:menu/screens/home/home.dart';
import 'package:menu/services/database.dart';
import 'package:menu/models/user.dart' as UsersModel;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  DatabaseService ds = DatabaseService();
  bool isAuth = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DateTime timestamp = DateTime.now();
  UsersModel.User currentUser;

  createUserInFirestore() async {
    final GoogleSignInAccount user = _googleSignIn.currentUser;
    DocumentSnapshot doc = await ds.usersRef.doc(user.id).get();

    if(!doc.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
      setState(() {});
      ds.usersRef.doc(user.id).set({
        'userId': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': "",
        'preferences': {},
        'timestamp': timestamp
      });
      doc = await ds.usersRef.doc(user.id).get();
    }
    setState(() {
      currentUser = UsersModel.User.fromDocument(doc);
    });

    print('currentUser: $currentUser');
    print('currentUser username: ${currentUser.username}');
  }

  handleSignIn(GoogleSignInAccount account){
    if(account!=null){
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      print("isAuth: $isAuth");
    } else{
      setState(() {
        isAuth = false;
      });
    }
  }

  login(){
    _googleSignIn.signIn();
  }

  logout(){
    _googleSignIn.signOut();
  }

  Widget buildAuthScreen(){
    print('build auth screen function called');
    print("current user: $currentUser");
    return Home(logoutFunction: logout, currentUser: currentUser);
  }

  Widget buildUnAuthScreen(){
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.orange,
                  Colors.pinkAccent,
                  Colors.pink
                ]
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('MeNU',
              style: TextStyle(
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(child: Text('Sign in with google')),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print("Init state called.");
    _googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    },
    onError: (err){
      print('Error signing in: $err');
    });
    //Reauthenticate user when app is opened
    _googleSignIn.isSignedIn().then((isSignedIn){
      if(isSignedIn){
        _googleSignIn.signInSilently(suppressErrors: false)
            .then((account) {
          handleSignIn(account);
        }).catchError((err){
          print('Error: $err');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
