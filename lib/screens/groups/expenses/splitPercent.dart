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

class SplitPercent extends StatefulWidget {

  MyGroup group;
  SplitPercent({this.group});
  
  @override
  _SplitPercentState createState() => _SplitPercentState();
}

class _SplitPercentState extends State<SplitPercent> {
  
  String price = "";
  String description = "";
  String err;

  @override
  Widget build(BuildContext context) {
    
    List<int> percents = new List<int>.filled(widget.group.members.length, 0);
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
                Text("Rozdziel koszty procentowo",style: TextStyle(fontSize: 30,),textAlign: TextAlign.center),
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
                                    width: 115,
                                  child: TextFormField(
                                    decoration: MyDecoration.textInputDecoration.copyWith(hintText: '0%',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Icons.calculate_outlined,color: Theme.of(context).cardColor, size: 25.0)),
                                        ),
                                    onChanged: (val) {
                                      if(isNumeric(val)==null)
                                      setState(() => percents[index] = int.parse(val));
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
                                    decoration: MyDecoration.textInputDecoration.copyWith(hintText: '0%',hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),fillColor: Theme.of(context).buttonColor,
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Icons.calculate_outlined,color: Theme.of(context).cardColor, size: 25.0)),
                                        ),
                                    onChanged: (val) {
                                      if(isNumeric(val)==null)
                                      setState(() => percents[index] = int.parse(val));
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
             Text("Do rozdania: " + (100-percents.fold(0, (a, b) => a+b)).toString()+"%",style: TextStyle(fontSize: 17),),
            ],
          ),
        ), 
      );
    }
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () async {
          err = isNumeric(price);
          if(description.length == 0){
            ErrorDialog(error: "Nie podałeś opisu",context: context).showError();
          }else if(err!=null){
            ErrorDialog(error: err,context: context).showError();
          }else if(100-percents.fold(0, (a, b) => a+b)!=0){
            ErrorDialog(error: "Muisz rozdać 100% kosztów",context: context).showError();
          }else{
            await addPercentExpense(price, percents, widget.group.members, user.uid, widget.group.groupid, description, Uuid().v4());
            await DatabaseService().addMessageToUser(user.uid, "Właśnie dodałeś wydatek w grupie " +widget.group.groupName + " na kwote " + price,Timestamp.fromDate(DateTime.now()),widget.group.groupid);
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
      setState(() => price = val);
    },
  );

  Future addPercentExpense(String price, List<int> percent ,List<dynamic> users, String ownerid,String groupid,String description,String expenseid) async {
    await DatabaseService().addExpenses(groupid, price, ownerid, expenseid, description);
    double pricedouble = double.parse(price);
    for(int i=0;i<users.length;i++)
    {
      if(percent[i]!=0 && users[i]!=ownerid){
        double howmany = percent[i]/100*pricedouble;
        await DatabaseService().addDetailsOfExpenses(ownerid, Uuid().v4(), howmany.toStringAsFixed(2), users[i], groupid, expenseid);
        await DatabaseService().addMessageToUser(users[i], "Dodano nowy koszt w grupie "+ widget.group.groupName+ " do którego przynależysz. Na kwotę "+ howmany.toString(),Timestamp.fromDate(DateTime.now()),widget.group.groupid);
      }
    }

  }

}