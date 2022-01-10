import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myDetails.dart';
import 'package:splitcost/models/myExpenses.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/screens/groups/expenses/editexpenses.dart';
import 'package:splitcost/screens/groups/settings/firebaseApi.dart';
import 'package:splitcost/services/database.dart';
import 'package:splitcost/style/colors.dart';
import 'package:splitcost/style/inputdecoration.dart';

class DetailView extends StatefulWidget {
  MyExpenses expense;
  MyGroup group;
  File file;
  DetailView({this.expense,this.group});
  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  List<String> debt;
  List<String> users;
  @override
  Widget build(BuildContext context) {
    //final group = Provider.of<MyGroup>(context);
    //final detail = Provider.of<List<MyDetails>>(context);
    final user = Provider.of<MyUser>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: StreamProvider<List<MyDetails>>.value(
            value: DatabaseService().getDetails(widget.group.groupid, widget.expense.expenseid), 
            initialData: [],
            child: Column(
              children: [
                SizedBox(height: 30,),
                Text(widget.expense.description,style: TextStyle(fontSize: 30),),
                SizedBox(height: 10,),
                Container(
                  height: MediaQuery.of(context).size.height*2/5,
                  // child: StreamProvider<List<MyDetails>>.value(
                  //   value: DatabaseService().getDetails(widget.group.groupid, widget.expense.expenseid), 
                  //   initialData: [],
                    child: DetailView2(group:widget.group,expense:widget.expense),
                    // ),
                ),
                SizedBox(height: 10,),
                if(user.uid==widget.expense.ownerid)
                  _buildbuttons(),

                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width*4.5/5,
                    height: MediaQuery.of(context).size.height*4.5/5,
                    child: _buildImage(widget.expense),
                  ),
                  onTap: ()  async => {
                    if(user.uid==widget.expense.ownerid)
                      await uploadFile(widget.expense.expenseid),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future uploadFile(String destination) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    final path = result.files.single.path;
    setState(() {
    widget.file = File(path);
    });
    await FirebaseApi.uploadFile(destination, widget.file);
  }

  Widget _buildbuttons() => Column(
    children: [
      Container(
                width: MediaQuery.of(context).size.width/5*4,
                child: _buildEditButton(widget.expense),
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width/5*4,
                child: _buildRemoveExpense(widget.expense.expenseid),
              ),
              SizedBox(height: 10,),
    ],
  );

  Widget _buildRemoveExpense(String expenseid) => ElevatedButton(
    style: MyDecoration.remindbuttonStyle,
    child: Row(
      children: [
        SizedBox(width: 30,),
        Text('Usuń wydatek',style: TextStyle(fontSize: 20),),
        Spacer(),
        Icon(Icons.remove,color: Colors.red,),
        SizedBox(width: 30,)
      ],
    ),
     onPressed:() async { await DatabaseService().deleteExpense(widget.group.groupid, expenseid); await FirebaseApi.removeimage(widget.expense.expenseid); Navigator.pop(context); Navigator.pop(context);}
  );

  Widget _buildEditButton(MyExpenses expense) => ElevatedButton(
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
    Navigator.push(
                    context,
       MaterialPageRoute(builder: (contextt) => EditExpenses(expense: expense,group: widget.group,)));
    }
  );


   Widget _buildImage(MyExpenses expense) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      FutureBuilder(
      future:  FirebaseApi.loadImageWithoutContext("${expense.expenseid}"), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState== ConnectionState.waiting)
        {
          return Container(
            width: MediaQuery.of(context).size.width*4.5/5,
            height: MediaQuery.of(context).size.height*3/5,      
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData){
          return Container(
            width: MediaQuery.of(context).size.width*4.5/5,
            height: MediaQuery.of(context).size.height*4.5/5,
            child: Image.network(snapshot.data),
          );
      } else{
        return Container(
            width: MediaQuery.of(context).size.width*4.5/5,
            height: MediaQuery.of(context).size.height*3/5,
            child:Image.asset('assets/images/nodata.png'),  
          );
        }
      }),
    ],
  );

}

class DetailView2 extends StatefulWidget {
  MyGroup group;
  MyExpenses expense;
  DetailView2({this.group,this.expense});
  @override
  _DetailView2State createState() => _DetailView2State();
}

class _DetailView2State extends State<DetailView2> {
  @override
  Widget build(BuildContext context) {
    final detail = Provider.of<List<MyDetails>>(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemCount: detail.length ?? 0,
        itemBuilder: (context,index){
        return DetailTile(detail: detail[index]);
      },
    ));
  }
}

class DetailTile extends StatelessWidget {
  final MyDetails detail;
  DetailTile({this.detail});

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 3 , horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor.withOpacity(0.50),
        border: Border.all(width: 2,color: MyColors.color4.withOpacity(0.60),),
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: FutureBuilder(
        future: DatabaseService().userCollection.doc(detail.who).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
          if(!snapshot.hasData)
            return CircularProgressIndicator();
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              SizedBox(width: 10,),
              Text(snapshot.data['userName'],style: TextStyle(fontSize: 20),),
              Spacer(),
              Text(detail.howmuch + " PLN",style: TextStyle(fontSize: 20),),
              SizedBox(width: 10,),
            ],
          );
        }
      ),
    );
  }
}