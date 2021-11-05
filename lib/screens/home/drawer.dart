import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/colors.dart';

class DrawerWidget extends StatelessWidget {

  final AuthService auth;

  const DrawerWidget({
    Key key,
    @required this.auth,
  }):super (key: key);

  @override
  Widget build(BuildContext context) => Drawer(
          child: ListView(
            children: [
              new ListTile(
                tileColor: MyColors.color2,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                title: new Text('Autor',style: TextStyle(color: MyColors.white),),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => About()),
                  // );
                },
                trailing: Wrap(
                  children: <Widget>[
                    Icon(Icons.arrow_forward,color: MyColors.white,), // icon-1
                  ],
                ),
              ),
              new ListTile(
                tileColor: MyColors.color2,
                leading: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                title: new Text('Ustawienia',style: TextStyle(color: MyColors.white)),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SettingsView()),
                  // );
                },
                trailing: Wrap(
                  children: <Widget>[
                    Icon(Icons.arrow_forward,color: MyColors.white,), // icon-1
                  ],
                ),
              ),
              new ListTile(
                tileColor: MyColors.color2,
                leading: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                title: new Text('Wyloguj się',style: TextStyle(color: MyColors.white)),
                onTap: () async {
                  await auth.signOut();
                },
                trailing: Wrap(
                  children: <Widget>[
                    Icon(Icons.arrow_forward,color: MyColors.white,), // icon-1
                  ],
                ),
              ),
            ],
          ),
  );
}