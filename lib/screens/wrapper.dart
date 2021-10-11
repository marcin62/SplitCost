import 'package:flutter/material.dart';
import 'package:splitcost/screens/authenticate/authenticate.dart';

import 'home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if Login then show apropriate page
    return Authenticate();
  }
}