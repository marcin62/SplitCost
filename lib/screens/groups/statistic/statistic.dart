import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitcost/models/myExpenses.dart';
import 'package:splitcost/models/myGroup.dart';
import 'package:splitcost/models/myUser.dart';
import 'package:splitcost/services/database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';


class Statistic extends StatefulWidget {

  @override
  _StatisticState createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  bool isstatistic = true;
  @override
  Widget build(BuildContext context) {
    final group = Provider.of<MyGroup>(context);
    return Scaffold(
      body:  Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
         padding: EdgeInsets.all(0),
          margin: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Text("Podział na użytkowników",style: TextStyle(fontSize: 17),),
                Checkbox(value: !isstatistic, onChanged:(bool val) {setState(()=>{ 
                  isstatistic= !isstatistic, });}),
                  Spacer(),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/6*4.5,
              child: MultiProvider(
                providers: [
                  StreamProvider<List<MyExpenses>>.value(value: DatabaseService().getexpenses(group.groupid), initialData: []),
                  StreamProvider<List<UserData>>.value(value: DatabaseService().getUsers(), initialData: [])
                ],
                child:isstatistic ? ChartMaker() : ChartUser(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartMaker extends StatefulWidget {

  @override
  _ChartMakerState createState() => _ChartMakerState();
}

class _ChartMakerState extends State<ChartMaker> {
  List<ChartClass> _currentMonthData;
  double ammount;

  @override
  Widget build(BuildContext context) {
    _currentMonthData = getdata(context);
    return SfCartesianChart(
      title: ChartTitle(text: "Suma wydatków " + ammount.toString() + " PLN"),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Data'),
        labelFormat: '{value}',
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat(),
        labelFormat: '{value}',
      ),
      series: <ChartSeries> [LineSeries<ChartClass,DateTime>(dataSource:_currentMonthData,
      xValueMapper: (ChartClass expen, _)=> expen.time,
      yValueMapper: (ChartClass expen, _)=> expen.price,
      )],
    );
  }

  List<ChartClass> getdata(BuildContext contextt)
  {
    List<ChartClass> list = new List();
    final expenses = Provider.of<List<MyExpenses>>(contextt);
    for(int i=0;i<expenses.length;i++)
    {
      MyExpenses temp = expenses.elementAt(i);
      int bylo = 0;
      for(int k =0;k<list.length;k++)
      {
        if(list.elementAt(k).time.year==temp.date.toDate().year &&list.elementAt(k).time.month==temp.date.toDate().month && list.elementAt(k).time.day==temp.date.toDate().day)
        {
          list.elementAt(k).price += double.parse(temp.price);
          bylo =1;
        }
      }
      if(bylo==0){
        list.add(ChartClass(time: temp.date.toDate(),price: double.parse(temp.price)));
      }
    }
    ammount=0;
    for(int i=0;i<list.length;i++)
    {
      ammount+=list.elementAt(i).price;
    }
    return list;
  }
}

class ChartClass{
  DateTime time;
  double price;
  ChartClass({this.time,this.price});
}

class ChartUser extends StatefulWidget {

  @override
  _ChartUserState createState() => _ChartUserState();
}

class _ChartUserState extends State<ChartUser> {
  List<ChartUserClass> _currentMonthData;
  double ammount;

  @override
  Widget build(BuildContext context) {
    _currentMonthData = getdata(context);
    return SfCartesianChart(
      title: ChartTitle(text: "Suma wydatków " + ammount.toString() + " PLN"),
      primaryXAxis: CategoryAxis(
                maximumLabelWidth: 60,
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat(),
        labelFormat: '{value} PLN',
      ),
      series: <ChartSeries<ChartUserClass, String>> [BarSeries<ChartUserClass,String>(dataSource:_currentMonthData,
      xValueMapper: (ChartUserClass expen, _)=> expen.userid,
      yValueMapper: (ChartUserClass expen, _)=> expen.price,
      )],
    );
  }

  List<ChartUserClass> getdata(BuildContext contextt)
  {
    List<ChartUserClass> list = new List();
    final expenses = Provider.of<List<MyExpenses>>(contextt);
    final users = Provider.of<List<UserData>>(contextt);
    for(int i=0;i<expenses.length;i++)
    {
      MyExpenses temp = expenses.elementAt(i);
      int bylo = 0;
      for(int k =0;k<list.length;k++)
      {
        if(list.elementAt(k).userid==temp.ownerid)
        {
          list.elementAt(k).price += double.parse(temp.price);
          bylo =1;
        }
      }
      String name;
      if(bylo==0){
        for(int w = 0 ;w<users.length;w++)
        {
          if(users.elementAt(w).uid == temp.ownerid)
          {
            name = users.elementAt(w).name;
            break;
          }
        }
        list.add(ChartUserClass(userid: name,price: double.parse(temp.price)));
      }
    }
    ammount=0;
    for(int i=0;i<list.length;i++)
    {
      ammount+=list.elementAt(i).price;
    }
    return list;
  }
}

class ChartUserClass{
  String userid;
  double price;
  ChartUserClass({this.userid,this.price});
}