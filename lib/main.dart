import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splitcost/services/auth.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init(cacheProvider: SharePreferenceCache());
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer(
        builder: (context,ThemeModel themeNotifier,child){
    return StreamProvider<MyUser>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        theme: themeNotifier.isDark ? _dark : _light,
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );}
    ));
  }

  ThemeData _dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: MyColors.color1,
    secondaryHeaderColor: MyColors.color4,
    hintColor: MyColors.white,
    cardColor: MyColors.color4,
    accentColor: MyColors.color2,
    backgroundColor: MyColors.color3,
    dividerColor: MyColors.color4,
    hoverColor: MyColors.color5,
  );

  ThemeData _light = ThemeData(
    brightness: Brightness.light,
    primaryColor: MyColors.color4,
    secondaryHeaderColor: MyColors.color1,
    hintColor: Colors.black,
    cardColor: MyColors.color2,
    accentColor: MyColors.color5,
    backgroundColor: MyColors.color5,
    dividerColor: Colors.pink ,
    hoverColor: MyColors.color2,
  );
}