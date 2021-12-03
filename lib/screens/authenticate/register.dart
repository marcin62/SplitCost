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
      body:SingleChildScrollView( 
        child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 50.0),
                Text(
                  'Zarejestruj się w SplitCost',
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
                                  border: Border.all(
                                      width: 2, color: Colors.white)),
                            ),
                SizedBox(height: 20,),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Nazwa użytkownika',hintStyle: TextStyle(color: MyColors.color2, fontSize: 17),fillColor: MyColors.color5,
                   suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.person,
                                    color: MyColors.color2, size: 25.0)),),
                  validator: (val) => val.length == 0 ? 'Wpisz nazwę użytkownika' : null,
                  onChanged: (val) {
                    setState(() => userName = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Numer Telefonu',hintStyle: TextStyle(color: MyColors.color2, fontSize: 17),fillColor: MyColors.color5, suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.phone,
                                    color: MyColors.color2, size: 25.0)),),
                  validator: (val) => validateMobile(val),
                  onChanged: (val) {
                    setState(() => phone = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Email', hintStyle: TextStyle(color: MyColors.color2, fontSize: 17),fillColor: MyColors.color5,suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.email,
                                    color: MyColors.color2, size: 25.0)),),
                  validator: (val) => val.isEmpty ? 'Wpisz Email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Hasło',hintStyle: TextStyle(color: MyColors.color2, fontSize: 17),fillColor: MyColors.color5, suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.lock,
                                    color: MyColors.color2, size: 25.0)),),
                  obscureText: true,
                  validator: (val) => val.length < 6 ? 'Wpisz dłuższe hasło (6+)' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Powtórz Hasło',hintStyle: TextStyle(color: MyColors.color2, fontSize: 17),fillColor: MyColors.color5, suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.lock,
                                    color: MyColors.color2, size: 25.0)),),
                  obscureText: true,
                  validator: (val) => password != password2 ? 'Hasła się różnią' : null,
                  onChanged: (val) {
                    setState(() => password2 = val);
                  },
                ),
                SizedBox(height: 20.0,),
                ElevatedButton(
                  style: MyDecoration.mybuttonStyle,
                  child: Text(
                    'Zarejestruj się',
                    style: TextStyle(color: MyColors.white,fontSize: 20)
                  ),
                  onPressed: () async {
                    if(_formKey.currentState.validate()){
                      setState(() => loading = true);
                      dynamic result = await _auth.checkIfUsernameIsAvaviable(userName);
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
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Masz konto? ',style: TextStyle(color: MyColors.white,fontSize: 17),),
                    GestureDetector(
                    onTap: () {
                      widget.toggleView();
                    },
                    child :Text('Zaloguj się',style: TextStyle(fontWeight:FontWeight.bold,color: MyColors.white,fontSize: 17),),
                    ),
                  ],
                ),
                SizedBox(height: 12.0,),
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