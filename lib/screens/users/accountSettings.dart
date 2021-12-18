import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/validators.dart';

class SettingsForm extends StatefulWidget {

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  
  String _currentName;
  String _currentPhone;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<MyUser>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(!snapshot.hasData)
        {
           return Center(
              child: CircularProgressIndicator(),
            );
        } else {
          UserData userData = snapshot.data;
          return Form(
            key: _formKey,
            child: Column(
              children:<Widget> [
                SizedBox(height: 110,),
                Text('Zaaktualizuj swoje dane.',style: TextStyle(fontSize: 18),),
                SizedBox(height: 20,),
                buildNameField(userData.name,"Podaj nazwę użytkownika" , Icon(Icons.person,color: Theme.of(context).cardColor, size: 25.0), "Wpisz nazwę użytkownika"),
                SizedBox(height: 20,),
                buildPhoneField(userData.phone, "Wpisz numertelefonu", Icon(Icons.phone,color: Theme.of(context).cardColor, size: 25.0)),
                SizedBox(height: 20,),
                buildButton(user.uid, userData.email)
              ],
            ),
          );
        }
      }
    );
  }

  Widget buildNameField(String data, String notdata,Icon icon,String manual) => TextFormField(
    initialValue: data ?? notdata,
    decoration: MyDecoration.textInputDecoration.copyWith(hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).backgroundColor,
    suffixIcon: Padding(
      padding: EdgeInsets.only(right: 20),
      child: icon),
    ),
    validator: (val) => val.isEmpty ? manual :null,
    onChanged: (val) => setState(()=> _currentName = val),
  );

  Widget buildPhoneField(String data, String notdata,Icon icon) => TextFormField(
    initialValue: data ?? notdata,
    decoration: MyDecoration.textInputDecoration.copyWith(hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).backgroundColor,    
    suffixIcon: Padding(
      padding: EdgeInsets.only(right: 20),
      child: icon),
    ),
    validator: (val) => validateMobile(val) !=null ? validateMobile(val) :null,
    onChanged: (val) => setState(()=> _currentPhone = val),
  );

  Widget buildButton(String userid,String email) => ElevatedButton(
    style: MyDecoration.mybuttonStyle,
    child: Text('Zaaktualizuj',style: TextStyle(fontSize: 22),),
    onPressed: () async{
      if(_formKey.currentState.validate()){
        int phones = await  DatabaseService(uid: userid).checPhone(_currentPhone);
        int names = await DatabaseService(uid: userid).checUserName(_currentName);
        print(phones);
        print(names);
        if(phones <1 && names <1)
          {
            await DatabaseService(uid: userid).updateUser(_currentName, userid,_currentPhone, email);
          }
      }
    },
  );

}