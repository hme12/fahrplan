import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './functions.dart';
import './gcode.dart';
import './otd_trips.dart';
import './otd_onestation.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  TripPageState createState() => TripPageState();
}

class TripPageState extends State<TripPage> {
  int tripLength = 1;
  var TripIds = [];
  var TheTripMap = {};
  var TheTrip = [];
  String TheOneStation = "";
  bool inArgsNotDone = true;
  String thistUtcd = " ";
  String thistLoc = " ";
  String thistDate = " ";

  String requestUtc = "";
  String startLats = "no latitude";
  String startLongs = "";
  String radius = "";
  String numStats = "";
  String numStops = "";
  String startAddress = "";
  String nstatsAddress = "";
  String stationId = "";
  String stationLocation = "";
  String stationMode = "";
  String stationLats = "";
  String stationLongs = "";

  String journeyRef = "";
  String journeyOrig = "";
  String journeyDest = "";
  String journeyDate = "";
  String journeySName = "";
  String journeyMode = "";
  String journeyOpDay = "";

  bool addressNotFound = true;
  String stationAddress = "no address";

  double tripFontSize = 20.0;
  double tripFontSizeT = 20.0 * 1.2;
  double tripFontSizeS = 20.0 * 0.8;
  double tripIconSize = 30.0;

  List<dynamic> inArgs = [];
  List<dynamic> startArgs = [];
  List<dynamic> statsArgs = [];
  List<dynamic> nstatsArgs = [];
  List<dynamic> stopArgs = [];

  List<dynamic> fillArgs(int count, List<dynamic> iArgs) {
    List<dynamic> fArgs = [];

    for (var i = 0; i < count; i++) {
      fArgs.add(iArgs[i]);
    }

    return fArgs;
  }

  void go_nstations() {
    String newroute = 'StationsPage';

    Navigator.pushNamed(context, newroute, arguments: nstatsArgs);
  }

  void go_start() {
    String newroute = 'StartPage';

    Navigator.pushNamed(context, newroute, arguments: startArgs);
  }

  void go_stations() {
    String newroute = 'StationsPage';

    Navigator.pushNamed(context, newroute, arguments: statsArgs);
  }

  void go_stops() {
    String newroute = 'StopsPage';

    Navigator.pushNamed(context, newroute, arguments: stopArgs);
  }

  void oneStation(
    String fSId,
    String fSLId,
    String fSName,
    String fATime1,
    String fDTime1,
  ) {
    myOneStationRequest(requestUtc, fSId, fSName, fATime1, fDTime1);
  }

  void myOneStationRequest(
    String ftUtc,
    String fstId,
    String fstName,
    String fATime1,
    String fDTime1,
  ) async {
    TheOneStation = await myOneStationRequestF(ftUtc, fstId, fstName);

    List<String> TheOneStationList = TheOneStation.split('|');

    String nreqUtc = fATime1;
    if (fATime1.length < 1) {
      nreqUtc = fDTime1;
    }

    double nstatsLat = double.parse(TheOneStationList[2]);
    double nstatsLong = double.parse(TheOneStationList[3]);

    nstatsArgs.add(nreqUtc);
    nstatsArgs.add(TheOneStationList[2]);
    nstatsArgs.add(TheOneStationList[3]);
    nstatsArgs.add(inArgs.elementAt(3));
    nstatsArgs.add(inArgs.elementAt(4));
    nstatsArgs.add(inArgs.elementAt(5));

    geoCodes(nstatsLat, nstatsLong);
  }

  void geoCodes(double nLat, double nLong) async {
    nstatsAddress = await geoCodesFT(nLat, nLong);

    nstatsArgs.add(nstatsAddress);

    go_nstations();
  }

  void myTripRequest(String ftUtc, String fJRef, String fOpDay) async {
    if (TheTrip.length < 1) {
      TheTrip = await myTripRequestF(ftUtc, fJRef, fOpDay);

      TheTripMap = TheTrip[0];

      setState(() {});
    }
  }

