import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/usersInfo.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:splitcost/validators/validators.dart';

import 'groupdetails.dart';

class Members extends StatefulWidget {

  MyGroup group;
  Members({this.group});

  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color1,
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 40),
        child: Column(
          children: [
            Row(
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
                Text(widget.group.groupName,style: TextStyle(color: MyColors.white,fontSize: 45),)
              ],
            ),
            SizedBox(height: 15,),
            Expanded(child: UserInfo(group: widget.group)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         _showDialog();
        },
        splashColor: MyColors.color4,
        child: Icon(Icons.add,color: MyColors.color1,),
        backgroundColor: MyColors.color5,
      ),
    );
  }

  void _showDialog(){
    String phonenumber="";
    String err;
    showDialog(
      context: context, 
      builder: (BuildContext context){
         return AlertDialog(
            backgroundColor: MyColors.color4,
            title: Text("Podaj numer telefonu nowego uczestnika"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            content: TextFormField(
                       decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Numer Telefonu',
                                suffixIcon: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(Icons.phone,
                                        color: MyColors.color2, size: 25.0)),
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
                     if(widget.group.members.contains(element['userId']))
                      ispresent = true;
                     else
                      widget.group.members.add(element['userId']);
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
                    await DatabaseService().updateMembersOfGroup(widget.group.members, widget.group.groupid);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupDetail(group: MyGroup(ownerid: widget.group.ownerid,groupName: widget.group.groupName,groupid: widget.group.groupid,members: widget.group.members))),);
                   }
                 }
                 },
                child: Text("Dodaj użytkownika",style: TextStyle(color: Colors.black),),
              ),
              TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text("Anuluj",style: TextStyle(color: Colors.black),),
              ),
            ],
            );
      }
    );
  }




}

