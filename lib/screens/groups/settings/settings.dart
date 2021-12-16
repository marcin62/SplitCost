import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/settings/usersmanagement.dart';
import 'package:splitcost/style/inputdecoration.dart';

class SettingsView extends StatefulWidget {
  MyGroup group;

  SettingsView({this.group});
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 20),
        child: Column(
          children: [
            _buildImage(),
            SizedBox(height: 20,),
            Text("Usuń członków",style: TextStyle(fontSize: 20),),
            SizedBox(height: 10,),
            Expanded(child: UsersManagement(group: widget.group,)),
            Container(
              width: MediaQuery.of(context).size.width/5*4,
              child: _buildChangePhotoButton(widget.group.groupid),
            ),
            SizedBox(height: 10,),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width/5*4,
                child: _buildRemoveGroupButton(widget.group.groupid),
              ),
            )
          ],
        )
      )
    );
  }

  Widget _buildImage() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo.jpg'),
            fit: BoxFit.fill,
          ),
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.white)),
      ),
      SizedBox(width: 20,),
      Text(widget.group.groupName,style: TextStyle(color: Theme.of(context).hintColor,fontSize: 45),)
    ],
  );

  Widget _buildChangePhotoButton(String groupid) => ElevatedButton(
     style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Zmień zdjęcie',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.photo_album,color: Colors.greenAccent,),
        SizedBox(width: 30,)
      ],
    ),
    onPressed:() async {}
  );

  Widget _buildRemoveGroupButton(String groupid) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Usuń grupe',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.delete_forever,color: Colors.red,),
        SizedBox(width: 30,)
      ],
    ),
    onPressed:() async {}
  );

}