import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('myUser');
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');

  Future updateUserData(String userName, String uid, String phoneNumber, String email) async {
    return await userCollection.doc(uid).set({
      'userName' : userName,
      'userId' : uid,
      'phoneNumber' : phoneNumber,
      'email': email,
    });
  }

   Future updateGroupData(String groupName, String groupid, String ownerid) async {
    return await groupsCollection.doc(groupid).set({
      'groupName' : groupName,
      'groupId' : groupid,
      'ownerId' : ownerid,
    });
  }

  Future updateMembersOfGroup(List uid,String groupid) async{
    return await groupsCollection.doc(groupid).update({
      'members' : uid,
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