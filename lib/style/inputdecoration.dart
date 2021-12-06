import 'package:flutter/material.dart';
import 'package:splitcost/style/colors.dart';

abstract class MyDecoration{
  static var textInputDecoration = InputDecoration(
    // hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 17),
    // fillColor: MyColors.color5,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: MyColors.color2),
      borderRadius: BorderRadius.circular(45)
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: MyColors.color2, width: 2.0),
      borderRadius: BorderRadius.circular(45.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: MyColors.red, width: 1),
      borderRadius: BorderRadius.circular(45.0),
    ), 
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: MyColors.color2, width: 2.0),
      borderRadius: BorderRadius.circular(45.0),
    ),
  );

  static var mybuttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(MyColors.color3.withOpacity(0.5)),
    minimumSize: MaterialStateProperty.all(Size(300, 60)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      side: BorderSide(
        color: Colors.white,
        width: 1,
        style: BorderStyle.solid),
        borderRadius:BorderRadius.circular(45.0))),
  );

   static var remindbuttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(MyColors.color3.withOpacity(0.5)),
    minimumSize: MaterialStateProperty.all(Size(50, 50)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      side: BorderSide(
        color: Colors.white,
        width: 1,
        style: BorderStyle.solid),
        borderRadius:BorderRadius.circular(90.0))),
  );
}
