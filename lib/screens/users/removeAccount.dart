import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';


class RemoveAccount extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService databaseService = new DatabaseService();
  
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<MyUser>(context);

    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("Czy napewno chcesz usunąć konto ?"),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {await deleteUser(user.uid,context);},
          child: Text("Usuń konto",style: TextStyle(color: Theme.of(context).hintColor),),
        ),
        TextButton(
          onPressed: ()=> Navigator.pop(context),
          child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
        ),
      ],
    );
  }

  void deleteUser(String userid,BuildContext context) async {
    Navigator.pop(context);
    await _auth.currentUser.delete().then((value) =>{
      databaseService.deleteUserdata(userid)
    });
  }
}