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
      resizeToAvoidBottomInset: true,
      backgroundColor: MyColors.color1,
      body: SingleChildScrollView(
        child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 50.0),
                Text(
                  'Zaloguj się w SplitCost',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MyColors.white,fontSize: 35,),
                ),
                SizedBox(height: 20,),
                Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.fill,
                    ),
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.white)),
                ),
                SizedBox(height: 20,),
                TextFormField(
                   decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Email',
                            suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.person,
                                    color: MyColors.color2, size: 25.0)),
                          ),
                  validator: (val) => val.isEmpty ? 'Wpisz Email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Hasło',
                            suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.lock,
                                    color: MyColors.color2, size: 25.0)),
                          ),
                  obscureText: true,
                  validator: (val) => val.length < 6 ? 'Wpisz dłuższe hasło (6+)' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                SizedBox(height: 20.0,),
                ElevatedButton(
                  style: MyDecoration.mybuttonStyle,
                  child: Text(
                    'Zaloguj się',
                    style: TextStyle(color: MyColors.white,fontSize: 20),
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
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Nie masz konta? ',style: TextStyle(color: MyColors.white,fontSize: 17),),
                    GestureDetector(
                    onTap: () {
                      widget.toggleView();
                    },
                    child :Text('Zarejestruj się',style: TextStyle(fontWeight:FontWeight.bold,color: MyColors.white,fontSize: 17),),
                    ),
                  ],
                ),
                SizedBox(height: 20.0,),
                Text(
                  error,
                  style: TextStyle(
                    color: MyColors.red,
                    fontSize: 14.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}