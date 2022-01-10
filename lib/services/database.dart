import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myDetails.dart';
import 'package:splitcost/models/myExpenses.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myMessage.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:uuid/uuid.dart';

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

  Future updateGroupName(String groupName, String groupid) async {
    return await groupsCollection.doc(groupid).update({
      'groupName' : groupName,
    });
  }

  Future updateMembersOfGroup(List uid,String groupid) async{
    return await groupsCollection.doc(groupid).update({
      'members' : uid,
    });
  }

  Future addExpenses(String groupid,String price, String ownerid, String expenseid, String description ) async {
    Timestamp date = Timestamp.fromDate(DateTime.now());
    return await groupsCollection.doc(groupid).collection('expenses').doc(expenseid).set({
      'expenseid' : expenseid,
      'ownerid' : ownerid,
      'price' : price,
      'description' : description,
      'date' : date,
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

  Future deleteDetails(String groupid,String expensesid) async {
    // return await groupsCollection.doc(groupid).collection('expenses').doc(expensesid).collection('details').doc(id).set({
    //   'owner' : owner,
    //   'detailid' : id,
    //   'howmuch' : howmuch,
    //   'who' : who,
    // });

  groupsCollection.doc(groupid).collection('expenses').doc(expensesid).collection('details').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }

  Future addMessageToUser(String userid,String message, Timestamp date,String groupid) async {
    String id =  Uuid().v4();
    return await userCollection.doc(userid).collection('messages').doc(id).set({
        'date' : date,
        'message' : message, 
        'groupId' : groupid,
        'see' : false,
        'messageid' : id,
      });
  }

  Future makemessageread(String userid,String messageid) async {
    return await userCollection.doc(userid).collection('messages').doc(messageid).update({
      'see' : true,
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
    return price.toStringAsFixed(2);
}
 Future<String> getUserName(){
   return (userCollection.doc(uid).snapshots() as Map<String,dynamic>)['userName'];
 }

 Future<dynamic> getCertainUserName(String userid){
   return (userCollection.doc(userid).snapshots() as Map<String,dynamic>)['userName'];
 }

 Future<String> getUsersKey(String uid) async {
  DocumentSnapshot snapshot = await DatabaseService().userCollection.doc(uid).get();
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  return data['userName']; 
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

Future deleteExpense(String groupid,String expenseid) async
{
  await groupsCollection.doc(groupid).collection("expenses").doc(expenseid).delete();
} 

 Future deleteUserdata(String userid) async {

   userCollection.doc(userid).delete();
   groupsCollection.where('ownerId',isEqualTo: userid).get().then((value) => {
     for(DocumentSnapshot ds in value.docs){
       ds.reference.delete()
     }
   });

   groupsCollection.get().then((group) =>{
     for(DocumentSnapshot ds in group.docs){
       ds.reference.collection('expenses').where('ownerid',isEqualTo: userid).get().then((expenses) =>{
         for(DocumentSnapshot ws in expenses.docs){
           ws.reference.delete()
         }
       })
     }
   });

   groupsCollection.get().then((group) =>{
     for(DocumentSnapshot ds in group.docs){
       ds.reference.collection('expenses').get().then((expenses) =>{
         for(DocumentSnapshot ws in expenses.docs){
           ws.reference.collection('details').where('who',isEqualTo: userid).get().then((value) =>{
             for(DocumentSnapshot ks in value.docs){
               ks.reference.delete()
             }
           })
         }
       })
     }
   });
   
   QuerySnapshot expensequery = await groupsCollection.where('members',arrayContains: userid).get();
   for (int i = 0 ;i <expensequery.docs.length;i++){
     DocumentSnapshot doc = await expensequery.docs.elementAt(i).reference.get();
     List list = (doc.data() as Map<String,dynamic>)['members'];
     String groupid = (doc.data() as Map<String,dynamic>)['groupId'];
     list.remove(userid);
     await updateMembersOfGroup(list, groupid);
   }
 }

  Future deleteDebt(payer, debt,groupid)async{
    await groupsCollection.doc(groupid).get().then((value) => 
    {
      value.reference.collection('expenses').where('ownerid',isEqualTo: payer).get().then((expenses) =>{
        for(DocumentSnapshot doc in expenses.docs)
        {
          doc.reference.collection('details').where('who',isEqualTo: debt).get().then((details) async => {
            for(DocumentSnapshot doc2 in details.docs)
            {
              doc2.reference.delete(),
            }
          }),
        }
      })
    });
  }
  Future deleteDebt2(payer, debt,groupid)async{
    await groupsCollection.doc(groupid).get().then((value) => 
    {
      value.reference.collection('expenses').where('ownerid',isEqualTo: debt).get().then((expenses) =>{
        for(DocumentSnapshot doc in expenses.docs)
        {
          doc.reference.collection('details').where('who',isEqualTo: payer).get().then((details) async => {
            for(DocumentSnapshot doc2 in details.docs)
            {
              doc2.reference.delete(),
            }
          }),
        }
      })
    });
  }

  Future deletegroup(String groupid)async {
    await groupsCollection.doc(groupid).delete();
    await deletemessegesfromgroup(groupid);
  }

  Future deletemessegesfromgroup(String groupid) async {
   userCollection.get().then((value) => {
     for(DocumentSnapshot ds in value.docs){
       ds.reference.collection('messages').where('groupId',isEqualTo: groupid).get().then((value2) => {
         for(DocumentSnapshot ds2 in value2.docs ){
           ds2.reference.delete(),
         }
       })
     }
   });
  }

  Stream<List<MyMessage>> messagesgroup(String group){
    final Query mylist = userCollection.doc(uid).collection('messages').where("groupId", isEqualTo: group).orderBy('date',descending: true);
    if(group == "Wszystko")
      return getMessages();
    return mylist.snapshots().map((snapshot) => snapshot.docs.map((document) => MyMessage.fromFirestore(document.data())).toList());
  }

   Stream<List<MyMessage>> getMessages(){
    return userCollection.doc(uid).collection('messages').orderBy('date',descending: true).snapshots().map((snapshot) => snapshot.docs.map((document) => MyMessage.fromFirestore(document.data())).toList());
  }

  Stream<MyGroup> getGroup(String group){
    return groupsCollection.doc(group).snapshots().map((document) =>MyGroup.fromFirestore(document.data()));
  }

    Stream<List<MyExpenses>> getexpensesgroup(String user,String groupid,DateTimeRange daterange){
    DateTime start = daterange.start;
    DateTime end = daterange.end;
    Query mylist = groupsCollection.doc(groupid).collection('expenses').where('date',isGreaterThanOrEqualTo: Timestamp.fromDate(start)).where('date',isLessThanOrEqualTo: Timestamp.fromDate(end));
    if(user != "Wszystko")
      mylist=mylist.where('ownerid',isEqualTo: user);
    return mylist.orderBy('date',descending: true).snapshots().map((snapshot) => snapshot.docs.map((document) => MyExpenses.fromFirestore(document.data())).toList());
  }

   Stream<List<MyExpenses>> getexpenses(String groupid){
    return groupsCollection.doc(groupid).collection('expenses').snapshots().map((snapshot) => snapshot.docs.map((document) => MyExpenses.fromFirestore(document.data())).toList());
  }

   Stream<List<MyDetails>> getDetails(String group,String expense){
    return groupsCollection.doc(group).collection('expenses').doc(expense).collection('details').snapshots().map((snapshot) => snapshot.docs.map((document) => MyDetails.fromFirestore(document.data())).toList());
  }

   Stream<List<UserData>> getUsers(){
    return userCollection.snapshots().map((snapshot) => snapshot.docs.map((document) => UserData.fromFirestore(document.data())).toList());
  }
}