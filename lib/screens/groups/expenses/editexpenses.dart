import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myDetails.dart';
import 'package:splitcost/models/myExpenses.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:splitcost/validators/validators.dart';
import 'package:uuid/uuid.dart';

class EditExpenses extends StatefulWidget {
  MyGroup group;
  MyExpenses expense;
  EditExpenses({this.group,this.expense});
  @override
  _EditExpensesState createState() => _EditExpensesState();
}

class _EditExpensesState extends State<EditExpenses> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StatefulBuilder( builder: (context,setState){
        return StreamProvider<List<MyDetails>>.value(
        value: DatabaseService().getDetails(widget.group.groupid, widget.expense.expenseid), 
        initialData: [],
        child: Edit(expense: widget.expense,group: widget.group,),
      );
    }
    ),
    // floatingActionButton: FloatingActionButton(
    //     onPressed: () async {
    //       err = isNumeric(price.toString());
    //       if(description.length == 0){
    //         ErrorDialog(error: "Nie podałeś opisu",context: context).showError();
    //       }else if(err!=null){
    //         ErrorDialog(error: err,context: context).showError();
    //       }else if(price-prices.fold(0, (a, b) => a+b)!=0){
    //         ErrorDialog(error: "Muisz rozdać wszystkie koszty kosztów",context: context).showError();
    //       }else{
    //         await addUnEquellyExpense(price.toString(), prices, widget.group.members, user.uid, widget.group.groupid, description, Uuid().v4());
    //         await DatabaseService().addMessageToUser(user.uid, "Właśnie dodałeś wydatek w grupie " +widget.group.groupName + " na kwote " + price.toString(),Timestamp.fromDate(DateTime.now()),widget.group.groupid);
    //         Navigator.pop(context);
    //         Navigator.pop(context);
    //       }
    //     },
    //     splashColor: Theme.of(context).secondaryHeaderColor,
    //     child: Icon(Icons.check,color: Theme.of(context).primaryColor,),
    //     backgroundColor: Theme.of(context).cardColor,
    //   ),
    );
}
}

class Edit extends StatefulWidget {
   MyGroup group;
  MyExpenses expense;
  Edit({this.group,this.expense});

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  double price = 0;
  String description = "";
  double priceee= 0;
  String err;
  @override
  Widget build(BuildContext context) {
    List<double> prices = new List<double>.filled(widget.group.members.length, 0);
    final user = Provider.of<MyUser>(context);
    final detail = Provider.of<List<MyDetails>>(context);
    for(int i=0;i<detail.length;i++){
      priceee += double.parse(detail.elementAt(i).howmuch);
    }
    // return Scaffold(
      return StatefulBuilder(builder: (context,setState){
        return Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    Text("Edytuj koszty",style: TextStyle(fontSize: 30,),textAlign: TextAlign.center),
                    SizedBox(height: 20,),
                    _buildPrice(),
                    SizedBox(height: 20,),
                    Container(
                      width: 300,
                      height: 450,
                      child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.group.members.length,
                      itemBuilder: (context, index){
                        return FutureBuilder(
                          future: DatabaseService().getUsersKey(widget.group.members[index]?? null), // a previously-obtained Future<String> or null
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            String price33="0 PLN";
                            for(int i=0;i<detail.length;i++)
                            {
                              if(detail.elementAt(i).who==widget.group.members[index])
                              {
                                price33 = detail.elementAt(i).howmuch;
                                //prices[index]= double.parse(detail.elementAt(i).howmuch);
                              }
                            }
                          if(snapshot.hasData){
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text(snapshot.data,style: TextStyle(fontSize: 20),),
                                    Spacer(),
                                     Container( 
                                        width: 125,
                                      child: TextFormField(
                                        decoration: MyDecoration.textInputDecoration.copyWith(hintText: price33,hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Icon(Icons.money,color: Theme.of(context).cardColor, size: 25.0)),
                                            ),
                                        onChanged: (val) {
                                          if(isNumeric(val)==null)
                                          setState(() => prices[index] = double.parse(val));
                                        },
                                      ),),
                                   // ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                              ],
                            );
                          }
                          else{
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text("Await data",style: TextStyle(fontSize: 20),),
                                    Spacer(),
                                    Expanded(
                                      child: Container( 
                                        width: 200,
                                      child: TextFormField(
                                        decoration: MyDecoration.textInputDecoration.copyWith(hintText: '0 PLN',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Icon(Icons.money,color: Theme.of(context).cardColor, size: 25.0)),
                                            ),
                                        onChanged: (val) {
                                          if(isNumeric(val)==null)
                                          setState(() => prices[index] = double.parse(val));
                                        },
                                      ),),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                              ],
                            );
                          }
                          }
                        );
                      }
                    ),              
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: MediaQuery.of(context).size.width/5*4,
                    child: _buildEditButton(widget.expense,prices,user.uid),
                  ),
                  SizedBox(height: 10,),
                 Text("Do rozdania: " + (price-prices.fold(0, (a, b) => a+b)).toString()+" PLN",style: TextStyle(fontSize: 17),),
                ],
              ),
            ), 
            );
      }
    );
  }

  Widget _buildEditButton(MyExpenses expense,List<double> prices,String uid) => ElevatedButton(
     style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Edytuj wydatek',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.info,color: Colors.greenAccent,),
        SizedBox(width: 30,)
      ],
    ),
    onPressed:() async {
      if(price-prices.fold(0, (a, b) => a+b)!=0){
            ErrorDialog(error: "Muisz rozdać wszystkie koszty kosztów",context: context).showError();
          }else{
            await DatabaseService().deleteDetails(widget.group.groupid,widget.expense.expenseid);
            await addUnEquellyExpense(price.toString(), prices, widget.group.members, widget.expense.ownerid, widget.group.groupid, widget.expense.description, widget.expense.expenseid);
            await DatabaseService().addMessageToUser(uid, "Właśnie edytowałeś wydatek w grupie " +widget.group.groupName + " na kwote " + price.toString(),Timestamp.fromDate(DateTime.now()),widget.group.groupid);
            Navigator.pop(context);

          }
    
    }
  );

   Widget _buildPrice() => TextFormField(
    decoration: MyDecoration.textInputDecoration.copyWith(hintText: priceee.toString() ,hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.money,color: Theme.of(context).cardColor, size: 25.0)),
        ),
    onChanged: (val) {
      setState(() => price = double.parse(val));
    },
  );

    Future addUnEquellyExpense(String price, List<double> percent ,List<dynamic> users, String ownerid,String groupid,String description,String expenseid) async {
    await DatabaseService().addExpenses(groupid, price, ownerid, expenseid, description);
    //double pricedouble = double.parse(price);
    for(int i=0;i<users.length;i++)
    {
      if(percent[i]!=0 && users[i]!=ownerid){
        double howmany = percent[i];
        await DatabaseService().addDetailsOfExpenses(ownerid, Uuid().v4(), howmany.toStringAsFixed(2), users[i], groupid, expenseid);
        await DatabaseService().addMessageToUser(users[i], "Edytowano koszt w grupie "+ widget.group.groupName+ " do którego przynależysz. Na kwotę "+ howmany.toString(),Timestamp.fromDate(DateTime.now()),widget.group.groupid);
      }
    }

  }

}