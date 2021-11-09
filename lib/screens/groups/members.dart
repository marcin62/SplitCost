import 'package:flutter/material.dart';

class Members extends StatefulWidget {

  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
  Widget build(BuildContext context) {
     return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.jpg'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white)),
              ),
          ],
        )
      ],
    );
  }
}