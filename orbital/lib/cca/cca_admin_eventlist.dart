import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbital/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital/cca/event_admin_view.dart';
import 'package:orbital/cca/create_event.dart';

class CCAAdminEventlist extends StatelessWidget {
  final database = Firestore.instance;
  DocumentSnapshot ccaDocument;

  CCAAdminEventlist({@required this.ccaDocument});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Column(children: [
      publishButton(context),
      eventList(),
    ]);
  }

  Widget publishButton(BuildContext context) {
    return Container(
      width: 280,
      padding: EdgeInsets.all(8),
      child: CupertinoButton.filled(
        child: Row(children: [
          Icon(Icons.add),
          SizedBox(width: 10,),
          Text('Create Event'),
        ]),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateEvent(
                      ccaDocument: ccaDocument,
                    ))),
      ),
    );
  }

  Widget closedEvent(DocumentSnapshot doc){
    if(doc['Closed'] == true){
      return Image.network(
        'https://firebasestorage.googleapis.com/v0/b/nus-whattodo.appspot.com/o/closed_event_image%2Fclosed-stamp-png.png?alt=media&token=c945c36e-b975-442a-94b6-5d91a39623b8'
      );
    }
    else{
      return SizedBox();
    }
    
  }

  Widget eventList() {
    return StreamBuilder<QuerySnapshot>(
      stream: database
          .collection('Event')
          .where("CCA", isEqualTo: ccaDocument['Name'])
          .orderBy('DateCreated', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text(
              'No events available ☹️',
              style: TextStyle(fontSize: 20),
            );
          default:
            return new Expanded(
                child: ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new SizedBox(
                    height: 100,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            side:
                                new BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(4.0)),
                        margin: EdgeInsets.all(3),
                        elevation: 3.0,
                        shadowColor: Colors.blue,
                        child: InkWell(
                            highlightColor: Colors.blueAccent,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EventAdminView(document: document)));
                            },
                            child: ListTile(
                              title: new Text(
                                  document['CCA'] + ': ' + document['Name'],
                                  style: TextStyle(fontSize: 24)),
                              subtitle: new Text(document['EventTime'],
                                  style: TextStyle(fontSize: 20)),
                                  trailing: closedEvent(document),
                            ))));
              }).toList(),
            ));
        }
      },
    );
  }
}
