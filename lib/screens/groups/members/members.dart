import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/members/addNewMember.dart';
import 'package:splitcost/screens/groups/members/paydebt.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';

class Members extends StatefulWidget {

  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {

  @override
 Widget build(BuildContext context) {

    final user = Provider.of<MyUser>(context);
    final group = Provider.of<MyGroup>(context);
     return StatefulBuilder( builder: (context,setState){
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
        child: Column(
          children: [
            _buildImage(group),
            SizedBox(height: 25,),
            Text("Użytkownicy",style: TextStyle(fontSize: 20),),
            SizedBox(height: 15,),
            Expanded(child:  StreamBuilder<QuerySnapshot>(
               stream: DatabaseService().userCollection.where('userId',whereIn:group.members).orderBy('email').snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return StatefulBuilder( builder: (context,setState){
                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                  children: snapshot.data.docs.map<Widget>((document){
                    if(user.uid!=document['userId']){
                        return FutureBuilder(
                        future: DatabaseService().getprice(user.uid, group.groupid, document['userId']), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if(snapshot.hasData){
                          return _buildContainer(snapshot, document, document['userId'],user.uid,group);
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
                ),); });
              },
            ),),
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
    );});
  }

  void _showDialog(MyGroup group){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AddMember(group: group,);
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
        if(snapshot.hasData){
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

  Widget _buildRows(String text) => Container(
     child: Text(text,style: TextStyle(fontSize: 20),),
  );

  Widget _buildRemindButton(String userid,String owner,String groupname,String price,MyGroup group) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.info,color: Colors.red,),
    onPressed:() async {
      String username = await DatabaseService().getUsersKey(owner);
      ErrorDialog(error: 'Właśnie wysłałeś przypomnienie o spłacie długu',context: context).showError();
      DatabaseService().addMessageToUser(userid, "Użytkownik " + username + " prosi o uregulowanie dłużności w grupie " + groupname +" na kwotę " +price +".", Timestamp.fromDate(DateTime.now()),group.groupid);
    }
  );

  Widget _buildPayButton(String userid,String owner,String groupname,String price,MyGroup group) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.money,color: Colors.green,),
    onPressed:() async {_paydebt(owner,userid,price,group);}
  );

  Widget _buildContainer(AsyncSnapshot snapshot,DocumentSnapshot document,String userId,String ownerid,MyGroup group) =>Container(
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
        _avatar(userId),
        SizedBox(width: 10,),
        _buildRows(document['userName']),
        Spacer(),
        _buildRows(snapshot.data+ " PLN"),   
        SizedBox(width: 10,),
        if(double.parse(snapshot.data) > 0)
          _buildRemindButton(userId, ownerid, group.groupName,snapshot.data,group)
        else if(double.parse(snapshot.data) <0)
          _buildPayButton(userId, ownerid, group.groupName,snapshot.data,group)
        else
          Container(
            padding: EdgeInsets.only(right: 3),
            child: Icon(Icons.face,color: Colors.greenAccent,size: 50,)
          )
        ],
    ),
  );

   void _paydebt(String owner, String userid,String price,MyGroup group){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return PayDebt(group: group,owner: owner,userid: userid,price: price,);
      }
    );
  }

    Widget _avatar(String uid) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext(uid), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting)
        {
          return Container(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData){
          return Container(
            width: 40,
            height: 40,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                snapshot.data.toString(),
              ),
            ),
          );
      } else{
        return Container(
            width: 40,
            height: 40,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
          );
        }
      }),
    ],
  );

}

