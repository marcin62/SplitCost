import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth =AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Zarejestruj sie w SplitCost'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: RaisedButton(
          child: Text('Zarejestruj się'),
          onPressed: () async{
            dynamic result = await _auth.signInAnon();
            if(result == null){
              print('error signin in');
            } else {
              print('signed in');
              print(result.uid);
            }
          },
        ),
      ),
    );
  }
}