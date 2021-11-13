import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/expenses.dart';
import 'package:splitcost/screens/groups/members.dart';
import 'package:splitcost/screens/groups/settings.dart';
import 'package:splitcost/style/colors.dart';

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
    if(_selectedIndex == 0) return Expenses(group: widget.group); 
    if(_selectedIndex == 1) return Members(group: widget.group);
    else return SettingsView();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: MyColors.color2,
        elevation: 0.0,
      ),
      body: Container(
        color: MyColors.color1,
        height: double.infinity,
        width: double.infinity,
        child: _selectScreen(context),
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
            icon: Icon(Icons.settings),
            label: 'Ustawienia',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.color4,
        unselectedItemColor: MyColors.white,
        onTap: _onItemTapped,
       ),
    );
  }
}