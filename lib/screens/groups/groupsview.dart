import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:uuid/uuid.dart';

import 'group.dart';

class GroupsView extends StatefulWidget {
  @override
  _GroupsViewState createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<MyUser>(context);

    return Scaffold(
      body: StreamBuilder(
        stream: DatabaseService().groupsCollection.where('members',arrayContains: user.uid).orderBy('groupName').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
          {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else if(!snapshot.hasData){
            return ListView(
              children: [
                Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50,),
                  Text("Nie należysz do żadnej grupy, dołącz lub stwórz własną",style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
                  SizedBox(height: 30,),
                  buildImageNoData(),
                ],
              ),
            )
              ],
            );
          }
          else {
          return ListView(
            children: snapshot.data.docs.map((document){
              return Group(groupname: document['groupName'],groupid: document['groupId'],ownerid: document['ownerId'],members : document['members']);
            }).toList(),
          );
        }
        }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         _showDialog(user.uid);
        },
        splashColor: Theme.of(context).secondaryHeaderColor,
        child: Icon(Icons.add,color: Theme.of(context).primaryColor,),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }


  void _showDialog(String userId){
    String groupName="";
    showDialog(
      context: context, 
      builder: (BuildContext context){
         return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Podaj nazwę tworzonej grupy"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            content: TextFormField(
                       decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Nazwa grupy',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
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
                  //_showError("Nie podałeś nazwy grupy");
                 else{
                  List members = new List();
                  members.add(userId);
                  await DatabaseService().updateGroupData(groupName, Uuid().v4(), userId, members);
                  Navigator.pop(context);
                 }
                 },
                child: Text("Stwórz grupe",style: TextStyle(color: Theme.of(context).hintColor),),
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

  Widget buildImageNoData()=>Container(
    width: 300,
    height: 300,
    child: CircleAvatar(
      radius: 0,
      backgroundImage: AssetImage('assets/images/nodata.png'),
    ),
  );
  
}