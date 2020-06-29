import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital/cca/cca_normal_view.dart';
import 'package:orbital/cca/cca_admin_view.dart';
import 'package:orbital/services/auth.dart';

class ExploreAll extends StatelessWidget {
  static const index = 1;
  final database = Firestore.instance;
  Auth auth;

  ExploreAll({@required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: database.collection('CCA').orderBy('Name').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return new Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data.documents.isEmpty) {
          return new Center(
              child: Text(
            'No CCAs available ☹️',
            style: TextStyle(fontSize: 30),
          ));
        } else {
          return new ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return new SizedBox(
                  height: 100,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          side: new BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(4.0)),
                      margin: EdgeInsets.all(3),
                      elevation: 3.0,
                      shadowColor: Colors.blue,
                      child: InkWell(
                          highlightColor: Colors.blueAccent,
                          onTap: () => goToCCAViewPage(context, document),
                          child: ListTile(
                            title: new Text(document['Name'],
                                style: TextStyle(fontSize: 24)),
                            subtitle: new Text(document['Category'],
                                style: TextStyle(fontSize: 20)),
                          ))));
            }).toList(),
          );
        }
      },
    );
  }

  void goToCCAViewPage(BuildContext context, DocumentSnapshot document) async {
    bool userIsAdmin = await auth.isAdmin(document['Name']);
    if (userIsAdmin) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CCAAdminView(
                    document: document,
                    exploreIndex: index,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CCANormalView.tab(document: document, previousIndex: index)));
    }
  }
}