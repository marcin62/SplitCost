import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  
  final String uid;

  MyUser({this.uid});
}

class UserData {
  final String uid;
  final String name;
  final String phone;
  final String email;

  UserData({this.email,this.name,this.phone,this.uid});
Map<String,dynamic> toMap(){
    return {
      'email' : email,
      'phoneNumber' : phone,
      'userId' : uid,
      'userName' : name,
    };
  }
  UserData.fromSnapchot(DocumentSnapshot snapshot)
      : email = snapshot['email'],
        phone = snapshot['phoneNumber'],
        uid = snapshot['userId'],
        name = snapshot['userName'];

  UserData.fromFirestore(Map<String, dynamic> firestore)
      : email = firestore['email'],
        phone = firestore['phoneNumber'],
        uid = firestore['userId'],
        name = firestore['userName'];
}