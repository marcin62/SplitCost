import 'package:flutter/material.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/style/loading.dart';
import 'package:splitcost/validators/validators.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth =AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String userName = '';
  String phone = '';
  String email = '';
  String password = '';
  String password2 = ''; 
  String error ='';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MyColors.color1,
      appBar: AppBar(
        backgroundColor: MyColors.color2,
        elevation: 0.0,
        title: Text('Zarejestruj sie w SplitCost'),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MyColors.color2),
            ),
            icon: Icon(Icons.person),
            label: Text('Zaloguj się'),
            onPressed: () {
              widget.toggleView();
            },
          ),
        ],
      ),
      body:SingleChildScrollView( 
        child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Nazwa użytkownika'),
                  validator: (val) => val.length == 0 ? 'Wpisz nazwę użytkownika' : null,
                  onChanged: (val) {
                    setState(() => userName = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Numer Telefonu'),
                  validator: (val) => validateMobile(val),
                  // validator: (val) => val.length != 9 || validateMobile(val) ? 'Wpisz numer telefonu ( 9 cyfr )' : null,
                  onChanged: (val) {
                    setState(() => phone = val);
                  },
                ),
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
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Hasło'),
                  obscureText: true,
                  validator: (val) => password != password2 ? 'Hasła się różnią' : null,
                  onChanged: (val) {
                    setState(() => password2 = val);
                  },
                ),
                SizedBox(height: 20.0,),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(MyColors.color2),
                  ),
                  child: Text(
                    'Zarejestruj się',
                    style: TextStyle(color: MyColors.color3),
                  ),
                  onPressed: () async {
                    if(_formKey.currentState.validate()){
                      setState(() => loading = true);
                      dynamic result = await _auth.checkIfUsernameIsAvaviable(userName);
                      print(result);
                      if(result !=0 ){
                        setState(() {
                          error = 'Nazwa użytkownika jest już zajęta, podaj inną';
                          loading = false;
                        });
                      } 
                      else {
                        result = await _auth.checkIfPhoneIsAvaviable(phone);
                        if(result !=0 ){
                          setState(() {
                            error = 'Podany numer telefonu jest już używany';
                            loading = false;
                          });
                        } else {
                          result = await _auth.registerWithEmailAndPassword(email,password,userName,phone);
                          if(result == null){
                            setState(() {
                              error = 'Prosze podaj prawidłowy email';
                              loading = false;
                            });
                          }
                        }
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
      ),
    );
  }
}