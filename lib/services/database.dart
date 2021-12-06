import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/group.dart';

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
 Future<String> getUserName(){
   return (userCollection.doc(uid).snapshots() as Map<String,dynamic>)['userName'];
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
}