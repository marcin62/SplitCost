import 'package:flutter/material.dart';
import 'package:splitcost/style/colors.dart';


class Group extends StatefulWidget {
  final String groupname;
  final String ownerid;
  final String groupid;

  Group({this.groupname,this.groupid,this.ownerid});

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
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
                Text(widget.ownerid, style: TextStyle(color: MyColors.white,fontSize: 15),),
                Text('Ilość członków: 0', style: TextStyle(color: MyColors.white,fontSize: 15),),
              ],
            )
            ],), 
        ],
      ),
    );
  }
}