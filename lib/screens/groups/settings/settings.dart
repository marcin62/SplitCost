import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/screens/groups/settings/usersmanagement.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';

class SettingsView extends StatefulWidget {
  MyGroup group;
  File file;
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
            //Expanded(child:img),
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
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext("${widget.group.groupid}"), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting)
        {
          return Container(
            height: 90,
            width: 90,
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData){
          return Container(
            width: 90,
            height: 90,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                snapshot.data.toString(),
              ),
            ),
          );
      } else{
        return Container(
            width: 90,
            height: 90,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/logo.jpg'),
            ),
          );
        }
      }),
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
    onPressed:() async {
      await uploadFile();
    }
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

  Future uploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    final path = result.files.single.path;
    setState(() {
    widget.file = File(path);
    });
    final destination ="${widget.group.groupid}";
    FirebaseApi.uploadFile(destination, widget.file);
  }

}