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
       backgroundColor: MyColors.color1,
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
                Text(widget.group.groupName,style: TextStyle(color: MyColors.white,fontSize: 45),)
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
                        color: MyColors.color5.withOpacity(0.50),
                        border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Column(
                        children: [
                          Text(document['description']),
                          Text(document['expenseid']),
                          Text(document['price'] + "PLN"),
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
        splashColor: MyColors.color4,
        child: Icon(Icons.add,color: MyColors.color1,),
        backgroundColor: MyColors.color5,
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
        return StatefulBuilder( builder: (context,setState){
         return Container(
           width: double.maxFinite,
           child: AlertDialog(
              backgroundColor: MyColors.color4,
              title: Text("Podaj Poniesiony Koszt"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                         decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Krótki opis',
                                  suffixIcon: Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.description,
                                          color: MyColors.color2, size: 25.0)),
                                ),
                        onChanged: (val) {
                          setState(() => description = val);
                        },
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                         decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Koszt',
                                  suffixIcon: Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.money,
                                          color: MyColors.color2, size: 25.0)),
                                ),
                        onChanged: (val) {
                          setState(() => price = val);
                        },
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: 300,
                    height: 300,
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
                          activeColor: MyColors.color1,
                          checkColor: MyColors.color4,
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
                   if( err != null || description.length == 0){
                    ErrorDialog(error: "Nie możesz zostawić pustych pól",context: context).showError();
                   }else{
                     await DatabaseService().addExpenses(widget.group.groupid, price, widget.group.ownerid, Uuid().v4(),description);
                     Navigator.pop(context);
                   }
                   },
                  child: Text("Dodaj koszt",style: TextStyle(color: Colors.black),),
                ),
                TextButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text("Anuluj",style: TextStyle(color: Colors.black),),
                ),
              ],
              ),
         );
        }
        );
      }
    );
  }

 Future<String> getUsersKey(String uid) async {
  DocumentSnapshot snapshot = await DatabaseService().userCollection.doc(uid).get();
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  return data['userName']; //you can get any field value you want by writing the exact fieldName in the data[fieldName]
  }

}