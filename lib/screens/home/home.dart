import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/colors.dart';

import 'drawer.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MyColors.color1,
      appBar: AppBar(
      title: Text('SplitCost'),
      backgroundColor: MyColors.color2, 
      elevation: 0.0,
      ),
      drawer: new DrawerWidget(auth: _auth),
    );
  }
}