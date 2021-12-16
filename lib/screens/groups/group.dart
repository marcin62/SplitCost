import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/validators/errordialog.dart';

import 'groupdetails.dart';

 final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser;
  final uid = user.uid;

class Group extends StatefulWidget {
  final String groupname;
  final String ownerid;
  final String groupid;
  final List members;

  Group({this.groupname,this.groupid,this.ownerid,this.members});

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 40),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor.withOpacity(0.50),
          border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
              Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.jpg'),
                    fit: BoxFit.fill,
                  ),
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white)),
                padding: EdgeInsets. symmetric(vertical: 10.0, horizontal: 5.0)
              ),
              SizedBox( width: 20,),
              Column(
                children: [
                  Text(widget.groupname, style: TextStyle(color: MyColors.white,fontSize: 25),),
                  Text('Ilość członków: '+widget.members.length.toString(), style: TextStyle(color: MyColors.white,fontSize: 15),),
                ],
              ),
              SizedBox( width: 20,),
              SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupDetail(group: MyGroup(ownerid: widget.ownerid,groupName: widget.groupname,groupid: widget.groupid,members: widget.members))),
                  ).then((value) => setState(()=>{}));
                },
                child: Icon(Icons.arrow_forward_rounded, color: Colors.greenAccent, size: 40,) ,
              )
              ],), 
               SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}