import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/settings/settings.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';

class UsersManagement extends StatefulWidget {

  MyGroup group;

  UsersManagement({this.group});

  @override
  _UsersManagementState createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<MyUser>(context);

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: StreamBuilder(
        stream: DatabaseService().userCollection.orderBy('email').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container(
              width: MediaQuery.of(context).size.width * 9 / 10,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor.withOpacity(0.50),
                  border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: snapshot.data.docs.map((document) {
                  if(widget.group.members.contains(document['userId']))
                  {
                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            document['userName'],
                            style: TextStyle( fontSize: 20),
                          ),
                          Spacer(),
                          Container(
                            width: 100,
                            child: _removeUser(document['userId'],),
                          ),
                          
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                  }
                else {
                  return SizedBox();
                }
                }).toList(),
              ));
        },
      ),
    );
  }

  Widget _removeUser(String userId,) => ElevatedButton(
    style: MyDecoration.mybuttonStyle,
    child: Icon(Icons.close,color: Colors.red,),
    onPressed: ()async {
      if(userId==widget.group.ownerid){
        ErrorDialog(error: 'Nie możesz usunąć właściciela grupy',context: context).showError();
      }else {
        _showDialog(userId);
      }
    }, 
  );

  void _showDialog(String userId){
    showDialog(
      context: context, 
      builder: (BuildContext context){
      return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("Czy napewno chcesz usunąć tego użytkownika ?"),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async { 
            Navigator.pop(context);
            widget.group.members.remove(userId);
            await DatabaseService().updateMembersOfGroup(widget.group.members, widget.group.groupid);
          },
          child: Text("Usuń użytkownika",style: TextStyle(color: Theme.of(context).hintColor),),
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