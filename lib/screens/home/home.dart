import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/colors.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color1,
      appBar: AppBar(
      title: Text('SplitCost'),
      backgroundColor: MyColors.color2, 
      elevation: 0.0,
      actions: <Widget>[
        TextButton.icon(
          icon: Icon(Icons.person), 
          //
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MyColors.color3),
          ),
          //
          label: Text('Wyloguj się'),
          onPressed: () async {
            await _auth.signOut();
          },
        ),
      ],
      ),
    );
  }
}