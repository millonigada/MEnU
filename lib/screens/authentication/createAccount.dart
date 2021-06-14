import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menu/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit(){
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: headerWidget(
        headerText: 'Set up your account'
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text("Create a username"),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      autovalidate: true,
                      validator: (val){
                        if(val.trim().length<4 || val.isEmpty){
                          return "Username too short";
                        }
                        else{
                          return null;
                        }
                      },
                      onSaved: (val) => username=val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                        hintText: "Must be atleast 3 charecters"
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 20,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7)
                    ),
                    child: Text(
                      "Submit"
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
