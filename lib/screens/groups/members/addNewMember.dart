import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/group.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:splitcost/validators/validators.dart';

import '../groupdetails.dart';

class AddMember extends StatelessWidget {
  String phonenumber="";
  String err = "";
  MyGroup group;
  AddMember({this.group});

  @override
  Widget build(BuildContext context) {
           return StatefulBuilder( builder: (context,setState){
         return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Podaj numer telefonu nowego uczestnika"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            content: TextFormField(
                       decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Numer Telefonu',
                                suffixIcon: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(Icons.phone,
                                        color: Theme.of(context).cardColor, size: 25.0)),
                              ),
                      onChanged: (val) {
                        setState(() => phonenumber = val);
                      },
                ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                 err = validateMobile(phonenumber);
                 if( err != null){
                  ErrorDialog(error: err,context: context).showError();
                 }
                 else{
                   bool ispresent = false;
                   bool isuser = false;
                   QuerySnapshot snap = await DatabaseService().userCollection.where('phoneNumber', isEqualTo: phonenumber).get();
                   snap.docs.forEach((element) {
                     isuser=true;
                     if(group.members.contains(element['userId']))
                      ispresent = true;
                     else
                      group.members.add(element['userId']);
                   });
                   if(ispresent)
                   {
                    ErrorDialog(error: "Użytkownik już jest w grupie",context: context).showError();
                   }
                   else if (isuser == false)
                   {
                     ErrorDialog(error: "Podany użytkownik nie istnieje",context: context).showError();
                   }
                   else {
                    await DatabaseService().updateMembersOfGroup(group.members, group.groupid);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupDetail(group: MyGroup(ownerid: group.ownerid,groupName: group.groupName,groupid:group.groupid,members: group.members))),);
                   }
                 }
                 },
                child: Text("Dodaj użytkownika",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
              TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
              ),
            ],
            );});
  }
}