import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
class UserInfo extends StatefulWidget {
  MyGroup group;
  UserInfo({this.group});
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color1,
      body: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().userCollection.snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  children: snapshot.data.docs.map<Widget>((document){
                    if(widget.group.members.contains(document['userId'])){
                    return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 3 , horizontal: 10),
                      decoration: BoxDecoration(
                        color: MyColors.color5.withOpacity(0.50),
                        border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Column(children: [
                        Text((document['userName'])),
                        Text(document['phoneNumber']),
                      ],),
                    );
                    }
                    else
                    return SizedBox(height: 0,);
                  }).toList(),
                );
              },
            ),
    );
  }
}