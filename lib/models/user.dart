import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  final String userId;
  final String displayName;
  final String username;
  final String photoUrl;
  final String email;
  final String bio;

  User({
    this.userId,
    this.displayName,
    this.username,
    this.photoUrl,
    this.email,
    this.bio
  });

  factory User.fromDocument(DocumentSnapshot doc){
    Map userData = doc.data();
    return User(
      userId: userData['userId'],
      displayName: userData['displayName'],
      username: userData['username'],
      photoUrl: userData['photoUrl'],
      email: userData['email'],
      bio: userData['bio']
    );
  }

}