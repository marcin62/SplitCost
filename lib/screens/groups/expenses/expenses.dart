import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/expenses/splitEquelly.dart';
import 'package:splitcost/screens/groups/expenses/splitPercent.dart';
import 'package:splitcost/screens/groups/expenses/splitUnEquelly.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';


class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final group = Provider.of<MyGroup>(context);
     return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 20),
        child: Column(
      children: [
        _buildImage(group),
        SizedBox(height: 15,),
        Expanded( child:
        StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().groupsCollection.doc(group.groupid).collection('expenses').snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                 if(snapshot.connectionState == ConnectionState.waiting)
                  {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if(!snapshot.hasData){
                    return ListView(
                      children: [
                        Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50,),
                          Text("W tej grupie nie ma wydatków, możesz dodać wydatek klikając przycisk u dołu ekranu",style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
                          SizedBox(height: 30,),
                          buildImageNoData(),
                        ],
                      ),
                    )
                      ],
                    );
                  }
                  else {
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
                          Text(document['description'],style: TextStyle(fontSize: 20),),
                          Spacer(),
                          Text(document['price'] + " PLN",style: TextStyle(fontSize: 20),),
                          SizedBox(width: 10,),
                          if(document['ownerid']==user.uid)
                          _buildRemoveExpenseButton(document['expenseid'],group.groupid)
                          else 
                          _buildInfoButton(),
                        ],
                      ),
                    );
                  }).toList(),
                );
                  }
              },
            ),
        ),
      ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         _showDialog(group);
        },
        splashColor: Theme.of(context).secondaryHeaderColor,
        child: Icon(Icons.add,color: Theme.of(context).primaryColor,),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

   Widget buildImageNoData()=>Container(
    width: 300,
    height: 300,
    child: CircleAvatar(
      radius: 0,
      backgroundImage: AssetImage('assets/images/nodata.png'),
    ),
  );

 Widget _buildRemoveExpenseButton(String expenseid,String groupid) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.remove,color: Colors.redAccent,),
    onPressed:() async {DatabaseService().deleteExpense(groupid, expenseid);}
  );

  Widget _buildInfoButton() => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.face,color: Colors.greenAccent,),
    onPressed: () => {
      
    },
  );

  void _showDialog(MyGroup group){
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
                      MaterialPageRoute(builder: (context) => SplitEquelly(group: group,),),
                    );
                    },
                    child: Text("Podziel po równo")
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: MyDecoration.mybuttonStyle,
                    onPressed: () async {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SplitPercent(group: group,),),
                    );
                    },
                    child: Text("Podziel procentowo")
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: MyDecoration.mybuttonStyle,
                    onPressed: () async {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SplitUnEquelly(group: group,),),
                    );
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

    Widget _buildImage(MyGroup group) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext("${group.groupid}"), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting)
        {
          return Container(
            height: 90,
            width: 90,
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData&& snapshot.data.toString()!=""){
          return Container(
            width: 90,
            height: 90,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                snapshot.data.toString(),
              ),
            ),
          );
      } else{
        return Container(
            width: 90,
            height: 90,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/logo.jpg'),
            ),
          );
        }
      }),
      SizedBox(width: 10,),
      Text(group.groupName,style: TextStyle(color: Theme.of(context).hintColor,fontSize: 45),)
    ],
  );


}