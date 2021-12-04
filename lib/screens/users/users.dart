import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/screens/users/accountSettings.dart';
import 'package:splitcost/screens/users/iconWidget.dart';
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
    return Consumer(
      builder: (context,ThemeModel themeNotifier,child){
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
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
  );

  void _showSettingsPanel(BuildContext context){
    showModalBottomSheet(context: context,isScrollControlled: true, builder: (context){
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 60),
        child: SettingsForm(),
      );
    });
  }
}
