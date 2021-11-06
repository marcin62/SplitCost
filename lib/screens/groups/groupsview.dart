import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:uuid/uuid.dart';

import 'group.dart';

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
              return Group(groupname: document['groupName'],groupid: document['groupId'],ownerid: document['ownerId'],);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // // Add your onPressed code here!
        },
        splashColor: MyColors.color4,
        child: Icon(Icons.add,color: MyColors.color1,),
        backgroundColor: MyColors.color5,
      ),
    );
  }
}