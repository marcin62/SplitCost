import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myExpenses.dart';
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
  String userr = "Wszystko";
  DateTimeRange dataRange;
  DateTimeRange dataRangeifnotcheck = DateTimeRange(
      start: DateTime(DateTime.now().year-5), end: DateTime(DateTime.now().year + 5));
  //String userr = "ybWLUmHKkuauHBbNrORAmchOGFM2";
  @override
  Widget build(BuildContext context) {
    final group = Provider.of<MyGroup>(context);
     return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
        child: Column(
      children: [
        // _buildImage(group),
        // SizedBox(height: 15,),
        _dropDownCategory(group),
        SizedBox(height: 20,),
        Center(child:_picdate()),
        SizedBox(height: 20,),
        Text("Wydatki",style: TextStyle(fontSize: 20),),
        SizedBox(height: 15,),
        StreamProvider<List<MyExpenses>>.value(
          value: DatabaseService().getexpensesgroup(userr,group.groupid, dataRange==null ? dataRangeifnotcheck : dataRange), 
          initialData: [],
          child:Expanded(child: ExpenseList(),),
          )
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
  //DATA TIME

  String getFrom() {
    if (dataRange == null) {
      return '${dataRangeifnotcheck.start.day}/${dataRangeifnotcheck.start.month}/${dataRangeifnotcheck.start.year}';
    } else {
      return '${dataRange.start.day}/${dataRange.start.month}/${dataRange.start.year}';
    }
  }

  String getUntil() {
    if (dataRange == null) {
      return '${dataRangeifnotcheck.end.day}/${dataRangeifnotcheck.end.month}/${dataRangeifnotcheck.end.year}';
    } else {
      return '${dataRange.end.day}/${dataRange.end.month}/${dataRange.end.year}';
    }
  }

  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 24 * 3)));
    final newDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: dataRange ?? initialDateRange);
    if (newDateRange == null) return;
    setState(() {
      dataRange = newDateRange;
    });
  }

  Widget _picdate() => Container(
    width: MediaQuery.of(context).size.width/4*5,
    height: 40,
    alignment: Alignment.center,
    child: Row(
      children: [
        SizedBox(width: 25,),
        ElevatedButton(style: MyDecoration.remindbuttonStyle.copyWith(minimumSize:MaterialStateProperty.all<Size>(Size(150,50))),onPressed: () => pickDateRange(context), child: Text(getFrom())),
        Spacer(),
        ElevatedButton(style: MyDecoration.remindbuttonStyle.copyWith(minimumSize:MaterialStateProperty.all<Size>(Size(150,50))),onPressed:  () => pickDateRange(context), child: Text(getUntil())),
        SizedBox(width: 25,),
      ],
    ),
  );
 // DATA TIME END
   Widget _dropDownCategory(MyGroup group){
        return StreamBuilder<QuerySnapshot>(
        stream:  DatabaseService().userCollection.where('userId',whereIn: group.members).orderBy('userName').snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) return const Center(
            child: const CupertinoActivityIndicator(),
          );
          return new Container(
            child: Column(
              children: [
                new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          padding: EdgeInsets.all(5),
                          child: new Text("Filtruj osobe",style: TextStyle(fontSize: 17),),
                        )
                    ),
                    new Expanded(
                      child:new InputDecorator(
                        decoration: const InputDecoration(
                          hintText: 'Wybierz osobe',
                          hintStyle: TextStyle(
                            fontSize: 15.0,
                            fontFamily: "OpenSans",
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        isEmpty: userr == null,
                        child: new DropdownButton(
                          value: userr == "Wszystko" ? null: userr,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              userr = newValue;
                            });
                          },
                          items: snapshot.data.docs.map((DocumentSnapshot document) {
                            return new DropdownMenuItem<String>(
                                value: document['userId'],
                                child: new Container(
                                  height: 30.0,
                                  padding: EdgeInsets.all(5),
                                  child: Container(width:70,height: 70,child:new Text(document['userName'])),
                                )
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      );
    }

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

class ExpenseList extends StatefulWidget{
  @override 
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList>{
  @override 
  Widget build(BuildContext context){

    final expense = Provider.of<List<MyExpenses>>(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemCount: expense.length ?? 0,
        itemBuilder: (context,index){
          return ExpenseTile(expense: expense[index]);
        },
      ),
    );

  }
}

class ExpenseTile extends StatelessWidget {
  final MyExpenses expense;
  ExpenseTile({this.expense});

  @override
  Widget build(BuildContext context){
    final user = Provider.of<MyUser>(context);
    final group = Provider.of<MyGroup>(context);
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
          Text(expense.description,style: TextStyle(fontSize: 20),),
          Spacer(),
          Text(expense.price + " PLN",style: TextStyle(fontSize: 20),),
          SizedBox(width: 10,),
          if(expense.ownerid==user.uid)
            _buildRemoveExpenseButton(expense.expenseid,group.groupid)
          else 
            _buildInfoButton(),
        ],
      ),
    );
  }

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
  
}