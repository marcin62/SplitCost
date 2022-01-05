import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/style/colors.dart';

import 'groupdetails.dart';

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
    MyGroup myGroup = new MyGroup(groupName:  widget.groupname,groupid: widget.groupid,members: widget.members,ownerid: widget.groupid);
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
                _buildImage(),
              SizedBox( width: 10,),
              Column(
                children: [
                  Text(widget.groupname, style: TextStyle(color: MyColors.white,fontSize: 25),),
                  Text('Ilość członków: '+widget.members.length.toString(), style: TextStyle(color: MyColors.white,fontSize: 15),),
                ],
              ),
              SizedBox( width: 10,),
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

  Widget _buildImage() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext("${widget.groupid}"), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting)
        {
          return Container(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData){
          return Container(
            width: 80,
            height: 80,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                snapshot.data.toString(),
              ),
            ),
          );
      } else{
        return Container(
            width: 80,
            height: 80,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/logo.jpg'),
            ),
          );
        }
      }),
      SizedBox(width: 20,),
    ],
  );
}