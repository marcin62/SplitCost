import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/services/database.dart';

import '../groupdetails.dart';

class PayDebt extends StatelessWidget {
  String owner="";
  String userid = "";
  MyGroup group;
  String price;
  PayDebt({this.group,this.owner,this.userid,this.price});

  @override
  Widget build(BuildContext context) {
           return StatefulBuilder( builder: (context,setState){
         return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Spłacany koszt jest tylko wirtualy, nie przelewamy pieniędzy, czy aby napewno chcesz to zrobić ?"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  String username = await DatabaseService().getUsersKey(userid);
                  DatabaseService().deleteDebt(userid, owner, group.groupid);
                  DatabaseService().deleteDebt2(userid, owner, group.groupid);
                  DatabaseService().addMessageToUser(owner, "Spłaciłeś dług użytkownikowi " +  username +" na kwotę "+ price+ " w grupie " + group.groupName +".", Timestamp.fromDate(DateTime.now()));
                  Navigator.pop(context);
                  Navigator.pop(context); //cos trzeba poprawic;
                  MaterialPageRoute(builder: (context) => GroupDetail(group: MyGroup(ownerid: group.ownerid,groupName: group.groupName,groupid:group.groupid,members: group.members)));
                },
                child: Text("Spłać dług",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
              TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
            ],
            );});
  }
}