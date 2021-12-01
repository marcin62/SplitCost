import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color1,
      body: StreamBuilder(
        stream: DatabaseService().userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('messages').orderBy('date',descending: false).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else{
                  return ListView(
                     children: snapshot.data.docs.map<Widget>((document){
                       return MessageTile(message: document['message']);
                     }).toList(),
                  );
                }
        }),
      );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  MessageTile({this.message});

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24,vertical: 8),
      margin: EdgeInsets.symmetric(vertical: 8,),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MyColors.color3,MyColors.color4]
          ),
        borderRadius: BorderRadius.only(topLeft:Radius.circular(23),topRight:Radius.circular(23),bottomRight: Radius.circular(23) ),
        ),
      child: Text(message,style: TextStyle(color: MyColors.white,fontSize: 17),),
      ),
    );
  }
}