import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:orbital/cca/cca_admin_about.dart';
import 'package:orbital/cca/cca_admin_eventlist.dart';
import 'package:orbital/cca/cca_admin_panel.dart';
import 'package:orbital/screens/explore/explore.dart';
import 'package:orbital/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flushbar/flushbar.dart';

class CCAAdminView extends StatefulWidget {
  Auth auth = new Auth();
  DocumentSnapshot document;
  bool favCCA;
  bool fromExplore = false;
  bool fromMyCCAs = false;
  int currentIndex = 0;
  int exploreIndex = 0;

  CCAAdminView.fromExplore(
      {@required this.document,
      @required this.currentIndex,
      @required this.exploreIndex}) {
    fromExplore = true;
  }
  CCAAdminView.fromMyCCAs(
      {@required this.document, @required this.currentIndex}) {
    fromMyCCAs = true;
  }

  @override
  _CCAAdminViewState createState() => _CCAAdminViewState();
}

class _CCAAdminViewState extends State<CCAAdminView> {
  void _flushBar(BuildContext context) {
    String ccaName = widget.document['Name'];
    Flushbar(
      icon: !widget.favCCA
          ? Icon(
              FontAwesomeIcons.grinAlt,
              color: Colors.white,
            )
          : Icon(FontAwesomeIcons.frown, color: Colors.white),
      title: !widget.favCCA ? "Hooray!" : "Awww",
      message: !widget.favCCA
          ? "You have added $ccaName to your Favourites"
          : "You have removed $ccaName from your Favourites",
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.currentIndex == null ? 0 : widget.currentIndex,
        length: 3,
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: Colors.redAccent,
            title: Text(widget.document['Name'],
                style: TextStyle(color: Colors.black)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (widget.fromMyCCAs) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Explore.tab(index: widget.exploreIndex)));
                }
              },
              color: Colors.white,
            ),
            actions: [
              Ink(
                  decoration: ShapeDecoration(
                      color: Colors.transparent,
                      shape: CircleBorder(
                          side: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ))),
                  child: FutureBuilder(
                      future:
                          widget.auth.isFavouriteCCA(widget.document['Name']),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        } else {
                          widget.favCCA = snapshot.data;
                          return IconButton(
                            highlightColor: Colors.red[700],
                            icon: Icon(Icons.star),
                            iconSize: 35,
                            onPressed: () {
                              _flushBar(context);
                              if (widget.favCCA) {
                                widget.auth.removeFavouriteCCA(
                                    widget.document['Name']);
                              } else {
                                widget.auth
                                    .addFavouriteCCA(widget.document['Name']);
                              }
                              setState(() {
                                widget.favCCA = !widget.favCCA;
                              });
                            },
                            color: widget.favCCA ? Colors.orange : Colors.white,
                          );
                        }
                      }))
            ],
            bottom: TabBar(
              labelStyle: TextStyle(fontSize: 22.0),
              indicatorColor: Colors.amber[700],
              indicatorWeight: 4.0,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[50],
              tabs: <Widget>[
                Tab(
                  icon: Icon(FontAwesomeIcons.infoCircle),
                  child: Text("About"),
                ),
                Tab(
                  icon: Icon(Icons.event),
                  child: Text("Events"),
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.crown),
                  child: Text("Admin"),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              widget.fromMyCCAs
                  ? CCAAdminAbout.fromMyCCAs(
                      document: widget.document,
                    )
                  : CCAAdminAbout.fromExplore(
                      document: widget.document,
                      index: widget.exploreIndex,
                    ),
              widget.fromMyCCAs
                  ? CCAAdminEventlist.fromMyCCAs(
                      ccaDocument: widget.document,
                    )
                  : CCAAdminEventlist.fromExplore(
                      ccaDocument: widget.document,
                      index: widget.exploreIndex,
                    ),
              widget.fromMyCCAs
                  ? CCAAdminPanel.fromMyCCAs(
                      ccaName: widget.document['Name'],
                      auth: widget.auth,
                    )
                  : CCAAdminPanel.fromExplore(
                      ccaName: widget.document['Name'],
                      auth: widget.auth,
                      previousIndex: widget.exploreIndex,
                    )
            ],
          ),
        ));
  }
}
