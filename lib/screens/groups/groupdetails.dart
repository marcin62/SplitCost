import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/expenses/expenses.dart';
import 'package:splitcost/screens/groups/members/members.dart';
import 'package:splitcost/screens/groups/settings/settings.dart';
import 'package:splitcost/screens/groups/statistic/statistic.dart';
import 'package:splitcost/services/database.dart';

class GroupDetail extends StatefulWidget {
  MyGroup group;
  GroupDetail({this.group});
  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _selectScreen(BuildContext context){ 
    if(_selectedIndex == 0) return Expenses(); 
    if(_selectedIndex == 1) return Members();
    if(_selectedIndex == 2) return Statistic();
    else return SettingsView();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamProvider<MyGroup>.value(
        value: DatabaseService().getGroup(widget.group.groupid), 
        initialData: widget.group,  
        child: Container(
          padding: EdgeInsets.only(top: 50),
          height: double.infinity,
          width: double.infinity,
          child: _selectScreen(context),
        ),
      ),
       bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.money,),
            label: 'Wydatki',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,),
            label: 'Osoby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Statystyki',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ustawienia',
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