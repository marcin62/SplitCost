import 'package:flutter/material.dart';
import 'package:splitcost/screens/groups/groupsview.dart';
import 'package:splitcost/screens/notifications/notifications.dart';
import 'package:splitcost/screens/users/users.dart';


class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _selectScreen(BuildContext context){
    if(_selectedIndex == 0) return GroupsView(); 
    if(_selectedIndex == 1) return Notifications();
    return Users();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
      title: Text('SplitCost'),
      elevation: 0.0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: _selectScreen(context),
        ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,),
            label: 'Grupy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message,),
            label: 'Wiadomości',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,),
            label: 'Konto',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).secondaryHeaderColor,//MyColors.color4,
        unselectedItemColor: Theme.of(context).hintColor,
        onTap: _onItemTapped,
    ),
    );
  }
}