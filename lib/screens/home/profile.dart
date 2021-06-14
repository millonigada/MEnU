import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:menu/widgets/header.dart';
import 'package:menu/models/user.dart' as UserModel;

class MyProfilePage extends StatefulWidget {

  final Function logout;
  final UserModel.User currentUser;

  MyProfilePage({this.currentUser, this.logout});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {

  @override
  Widget build(BuildContext context) {
    print(widget.currentUser);
    print("Email: "+widget.currentUser.email.toString());
    print("Display Name: "+widget.currentUser.displayName.toString());
    print("Username: "+widget.currentUser.username.toString());
    print("Photo URL: "+widget.currentUser.photoUrl.toString());
    return Scaffold(
      appBar: headerWidget(
        headerText: 'Profile'
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 25),
            height: 103,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
          ),
          Container(
              child: Text(
                'Upload Image',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor
                ),
              )
          ),
          SizedBox(
            height: 70,
          ),
          Center(
            child: Container(
              width: 379,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: Text(
                          'Display Name',
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.currentUser.displayName
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Theme.of(context).hintColor,
                          ),
                          onPressed: (){

                          }
                      )
                    ],
                  ),
                  Divider(
                    thickness: 0.5,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: Text(
                          'Username',
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.currentUser.username
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Theme.of(context).hintColor,
                          ),
                          onPressed: (){

                          }
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: Text(
                          'Bio',
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.currentUser.bio
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Divider(
                      thickness: 0.5,
                      height: 37,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        child: Text(
                          'Email',
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.currentUser.email
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 0.5,
                    height: 37,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(onPressed: widget.logout, child: Text("Signout"))
        ],
      ),
    );
  }
}
