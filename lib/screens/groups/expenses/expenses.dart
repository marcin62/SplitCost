import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:splitcost/validators/validators.dart';
import 'package:uuid/uuid.dart';

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // final User user = auth.currentUser;
  // final uid = user.uid;

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
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 40),
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
    List<bool> bools = new List<bool>.filled(widget.group.members.length, false);
    bool check = true;
    String price = "";
    String description = "";
    String err;
    showDialog(
      context: context, 
      builder: (BuildContext context){
      return SingleChildScrollView(
        child: StatefulBuilder( builder: (context,setState){
         return Container(
           width: double.maxFinite,
           child: AlertDialog(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text("Podaj Poniesiony Koszt"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                         decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Krótki opis',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).accentColor,
                                  suffixIcon: Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.description,
                                          color: Theme.of(context).cardColor, size: 25.0)),
                                ),
                        onChanged: (val) {
                          setState(() => description = val);
                        },
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                         decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Koszt',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).accentColor,
                                  suffixIcon: Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.money,
                                          color: Theme.of(context).cardColor, size: 25.0)),
                                ),
                        onChanged: (val) {
                          setState(() => price = val);
                        },
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: 300,
                    height: 200,
                    child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.group.members.length,
                    itemBuilder: (context, index){
                      return FutureBuilder(
                        future: getUsersKey(widget.group.members[index]?? null), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if(snapshot.hasData){
                          return CheckboxListTile(
                            title: Text(snapshot.data),
                            secondary: Icon(Icons.money),
                            controlAffinity: ListTileControlAffinity.platform,
                            value: bools[index],
                            onChanged: (bool value){
                              setState(() {
                                bools[index] = value;
                              });
                          },
                          activeColor: Theme.of(context).primaryColor,
                          checkColor: Theme.of(context).secondaryHeaderColor,
                      );}
                        else{
                          return CheckboxListTile(
                          title: Text("Awaiting data"),
                          secondary: Icon(Icons.money),
                          controlAffinity: ListTileControlAffinity.platform,
                          value: bools[index],
                          onChanged: (bool value){
                            setState(() {
                              bools[index] = value;
                                                      });
                          },
                        );}
                        }
                      );
                    }
                  ),              
                  ),
                ],
              ), 
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                   err = isNumeric(price);
                   if(description.length == 0){
                    ErrorDialog(error: "Nie podałeś opisu",context: context).showError();
                   }else if(err!=null){
                    ErrorDialog(error: err,context: context).showError();
                   }else if(!bools.contains(true)){
                    ErrorDialog(error: "Musisz zaznaczyć użytkowników na których chcesz podzielić koszty",context: context).showError();
                   }
                   else{
                     await addexpense(price, bools, widget.group.members, FirebaseAuth.instance.currentUser.uid, widget.group.groupid, description, Uuid().v4());
                     await DatabaseService().addMessageToUser(FirebaseAuth.instance.currentUser.uid, "Właśnie dodałeś wydatek w grupie " +widget.group.groupName + " na kwote " + price,Timestamp.fromDate(DateTime.now()));
                     Navigator.pop(context);
                   }
                   },
                  child: Text("Dodaj koszt",style: TextStyle(color: Theme.of(context).hintColor),),
                ),
                TextButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text("Anuluj",style: TextStyle(color: Theme.of(context).hintColor),),
                ),
              ],
              ),
         );
        }
        ),);
      }
    );
  }

 Future<String> getUsersKey(String uid) async {
  DocumentSnapshot snapshot = await DatabaseService().userCollection.doc(uid).get();
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  return data['userName']; //you can get any field value you want by writing the exact fieldName in the data[fieldName]
  }

Future addexpense(String price, List<bool> bools ,List<dynamic> users, String ownerid,String groupid,String description,String expenseid) async {
  int divide = 0;
  for (int i=0;i<bools.length;i++){
    if(bools[i]==true)
      divide++;
  }
  await DatabaseService().addExpenses(groupid, price, ownerid, expenseid, description);
  double priceperperson = double.parse(price)/divide;

  for(int i=0;i<users.length;i++)
  {
    if(bools[i]==true && users[i]!=ownerid){
       await DatabaseService().addDetailsOfExpenses(ownerid, Uuid().v4(), priceperperson.toString(), users[i], groupid, expenseid);
       await DatabaseService().addMessageToUser(users[i], "Dodano nowy koszt w grupie "+ widget.group.groupName+ " do którego przynależysz. Na kwotę "+ priceperperson.toString(),Timestamp.fromDate(DateTime.now()));
    }
  }

}

}