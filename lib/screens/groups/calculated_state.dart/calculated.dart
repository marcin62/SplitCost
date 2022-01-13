import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myExpenses.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';
import 'package:splitcost/validators/errordialog.dart';

class Calculate extends StatefulWidget {

  @override
  _CalculateState createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {
  @override
  Widget build(BuildContext context) {
    final group = Provider.of<MyGroup>(context);
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: MultiProvider(
        providers: [
        StreamProvider<List<MyExpenses>>.value(value: DatabaseService().getexpenses(group.groupid), initialData: []),
        StreamProvider<List<UserData>>.value(value: DatabaseService().getUsers(), initialData: []),
      ],
      child: Column(
        children: [
          Container(
          height: MediaQuery.of(context).size.height/15*1,
          child: Text("Tryb rozliczeń został wlączony",style: TextStyle(fontSize: 25),)),
          Container(
            height: MediaQuery.of(context).size.height/15*10,
            child: UsersList()),
          SizedBox(height: 5,),
         _buildChangeStateButton(group),
        ],
      ),
    )
    );
  }
    Widget _buildChangeStateButton(MyGroup group) => ElevatedButton(
     style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Wyłącz tryb rozliczeniowy',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.photo_album,color: Colors.greenAccent,),
        SizedBox(width: 30,)
      ],
    ),
    onPressed:() async {
      int iscorrect=1;
      for(int i=0;i<group.prices.length;i++)
      {
        if(double.parse(group.prices[i]) != 0)
        {
          iscorrect=0;
          ErrorDialog(error: "Grupa się nie rozliczyła, nie można wyłączyć",context: context).showError();
          break;
        }
      }
      if(iscorrect==1){
        await DatabaseService().deleteallexpenses(group.groupid);
        await DatabaseService().updateGrouCalculated(group.groupid, !group.iscalculated);
      }
    }
  );
}

class UsersList extends StatefulWidget {

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  double myprice;
  @override
  Widget build(BuildContext context) {
     final currentuser = Provider.of<MyUser>(context);
     final group = Provider.of<MyGroup>(context);
     final user = Provider.of<List<UserData>>(context);
  
     return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child:ListView.builder(
      itemCount: group.members.length,
      itemBuilder:(BuildContext context, int index){
        String username = "Awaiting";
        for(int i=0;i<user.length;i++)
        {
          if(group.members[index]==user.elementAt(i).uid)
          {
            username = user.elementAt(i).name;
          }
          if(group.members[index]==currentuser.uid)
          {
            myprice = double.parse(group.prices[index]);
          }
        }
        return _buildContainer(username, group.members[index],group.prices[index],group,currentuser);
      }
    )); 
  }

  Widget _buildContainer(String username,String userId,String price,MyGroup group,MyUser currentuser) =>Container(
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
        _buildRows(username),
        Spacer(),
        _buildRows(price+ " PLN"),   
        SizedBox(width: 10,),
        if(double.parse(price) > 0 && currentuser.uid!= userId&& myprice!=0)
           _buildPayButton(userId,group,price, currentuser.uid)
        else
          Container(
            padding: EdgeInsets.only(right: 3), 
            child: Icon(Icons.face,color: Colors.greenAccent,size: 50,)
          )
        ],
    ),
  );

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

  Widget _buildPayButton(String userid,MyGroup group, String price,String currentuser) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Icon(Icons.money,color: Colors.green,),
   onPressed:() async {
      double thisprice = double.parse(price);
      myprice = -myprice;
      if(thisprice >= myprice)
      {
        thisprice -= myprice;
        myprice = 0;
      }
      if(thisprice < myprice)
      {
        myprice -= thisprice;
        thisprice = 0;
      }
      if(thisprice == myprice)
      {
        myprice=0;
        thisprice = 0;
      }
      for(int i=0;i<group.prices.length;i++)
      {
        if(group.members[i]==userid)
        {
          group.prices[i] = thisprice.toString();
        }else if(group.members[i]==currentuser)
        {
          group.prices[i] = myprice.toString();
        }
      }
      DatabaseService().updategroupprices(group.groupid,group.prices);
     }
  );

   Widget _buildRows(String text) => Container(
     child: Text(text,style: TextStyle(fontSize: 20),),
  );
}