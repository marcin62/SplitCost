import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('myUser');

  Future updateUserData(String userName, String uid, String phoneNumber, String email) async {
    return await userCollection.doc(uid).set({
      'userName' : userName,
      'userId' : uid,
      'phoneNumber' : phoneNumber,
      'email': email,
    });
  }

  Future checUserName(String userName) async {
    QuerySnapshot result = await userCollection.where('userName', isEqualTo: userName).get();
    List <DocumentSnapshot> documents = result.docs;
    return documents.length;
  }

  Future checPhone(String phone) async {
    QuerySnapshot result = await userCollection.where('phoneNumber', isEqualTo: phone).get();
    List <DocumentSnapshot> documents = result.docs;
    return documents.length;
  }
}