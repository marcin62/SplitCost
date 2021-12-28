import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';
import 'package:splitcost/validators/validators.dart';
import 'package:uuid/uuid.dart';

class SplitUnEquelly extends StatefulWidget {

  MyGroup group;
  SplitUnEquelly({this.group});
  
  @override
  _SplitUnEquellyState createState() => _SplitUnEquellyState();
}

class _SplitUnEquellyState extends State<SplitUnEquelly> {
  
  double price = 0;
  String description = "";
  String err;

  @override
  Widget build(BuildContext context) {
    
    List<double> prices = new List<double>.filled(widget.group.members.length, 0);
    final user = Provider.of<MyUser>(context);

    return Scaffold(
      body: StatefulBuilder( builder: (context,setState){
        return Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                Text("Rozdziel koszty nierówno",style: TextStyle(fontSize: 30,),textAlign: TextAlign.center),
                SizedBox(height: 20,),
                _buildDescription(),
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
             Text("Do rozdania: " + (price-prices.fold(0, (a, b) => a+b)).toString()+" PLN",style: TextStyle(fontSize: 17),),
            ],
          ),
        ), 
      );
    }
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () async {
          err = isNumeric(price.toString());
          if(description.length == 0){
            ErrorDialog(error: "Nie podałeś opisu",context: context).showError();
          }else if(err!=null){
            ErrorDialog(error: err,context: context).showError();
          }else if(price-prices.fold(0, (a, b) => a+b)!=0){
            ErrorDialog(error: "Muisz rozdać wszystkie koszty kosztów",context: context).showError();
          }else{
            await addUnEquellyExpense(price.toString(), prices, widget.group.members, user.uid, widget.group.groupid, description, Uuid().v4());
            await DatabaseService().addMessageToUser(user.uid, "Właśnie dodałeś wydatek w grupie " +widget.group.groupName + " na kwote " + price.toString(),Timestamp.fromDate(DateTime.now()));
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
        splashColor: Theme.of(context).secondaryHeaderColor,
        child: Icon(Icons.check,color: Theme.of(context).primaryColor,),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  Widget _buildDescription() => TextFormField(
    decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Krótki opis',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.description,color: Theme.of(context).cardColor, size: 25.0)),
        ),
    onChanged: (val) {
      setState(() => description = val);
    },
  );

  Widget _buildPrice() => TextFormField(
    decoration: MyDecoration.textInputDecoration.copyWith(hintText: 'Koszt',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
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
    double pricedouble = double.parse(price);
    for(int i=0;i<users.length;i++)
    {
      if(percent[i]!=0 && users[i]!=ownerid){
        double howmany = percent[i];
        await DatabaseService().addDetailsOfExpenses(ownerid, Uuid().v4(), howmany.toStringAsFixed(2), users[i], groupid, expenseid);
        await DatabaseService().addMessageToUser(users[i], "Dodano nowy koszt w grupie "+ widget.group.groupName+ " do którego przynależysz. Na kwotę "+ howmany.toString(),Timestamp.fromDate(DateTime.now()));
      }
    }

  }

}