  Widget mkCard(int idst) {
    String thisTrip = TheTripMap[TripIds[idst]].toString();

    List<String> thisTripList = thisTrip.split('|');

    String thisSId = thisTripList[0];
    String thisSName = thisTripList[1];
    String thisDTime0 = thisTripList[2];
    String thisDTime1 = thisTripList[3];
    String thisATime0 = thisTripList[4];
    String thisATime1 = thisTripList[5];
    String thisQuayNumber = thisTripList[6];
    String thisPrevOnw = thisTripList[7];
    String thisSloid = thisTripList[8];

    String thisATimeString = "";
    List<String> thisATimes = [];

    if (thisATime0.length > 0) {
      thisATimes = ETString(thisATime0, thisATime1, "N");
      thisATimeString = thisATimes[0];
    }

    String thisDTimeString = "";
    List<String> thisDTimes = [];

    if (thisDTime0.length > 0) {
      thisDTimes = ETString(thisDTime0, thisDTime1, "N");
      thisDTimeString = thisDTimes[0];
    }

    String AnAb = "";
    String An = "";
    String Ab = "";
    String Nl = "";

    if (thisATimeString.length > 0) {
      An = "Ankunft : " + thisATimeString;
    }

    if (thisDTimeString.length > 0) {
      Ab = "Abfahrt : " + thisDTimeString;
    }

    if ((An.length > 0) && (Ab.length > 0)) {
      Nl = "\n";
    }

    AnAb = An + Nl + Ab;

    Color? cColor = Colors.blueGrey[100];

    if (journeyMode.contains("rail")) {
      cColor = Colors.red[100];
      if (thisPrevOnw.contains("P")) {
        cColor = Colors.red[50];
      }
    }

    if (journeyMode.contains("bus")) {
      cColor = Colors.yellow[100];
      if (thisPrevOnw.contains("P")) {
        cColor = Colors.yellow[50];
      }
    }

    if (journeyMode.contains("water")) {
      cColor = Colors.blue[100];
      if (thisPrevOnw.contains("P")) {
        cColor = Colors.blue[50];
      }
    }

    if (journeyMode.contains("tram")) {
      cColor = Colors.green[100];
      if (thisPrevOnw.contains("P")) {
        cColor = Colors.green[50];
      }
    }

    String quay = "";

    if (thisQuayNumber.length > 0) {
      quay = "Gl. " + thisQuayNumber;
    }

    TextStyle normal = TextStyle(fontSize: tripFontSize);
    TextStyle underl = TextStyle(
      fontSize: tripFontSize,
      decoration: TextDecoration.underline,
    );

    if (stationId == thisSId) {
      normal = underl;
      cColor = Colors.white;
    }

    if (journeySName == thisSName) {
      normal = underl;
      cColor = Colors.white;
    }

    return Card(
      color: cColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(thisSName + "  " + quay, style: normal),
            subtitle: Text(AnAb, style: TextStyle(fontSize: tripFontSizeS)),
            onTap: () {
              oneStation(thisSId, thisSloid, thisSName, thisATime1, thisDTime1);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iroute = ModalRoute.of(context);
    final isett = iroute!.settings;
    inArgs = (isett.arguments) as List;

    if (inArgsNotDone) {
      startArgs = fillArgs(7, inArgs);
      statsArgs = fillArgs(7, inArgs);
      stopArgs = fillArgs(12, inArgs);

      requestUtc = inArgs.elementAt(0);
      startLats = inArgs.elementAt(1);
      startLongs = inArgs.elementAt(2);
      radius = inArgs.elementAt(3);
      numStats = inArgs.elementAt(4);
      numStops = inArgs.elementAt(5);
      startAddress = inArgs.elementAt(6);
      stationId = inArgs.elementAt(7);
      stationLocation = inArgs.elementAt(8);
      stationMode = inArgs.elementAt(9);
      stationLats = inArgs.elementAt(10);
      stationLongs = inArgs.elementAt(11);

      journeyRef = inArgs.elementAt(12);
      journeyOrig = inArgs.elementAt(13);
      journeyDest = inArgs.elementAt(14);
      journeyDate = inArgs.elementAt(15);
      journeySName = inArgs.elementAt(16);
      journeyMode = inArgs.elementAt(17);
      journeyOpDay = inArgs.elementAt(18);

      thistUtcd = requestUtc.replaceAll("T", " ");
      var thistUtc = DateTime.parse(thistUtcd);
      thistLoc = thistUtc.toLocal().toString();
      List<String> thistLocs = thistLoc.split(" ");
      thistDate = thistLocs[0];

      inArgsNotDone = false;
    }

    Size size = MediaQuery.sizeOf(context);

    if (size.shortestSide < 700) {
      tripFontSize = 15;
      tripFontSizeT = 15 * 1.2;
      tripFontSizeS = 15 * 0.8;
      tripIconSize = 25;
    }

    myTripRequest(requestUtc, journeyRef, journeyOpDay);
    tripLength = TheTripMap.length;
    var tripKeys = TheTripMap.keys;
    String titleText = journeyOpDay + "  " + journeyOrig + " -  " + journeyDest;
    Color? tColor = Colors.teal[400];

    if (tripLength < 1) {
      titleText = titleText + "   nicht gefunden";
      tColor = Colors.amber[400];
    }

    for (final tKy in tripKeys) {
      TripIds.add(tKy);
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          title: Text(titleText, style: TextStyle(fontSize: tripFontSizeT)),
          backgroundColor: tColor,
        ),
        body: ListView.builder(
          itemCount: tripLength,
          itemBuilder: (context, index) => mkCard(index),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.teal[400],
          height: 70.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.west, size: tripIconSize),
                color: Colors.lightGreenAccent,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_stops();
                },
              ),
              IconButton(
                icon: Icon(Icons.trip_origin, size: tripIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_start();
                },
              ),
              IconButton(
                icon: Icon(Icons.store, size: tripIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_stations();
                },
              ),
              IconButton(
                icon: Icon(Icons.departure_board, size: tripIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_stops();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
