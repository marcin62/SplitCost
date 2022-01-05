import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myMessage.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  
  String group = "Wszystko";
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    return StreamProvider<List<MyMessage>>.value(
      value: DatabaseService(uid:user.uid).messagesgroup(group), 
      initialData: [],
      child: Container( 
        child: Column(children: [
          _dropDownCategory(user.uid),
          Expanded(
            child:Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*4/5,
              child: MessageList(),
            )
          ),
        ],),
        ),
    );
  }
      Widget _dropDownCategory(String uid){
        return StreamBuilder<QuerySnapshot>(
        stream:  DatabaseService().groupsCollection.where('members',arrayContains: uid).orderBy('groupName').snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) return const Center(
            child: const CupertinoActivityIndicator(),
          );
          return new Container(
            child: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      padding: EdgeInsets.all(5),
                      child: new Text("Filtruj grupe",style: TextStyle(fontSize: 17),),
                    )
                ),
                new Expanded(
                  child:new InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Wybierz grupe',
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "OpenSans",
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    isEmpty: group == null,
                    child: new DropdownButton(
                     // value: group,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
                          group = newValue;
                        });
                      },
                      items: snapshot.data.docs.map((DocumentSnapshot document) {
                        return new DropdownMenuItem<String>(
                            value: document['groupId'],
                            child: new Container(
                              height: 30.0,
                              padding: EdgeInsets.all(5),
                              child: Container(width:70,height: 70,child:new Text(document['groupName'])),
                            )
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      );
    }
}

class MessageList extends StatefulWidget{
  @override 
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList>{
  @override 
  Widget build(BuildContext context){

    final message = Provider.of<List<MyMessage>>(context);

    return ListView.builder(
      itemCount: message.length ?? 0,
      itemBuilder: (context,index){
        return MessageTile(message: message[index]);
      },
    );

  }
}

class MessageTile extends StatelessWidget {
  final MyMessage message;
  MessageTile({this.message});

  @override
  Widget build(BuildContext context){
    final user = Provider.of<MyUser>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24,vertical: 8),
      margin: EdgeInsets.symmetric(vertical: 8,),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24,vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).splashColor,Theme.of(context).dividerColor]
                ),
              borderRadius: BorderRadius.only(topLeft:Radius.circular(23),topRight:Radius.circular(23),bottomRight: Radius.circular(23) ),
              border: Border.all(color: Colors.greenAccent,width: message.see ==true ? 0 : 3 ),
              ),
            child: Text(message.message,style: TextStyle(color: Theme.of(context).hintColor,fontSize: 17),),
            ),
            onTap: ()async  => {
              await DatabaseService().makemessageread(user.uid, message.messageid),
            },
          ),
          SizedBox(height: 1,),
          Text(DateTime.fromMillisecondsSinceEpoch(message.date.millisecondsSinceEpoch).toString().substring(0,19)),
        ],
      ),
    );
  }
  
}