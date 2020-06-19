import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital/cca/cca_normal_view.dart';
import 'package:orbital/services/auth.dart';

class ExploreFavourites extends StatelessWidget {
  final collectionRef = Firestore.instance.collection('CCA');
  Auth auth = new Auth();
  Future<List> favourites;
  List favList;

  ExploreFavourites() {
    favourites = auth.getFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: favourites,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            favList = snapshot.data.reversed.toList();
            return ListView.builder(
                itemCount: favList.length,
                itemBuilder: (BuildContext ctxt, int index) =>
                    buildBody(ctxt, index));
          }
        });
  }

  Widget buildBody(BuildContext ctxt, int index) {
    return FutureBuilder(
        future: collectionRef.document(favList[index]).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          } else {
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
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CCANormalView(
                                        document: snapshot.data,
                                      )));
                        },
                        child: ListTile(
                          title: new Text(snapshot.data['Name'],
                              style: TextStyle(fontSize: 24)),
                          subtitle: new Text(snapshot.data['Category'],
                              style: TextStyle(fontSize: 20)),
                        ))));
          }
        });
  }
}