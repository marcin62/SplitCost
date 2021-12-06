import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/addNewMember.dart';
import 'package:splitcost/screens/groups/group.dart';
import 'package:splitcost/screens/groups/paydebt.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';

class Members extends StatefulWidget {

  MyGroup group;
  Members({this.group});

  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {

  @override
 Widget build(BuildContext context) {

    final user = Provider.of<MyUser>(context);

     return StatefulBuilder( builder: (context,setState){
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 20),
        child: Column(
          children: [
            _buildImageWithName(widget.group.groupName),
            SizedBox(height: 15,),
            Expanded(child:  StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().userCollection.snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return StatefulBuilder( builder: (context,setState){
                return ListView(
                  children: snapshot.data.docs.map<Widget>((document){
                    if(widget.group.members.contains(document['userId'])&&user.uid!=document['userId']){
                        return FutureBuilder(
                        future: DatabaseService().getprice(user.uid, widget.group.groupid, document['userId']), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if(snapshot.hasData){
                          return _buildContainer(snapshot, document, document['userId'],user.uid);
                          }
                          else{
                            return Center(
                              child: CircularProgressIndicator(),
                            ); 
                          }
                        });
                    }
                    else
                    return SizedBox(height: 0,);
                  }).toList(),
                ); });
              },
            ),),
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
    );});
  }

  void _showDialog(){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AddMember(group: widget.group);
      }
    );
  }

  Widget _buildImageWithName(String groupName) =>Row(
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
      Text(groupName,style: TextStyle(color: Theme.of(context).hintColor,fontSize: 45),)
    ],
  );

  Widget _buildRows(String text) => Container(
     child: Text(text,style: TextStyle(color: MyColors.white,fontSize: 20),),
  );

  Widget _buildRemindButton(String userid,String owner,String groupname,String price) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.info,color: Colors.red,),
    onPressed:() async {
      String username = await DatabaseService().getUsersKey(owner);
      DatabaseService().addMessageToUser(userid, "Użytkownik " + username + " prosi o uregulowanie dłużności w grupie " + groupname +" na kwotę " +price +".", Timestamp.fromDate(DateTime.now()));
    }
  );

  Widget _buildPayButton(String userid,String owner,String groupname,String price) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.money,color: Colors.green,),
    onPressed:() async {_paydebt(owner,userid,price);}
  );

  Widget _buildContainer(AsyncSnapshot snapshot,DocumentSnapshot document,String userId,String ownerid) =>Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.symmetric(vertical: 3 , horizontal: 10),
    decoration: BoxDecoration(
      color:Theme.of(context).hoverColor.withOpacity(0.50),
      border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
      borderRadius: BorderRadius.all(Radius.circular(22)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox( width: 10,),
        _buildRows(document['userName']),
        Spacer(),
        _buildRows(snapshot.data+ " PLN"),   
        Spacer(),
        if(double.parse(snapshot.data) > 0)
          _buildRemindButton(userId, ownerid, widget.group.groupName,snapshot.data)
        else if(double.parse(snapshot.data) <0)
          _buildPayButton(userId, ownerid, widget.group.groupName,snapshot.data)
        else
          Icon(Icons.face,color: Colors.greenAccent,)
        ],
    ),
  );

   void _paydebt(String owner, String userid,String price){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return PayDebt(group: widget.group,owner: owner,userid: userid,price: price,);
      }
    );
  }

}

