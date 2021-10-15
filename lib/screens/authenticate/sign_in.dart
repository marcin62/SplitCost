import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/style/loading.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth =AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error ='';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: MyColors.color1,
      appBar: AppBar(
        backgroundColor: MyColors.color2,
        elevation: 0.0,
        title: Text('Zaloguj sie w SplitCost'),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MyColors.color2),
            ),
            icon: Icon(Icons.person),
            label: Text('Zarejestruj się'),
            onPressed: () {
              widget.toggleView();
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Email'),
                validator: (val) => val.isEmpty ? 'Wpisz Email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Hasło'),
                obscureText: true,
                validator: (val) => val.length < 6 ? 'Wpisz dłuższe hasło (6+)' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0,),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(MyColors.color2),
                ),
                child: Text(
                  'Zaloguj się',
                  style: TextStyle(color: MyColors.color3),
                ),
                onPressed: () async {
                  if(_formKey.currentState.validate()){
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if(result == null){
                      setState(() {
                        error = 'Nie udało się zalogować z tymi danymi';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 12.0,),
              Text(
                error,
                style: TextStyle(
                  color: MyColors.error,
                  fontSize: 14.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}