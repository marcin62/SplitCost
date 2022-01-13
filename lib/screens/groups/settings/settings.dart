import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/calculated_state.dart/calculated.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/screens/groups/settings/usersmanagement.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';

class SettingsView extends StatefulWidget {
  File file;
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsView> {
  
  @override
  Widget build(BuildContext context) {
    final group = Provider.of<MyGroup>(context);
    return group.iscalculated ? Calculate() : Scaffold(
      body: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
          child: Column(
            children: [
              // _buildImage(group),
              SizedBox(height: 25,),
              Text("Usuń członków",style: TextStyle(fontSize: 20),),
              SizedBox(height: 15,),
              Container(
                height: 320,
                child:Expanded(child: UsersManagement(group: group,)),
              ),
              SizedBox(height: 20,),
              Container(
                width: MediaQuery.of(context).size.width/5*4,
                child: _buildChangeStateButton(group),
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width/5*4,
                child: _buildGroupName(group),
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width/5*4,
                child: _buildChangePhotoButton(group),
              ),
              SizedBox(height: 10,),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width/5*4,
                  child: _buildRemoveGroupButton(group.groupid),
                ),
              )
            ],
          )
        ),
      );
  }

  Widget _buildImage(MyGroup group) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext("${group.groupid}"), // a previously-obtained Future<String> or null
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
      SizedBox(width: 10,),
      Text(group.groupName,style: TextStyle(color: Theme.of(context).hintColor,fontSize: 45),)
    ],
  );

  Widget _buildGroupName(MyGroup group) => ElevatedButton(
     style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Zmień nazwę grupy',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.info,color: Colors.greenAccent,),
        SizedBox(width: 30,)
      ],
    ),
    onPressed:() async {
     _changegroupname(group);
    }
  );

    Widget _buildChangeStateButton(MyGroup group) => ElevatedButton(
     style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Tryb rozliczeniowy',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.photo_album,color: Colors.greenAccent,),
        SizedBox(width: 30,)
      ],
    ),
    onPressed:() async {
      List<dynamic> newprice = new List();
      for(int i=0;i<group.members.length;i++)
      {
        String temp = await DatabaseService().gettotalpay(group.members[i], group.groupid);
        newprice.add(temp);
      }
      await DatabaseService().updategroupprices(group.groupid, newprice);
      await DatabaseService().updateGrouCalculated(group.groupid, !group.iscalculated);
    }
  );

  Widget _buildChangePhotoButton(MyGroup group) => ElevatedButton(
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
      await uploadFile(group);
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
    onPressed:() async {
      _showDialog(groupid);
    }
  );

  Future uploadFile(MyGroup group) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    final path = result.files.single.path;
    setState(() {
    widget.file = File(path);
    });
    final destination ="${group.groupid}";
    FirebaseApi.uploadFile(destination, widget.file);
  }

  void _showDialog(String groupId){
    showDialog(
      context: context, 
      builder: (BuildContext context){
         return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Czy napewno chcesz usunąć grupę"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await DatabaseService().deletegroup(groupId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                 },
                child: Text("Usuń grupe",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
              TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
            ],
            );
      }
    );
  }

  void _changegroupname(MyGroup group){
    String groupName=group.groupName;
    showDialog(
      context: context, 
      builder: (BuildContext context){
         return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Zmień nazwę grupy"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
             content: TextFormField(
                       decoration: MyDecoration.textInputDecoration.copyWith(hintText: groupName,hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
                                suffixIcon: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(Icons.group,
                                        color: Theme.of(context).cardColor, size: 25.0)),
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
                 else{
                  await DatabaseService().updateGroupName(groupName,group.groupid);
                  Navigator.pop(context);
                 }
                 },
                child: Text("Zmień nazwę",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
              TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
            ],
            );
      }
    );
  }


}