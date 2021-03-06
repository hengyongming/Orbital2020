import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital/screens/app_drawer.dart';
import 'package:orbital/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital/cca/event_admin_view.dart';
import 'package:orbital/cca/event_normal_view.dart';

class MyEvents extends StatelessWidget {
  final collectionRef = Firestore.instance.collection('Event');
  Auth auth;
  Future<List> bookmarks;
  List bookmarkList;

  MyEvents({@required this.auth}) {
    bookmarks = auth.getBookmarks();
  }

  Widget closedEvent(AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.data['Closed'] == true) {
      return Image.asset(
        "images/closed.png",
        height: 100,
        width: 100,
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: Text('Bookmarks', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      drawer: AppDrawer(drawer: Drawers.bookmark),
      body: getBookmarkFuture(),
    );
  }

  Widget getBookmarkStream() {
    return StreamBuilder<List<String>>(
        stream: Stream.fromFuture(bookmarks),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data.isEmpty) {
            return new Center(
                child: Text(
              'No bookmarked events ☹️',
              style: TextStyle(fontSize: 30),
            ));
          } else {
            bookmarkList = snapshot.data;
            return ListView.builder(
                shrinkWrap: true,
                itemCount: bookmarkList.length,
                itemBuilder: (BuildContext ctx, int index) =>
                    buildBody(ctx, index));
          }
        });
  }

  Widget getBookmarkFuture() {
    return FutureBuilder(
        future: bookmarks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            bookmarkList = snapshot.data.reversed.toList();
            if (bookmarkList.isEmpty) {
              return Center(
                  child: Text(
                'No bookmarked events ☹️',
                style: TextStyle(fontSize: 30),
              ));
            } else {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookmarkList.length,
                  itemBuilder: (BuildContext ctx, int index) =>
                      buildBody(ctx, index));
            }
          }
        });
  }

  Widget buildBody(BuildContext context, int index) {
    return FutureBuilder(
        future: collectionRef.document(bookmarkList[index]).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          } else {
            String eventTime = snapshot.data['EventTime'];

            return new SizedBox(
                height: 100,
                child: Card(
                    shape: RoundedRectangleBorder(
                        side:
                            new BorderSide(color: Colors.grey[600], width: 1.0),
                        borderRadius: BorderRadius.circular(4.0)),
                    margin: EdgeInsets.all(3),
                    elevation: 1.0,
                    shadowColor: Colors.blue,
                    child: InkWell(
                        highlightColor: Colors.blueAccent,
                        onTap: () => goToEventPage(context, snapshot.data),
                        child: ListTile(
                          title: new Text(
                            snapshot.data['CCA'] + ": " + snapshot.data['Name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 22),
                          ),
                          subtitle: new Text(eventTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 20)),
                          trailing: closedEvent(snapshot),
                        ))));
          }
        });
  }

  void goToEventPage(BuildContext context, DocumentSnapshot document) async {
    bool userIsAdmin = await auth.isAdminOf(document['CCA']);
    if (userIsAdmin) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventAdminView.fromMyEvents(
                    document: document,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventNormalView.fromMyEvents(
                    document: document,
                  )));
    }
  }
}
