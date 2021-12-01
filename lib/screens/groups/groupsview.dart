import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/screens/groups/members.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:uuid/uuid.dart';

import 'group.dart';

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // final User user = auth.currentUser;
  // // final uid = user.uid;

class GroupsView extends StatefulWidget {
  @override
  _GroupsViewState createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color1,
      body: StreamBuilder(
        stream: DatabaseService().groupsCollection.orderBy('groupName').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data.docs.map((document){
              return Group(groupname: document['groupName'],groupid: document['groupId'],ownerid: document['ownerId'],members : document['members']);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         _showDialog();
        },
        splashColor: MyColors.color4,
        child: Icon(Icons.add,color: MyColors.color1,),
        backgroundColor: MyColors.color5,
      ),
    );
  }


  void _showDialog(){
    String groupName="";
    showDialog(
      context: context, 
      builder: (BuildContext context){
         return AlertDialog(
            backgroundColor: MyColors.color4,
            title: Text("Podaj nazwę tworzonej grupy"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            content: TextFormField(
                       decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Nazwa grupy',
                                suffixIcon: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(Icons.group,
                                        color: MyColors.color2, size: 25.0)),
                              ),
                      onChanged: (val) {
                        setState(() => groupName = val);
                      },
                ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                 if(groupName == "")
                  ErrorDialog(error: "Nie podałeś nazwy grupy",context: context).showError();
                  //_showError("Nie podałeś nazwy grupy");
                 else{
                  List members = new List();
                  members.add(uid);
                  await DatabaseService().updateGroupData(groupName, Uuid().v4(), uid, members);
                  Navigator.pop(context);
                 }
                 },
                child: Text("Stwórz grupe",style: TextStyle(color: Colors.black),),
              ),
              TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text("Anuluj",style: TextStyle(color: Colors.black),),
              ),
            ],
            );
      }
    );
  }
}