import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:splitcost/style/colors.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.color1,
      child: Center(
        child: SpinKitChasingDots(
          color: MyColors.color2,
          size: 50,
        ),
      ),
    );
  }
}