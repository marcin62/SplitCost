import 'package:flutter/material.dart';
import 'package:splitcost/style/colors.dart';

class ErrorDialog {

  final String error;
  final BuildContext context;
  ErrorDialog({this.error,this.context});
  
  void showError(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: ()=> Navigator.pop(context),
             child: Text("Ok",style: TextStyle(color: Theme.of(context).hintColor),)
             )
          ],
        );
      }
    );
  }
}