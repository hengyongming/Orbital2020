import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:expandable/expandable.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class EventFeedbackAdmin extends StatelessWidget {
  DocumentReference eventDocRef;
  DocumentSnapshot eventDocSnapshot;

  EventFeedbackAdmin(
      {@required this.eventDocRef, @required this.eventDocSnapshot});

  BoxDecoration myBoxDecoration(Color color) {
    return BoxDecoration(
      border: Border.all(
        color: color,
        width: 2.0,
      ),
      borderRadius: BorderRadius.all(Radius.circular(7.0)),
    );
  }

  Widget _ratingBar() {
    double aveRating = eventDocSnapshot['totalFeedbackScore'] /
        eventDocSnapshot['totalFeedbackCount'];
    String satisfaction = aveRating <= 1.0
        ? "Very Dissatisfied"
        : aveRating <= 2.0
            ? "Dissatisfied"
            : aveRating <= 3.0
                ? "Neutral"
                : aveRating <= 4.0 ? "Satisfied" : "Very Satisfied";
    return Column(children: [
      RatingBarIndicator(
        rating: aveRating,
        itemSize: 50,
        itemCount: 5,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Icon(
                FontAwesomeIcons.angry,
                color: Colors.red,
              );
            case 1:
              return Icon(
                FontAwesomeIcons.frown,
                color: Colors.redAccent,
              );
            case 2:
              return Icon(
                FontAwesomeIcons.meh,
                color: Colors.amber,
              );
            case 3:
              return Icon(
                FontAwesomeIcons.smile,
                color: Colors.lightGreen,
              );
            case 4:
              return Icon(
                FontAwesomeIcons.laughBeam,
                color: Colors.green,
              );
          }
        },
      ),
      SizedBox(height: 7),
      Text("${aveRating.toStringAsFixed(2)}/5.0",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      Text("$satisfaction",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget barChart() {
    List<Rating> data = [
      Rating(
          count: eventDocSnapshot['feedbackES'],
          satisfaction: "V. Satisfied",
          barColor: charts.ColorUtil.fromDartColor(Colors.green)),
      Rating(
          count: eventDocSnapshot['feedbackS'],
          satisfaction: "Satisfied",
          barColor: charts.ColorUtil.fromDartColor(Colors.lightGreen)),
      Rating(
          count: eventDocSnapshot['feedbackN'],
          satisfaction: "Neutral",
          barColor: charts.ColorUtil.fromDartColor(Colors.amber)),
      Rating(
          count: eventDocSnapshot['feedbackD'],
          satisfaction: "Dissatisfied",
          barColor: charts.ColorUtil.fromDartColor(Colors.redAccent)),
      Rating(
          count: eventDocSnapshot['feedbackED'],
          satisfaction: "V. Dissatisfied",
          barColor: charts.ColorUtil.fromDartColor(Colors.red)),
    ];
    List<charts.Series<Rating, String>> series = [
      charts.Series(
          id: "Ratings",
          data: data,
          domainFn: (Rating series, _) => series.satisfaction,
          measureFn: (Rating series, _) => series.count,
          colorFn: (Rating series, _) => series.barColor)
    ];

    return Padding(
      padding: new EdgeInsets.all(3.0),
      child: new SizedBox(
          height: 240.0,
          child: charts.BarChart(
            series,
            animate: true,
            vertical: false,
          )),
    );
  }

  Widget expendableStats() {
    return ExpandableNotifier(
        initialExpanded: false,
        child: ExpandablePanel(
            header: Row(children: [
              Icon(
                FontAwesomeIcons.chartBar,
                size: 30,
              ),
              SizedBox(
                width: 12,
              ),
              Text(" Statistics",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20))
            ]),
            collapsed: SizedBox(),
            expanded: Container(
              padding: EdgeInsets.fromLTRB(3, 2, 0, 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              alignment: Alignment.center,
              width: 400,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: [
                      Text(" No. of respondents:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 3,
                      ),
                      Text(" ${eventDocSnapshot['totalFeedbackCount']}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                    ]),
                    SizedBox(height: 20),
                    Text(
                      " Mean rating:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Row(children: [
                      SizedBox(
                        width: 60,
                      ),
                      _ratingBar(),
                    ]),
                    SizedBox(height: 27),
                    Text(
                      " Rating distribution:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    barChart(),
                  ]),
            )));
  }

  Widget feedbackWidget(DocumentSnapshot doc) {
    final df = new DateFormat('dd/MM/yyyy');
    return Container(
        margin: EdgeInsets.all(2),
        padding: const EdgeInsets.fromLTRB(5, 4, 3, 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  doc['Anonymous']
                      ? Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("${doc['Name']}"))
                      : Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("${doc['Name']}\n${doc['Email']}")),
                  Spacer(
                    flex: 3,
                  ),
                  Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text("${df.format(doc['DateTime'].toDate())}")),
                ],
              ),
              SizedBox(
                height: 7,
              ),
              Text("Rating: ${doc['Rating']}/5.0"),
              SizedBox(
                height: 7,
              ),
              Text("${doc['Comment']}"),
            ],
          ),
        ));
  }

  Widget expendableFeedback(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ExpandablePanel(
      header: Row(children: [
        Icon(
          FontAwesomeIcons.comments,
          size: 30,
        ),
        SizedBox(
          width: 14,
        ),
        Text(" Feedback",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20))
      ]),
      collapsed: SizedBox(),
      expanded: Column(
        children: snapshot.data.documents.map((DocumentSnapshot document) {
          return feedbackWidget(document);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: eventDocRef.collection("Feedback").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data.documents.isEmpty) {
            return new Center(
                child: Text(
              'No feedback available ☹️',
              style: TextStyle(fontSize: 30),
            ));
          } else {
            return SingleChildScrollView(
                child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 380,
                  child: expendableStats(),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: 380,
                  child: expendableFeedback(snapshot),
                ),
                SizedBox(
                  height: 40,
                )
              ],
            ));
          }
        });
  }
}

class Rating {
  final count;
  final satisfaction;
  final charts.Color barColor;
  Rating(
      {@required this.count,
      @required this.satisfaction,
      @required this.barColor});
}
