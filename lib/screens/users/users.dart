import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/screens/users/accountSettings.dart';
import 'package:splitcost/screens/users/iconWidget.dart';
import 'package:splitcost/screens/users/removeAccount.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/theme.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  static const keyDarkMode = 'key-dark-mode';
  static const keyCurrency = 'key-currency';
  final AuthService auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    return Consumer(
      builder: (context,ThemeModel themeNotifier,child){
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            SizedBox(height: 10,),
            _avatar(user.uid),
            SizedBox(height: 32,),
            SettingsGroup(
              title: 'Ogólne',
              children: <Widget>[
                buildAccount(),
                buildDarkMode(themeNotifier),
                buildCurrency(),
              ],
            ),
            const SizedBox(height: 32,),
            SettingsGroup(
              title: 'Konto',
              children: <Widget>[
                buildLogout(),
                buildDeleteAccount(),
              ],
            ),
          ],
        ),
      ),
    );});
  }

  
  Widget buildDarkMode(ThemeModel theme) => SwitchSettingsTile(
    settingKey: keyDarkMode,
    title: theme.isDark ? 'Tryb ciemny' : 'Tryb jasny',
    leading: IconWidget(
      icon: theme.isDark ? Icons.brightness_2 : Icons.brightness_4,
      color: Color(0xFF642ef3),
    ),
    onChange: (state)async{
      setState(() {theme.isDark ? theme.isDark = false :theme.isDark = true;});
  });

  Widget buildLogout() => SimpleSettingsTile(
    title: 'Wyloguj się',
    subtitle: '',
    leading: IconWidget(
      icon: Icons.logout,
      color: Colors.blueAccent,
    ),
    onTap: () async {await auth.signOut();},
  );

  Widget buildAccount() => SimpleSettingsTile(
    title: 'Ustawienia konta',
    subtitle: 'Numer Telefonu, Nazwa użytkownika',
    leading: IconWidget(
      icon: Icons.person,
      color: Colors.green,
    ),
    onTap: ()=>_showSettingsPanel(context),
  );

  Widget buildCurrency() => DropDownSettingsTile(
    settingKey: keyCurrency,
    title: "Waluta",
    selected: 1,
    values: <int,String>{
      1: 'PLN',
      2: 'EUR',
      3: 'USD', 
    }
  );

  Widget buildDeleteAccount() => SimpleSettingsTile(
    title: 'Usuń konto',
    subtitle: '',
    leading: IconWidget(
      icon: Icons.delete,
      color: Colors.pink,
    ),
    onTap: ()=>_removeAccount(context),
  );

  void _showSettingsPanel(BuildContext context){
    showModalBottomSheet(context: context,isScrollControlled: true, builder: (context){
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 60),
        child: SettingsForm(),
      );
    });
  }

  void _removeAccount(BuildContext context){
      showDialog(
      context: context, 
      builder: (BuildContext context){
         return RemoveAccount();
      }
    );
  }

  Widget _avatar(String uid) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext(uid), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting)
        {
          return Container(
            height: 120,
            width: 120,
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData){
          return Container(
            width: 120,
            height: 120,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                snapshot.data.toString(),
              ),
            ),
          );
      } else{
        return Container(
            width: 120,
            height: 120,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
          );
        }
      }),
    ],
  );

}
