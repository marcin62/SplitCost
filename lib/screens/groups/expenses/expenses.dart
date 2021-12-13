import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/screens/groups/expenses/splitEquelly.dart';
import 'package:splitcost/screens/groups/expenses/splitPercent.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:splitcost/validators/validators.dart';
import 'package:uuid/uuid.dart';


class Expenses extends StatefulWidget {
  MyGroup group;
  Expenses({this.group});
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 20),
        child: Column(
      children: [
        Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.fill,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white)),
                  ),
                SizedBox(width: 20,),
                Text(widget.group.groupName,style: TextStyle(color: Theme.of(context).hintColor,fontSize: 45),)
              ],
        ),
        SizedBox(height: 15,),
        Expanded( child:
        StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().groupsCollection.doc(widget.group.groupid).collection('expenses').snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  children: snapshot.data.docs.map<Widget>((document){
                    return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 3 , horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor.withOpacity(0.50),
                        border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(document['description'],style: TextStyle(color: MyColors.white,fontSize: 20),),
                          Spacer(),
                          Text(document['price'] + " PLN",style: TextStyle(color: MyColors.white,fontSize: 20),),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ),
      ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         _showDialog();
        },
        splashColor: Theme.of(context).secondaryHeaderColor,
        child: Icon(Icons.add,color: Theme.of(context).primaryColor,),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }


  void _showDialog(){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return StatefulBuilder( builder: (context,setState){
         return Container(
           width: double.maxFinite,
           child: AlertDialog(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text("Wybierz rodzaj podziału kosztu"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                     style: MyDecoration.mybuttonStyle,
                    onPressed: () async {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SplitEquelly(group: widget.group,),),
                    );
                    },
                    child: Text("Podziel porówno")
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: MyDecoration.mybuttonStyle,
                    onPressed: () async {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SplitPercent(group: widget.group,),),
                    );
                    },
                    child: Text("Podziel procentowo")
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: MyDecoration.mybuttonStyle,
                    onPressed: () async {
                    //   Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SplitPercent(group: widget.group,),),
                    // );
                    },
                    child: Text("Podziel cenowo")
                  ),
                ],
              ), 
              actions: <Widget>[
                TextButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
                ),
              ],
              ),
         );
        }
        );
      }
    );
  }

}