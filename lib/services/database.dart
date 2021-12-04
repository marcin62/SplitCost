import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitcost/models/myUser.dart';

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

   Future updateGroupData(String groupName, String groupid, String ownerid, List members) async {
    return await groupsCollection.doc(groupid).set({
      'groupName' : groupName,
      'groupId' : groupid,
      'ownerId' : ownerid,
      'members' : members,
    });
  }

  Future updateMembersOfGroup(List uid,String groupid) async{
    return await groupsCollection.doc(groupid).update({
      'members' : uid,
    });
  }

  Future addExpenses(String groupid,String price, String ownerid, String expenseid, String description ) async {
    return await groupsCollection.doc(groupid).collection('expenses').doc(expenseid).set({
      'expenseid' : expenseid,
      'ownerid' : ownerid,
      'price' : price,
      'description' : description,
    });
  }

  Future addDetailsOfExpenses(String owner, String id, String howmuch, String who,String groupid,String expensesid) async {
    return await groupsCollection.doc(groupid).collection('expenses').doc(expensesid).collection('details').doc(id).set({
      'owner' : owner,
      'detailid' : id,
      'howmuch' : howmuch,
      'who' : who,
    });
  }

  Future addMessageToUser(String userid,String message, Timestamp date) async {
    return await userCollection.doc(userid).collection('messages').doc().set({
        'date' : date,
        'message' : message, 
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

  String getUid(){
    return FirebaseAuth.instance.currentUser.uid;
  }

  Future<String> getprice(String uidd,String groupid,String debtid) async {
    double price = 0;
    QuerySnapshot expensequery = await groupsCollection.doc(groupid).collection('expenses').get();
    for (int i = 0 ;i <expensequery.docs.length;i++){
      QuerySnapshot doc = await expensequery.docs.elementAt(i).reference.collection('details').get();

      for(int k = 0; k< doc.docs.length;k++){
        DocumentSnapshot document = doc.docs.elementAt(k);
        if(document['owner'] == uidd)
        {
          if(document['who'] == debtid)
          {
            price += double.parse(document['howmuch']);
          }
        }else if(document['owner'] == debtid){
          if(document['who'] == uidd)
          {
            price -= double.parse(document['howmuch']);
          }
        }
      } 
    }
    return price.toString();
}

 Stream<UserData> get userData {
   return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
 }

 UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
   return UserData(
     uid: (snapshot.data() as Map<String,dynamic>)['userId'],
     name: (snapshot.data() as Map<String,dynamic>)['userName'],
     email: (snapshot.data() as Map<String,dynamic>)['email'],
     phone: (snapshot.data() as Map<String,dynamic>)['phoneNumber'],
   );
 }

 Future updateUser(String userName, String uidd, String phoneNumber, String email) async {
    return await userCollection.doc(uidd).set({
      'userName' : userName,
      'userId' : uidd,
      'phoneNumber' : phoneNumber,
      'email': email,
    });
  }


}