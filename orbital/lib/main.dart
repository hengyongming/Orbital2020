import 'package:flutter/material.dart';
import 'package:orbital/cca/create_cca.dart';
import 'package:orbital/screens/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/activity_feed/activity_feed.dart';
import 'screens/explore/explore.dart';
import 'package:orbital/screens/authetication/sign_up.dart';
import 'package:orbital/cca/create_event.dart';
import 'package:orbital/cca/create_cca.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCA App',
      initialRoute: '/',
      routes: {
        '/': (BuildContext ctx) => Wrapper(),
        '/activity': (BuildContext ctx) => ActivityFeed(),
        '/explore': (BuildContext ctx) => Explore(),
        '/signUp' : (BuildContext ctx) => SignUpPage(),
        '/createcca' : (BuildContext ctx) => CreateCCA(),
        '/createevent': (BuildContext ctx) => CreateEvent()
      
      },
      
    );
  }
}
