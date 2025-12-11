import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './functions.dart';
import './gcode.dart';
import './otd_stops.dart';

class StopsPage extends StatefulWidget {
  const StopsPage({super.key});

  @override
  StopsPageState createState() => StopsPageState();
}

class StopsPageState extends State<StopsPage> {
  int stopsLength = 1;
  var TheStops = [];

  var Origs = {};
  var Dests = {};
  var sDate = {};
  var sName = {};
  var jMode = {};
  var OpDay = {};
  var Late = {};

  String requestUtc = "";
  String startLats = "no latitude";
  String startLongs = "";
  String radius = "";
  String numStats = "";
  String numStops = "";
  String startAddress = "";
  String stationId = "";
  String stationName = "";
  String stationMode = "";
  String stationLats = "";
  String stationLongs = "";
  String stationArrival = "";

  bool addressNotFound = true;
  String stationAddress = "no address";

  bool inArgsNotDone = true;
  String thistUtcd = " ";
  String thistLoc = " ";
  String thistDate = " ";
  String thistArrivS = "N";

  double stopsFontSize = 20.0;
  double stopsFontSizeT = 20.0 * 1.2;
  double stopsFontSizeS = 20.0 * 0.8;
  double stopsIconSize = 30.0;

  List<dynamic> inArgs = [];
  List<dynamic> startArgs = [];
  List<dynamic> statsArgs = [];
  List<dynamic> orsArgs = [];
  List<dynamic> tripArgs = [];

  List<dynamic> fillArgs(int count, List<dynamic> iArgs) {
    List<dynamic> fArgs = [];

    for (var i = 0; i < count; i++) {
      fArgs.add(iArgs[i]);
    }

    return fArgs;
  }

  void geoCodes(double stLat, double stLong) async {
    if (addressNotFound) {
      stationAddress = await geoCodesF(
        stLat,
        stLong,
        stationLats,
        addressNotFound,
        stationAddress,
      );

      if (stationAddress.contains("no address")) {
        addressNotFound = true;
      } else {
        addressNotFound = false;
      }
    }

    setState(() {});
  }

  void go_tripinfo(String jRef) {
    String newroute = 'TripPage';

    tripArgs.add(jRef);
    tripArgs.add(Origs[jRef]);
    tripArgs.add(Dests[jRef]);
    tripArgs.add(sDate[jRef]);
    tripArgs.add(sName[jRef]);
    tripArgs.add(jMode[jRef]);
    tripArgs.add(OpDay[jRef]);

    Navigator.pushNamed(context, newroute, arguments: tripArgs);
  }

  void go_start() {
    String newroute = 'StartPage';

    Navigator.pushNamed(context, newroute, arguments: startArgs);
  }

  void go_stations() {
    String newroute = 'StationsPage';

    Navigator.pushNamed(context, newroute, arguments: statsArgs);
  }

  void go_map() {
    String newroute = 'OrsDirPage';

    addressNotFound = true;
    orsArgs.add(stationAddress);

    Navigator.pushNamed(context, newroute, arguments: orsArgs);
  }

  void myStopsRequest(String ftUtc, String fNumStops, String fStationId) async {
    if (TheStops.length < 1) {
      TheStops = await myStopsRequestF(ftUtc, fNumStops, fStationId);

      setState(() {});
    }
  }

  Widget mkCard(int idst) {
    String thisStop = TheStops[idst].toString();

    List<String> thisStopList = thisStop.split('|');

    String thisJRef = thisStopList[0];
    String thisTTime = thisStopList[3];
    String thisETime = thisStopList[4];
    String thisMode = thisStopList[5];
    String thisStart = thisStopList[7];
    String thisEnd = thisStopList[9];
    String thisPtMode = thisStopList[10];
    //    String thisTrain = thisStopList[11];
    String thisTrainName = thisStopList[12];
    String thisQuayNumber = thisStopList[13];
    String origDest = "Abfahrt nach \n" + thisEnd;

    Origs[thisJRef] = thisStart;
    Dests[thisJRef] = thisEnd;
    sDate[thisJRef] = thisTTime;
    sName[thisJRef] = stationName;
    jMode[thisJRef] = thisPtMode;

    if (thisMode.contains("Ankunft")) {
      origDest = "Ankunft von \n" + thisStart;
    }

    List<String> TimeList = ETString(thisTTime, thisETime, thistArrivS);
    String thisTimeString = TimeList[0];
    OpDay[thisJRef] = TimeList[1];
    Late[thisJRef] = TimeList[2];

    Color? cColor = Colors.blueGrey[100];

    if (thisPtMode.contains("rail")) {
      cColor = Colors.red[100];
      if (thisMode.contains("Ankunft")) {
        cColor = Colors.red[50];
      }
    }

    if (thisPtMode.contains("bus")) {
      cColor = Colors.yellow[100];
      if (thisMode.contains("Ankunft")) {
        cColor = Colors.yellow[50];
      }
    }

    if (thisPtMode.contains("water")) {
      cColor = Colors.blue[100];
      if (thisMode.contains("Ankunft")) {
        cColor = Colors.blue[50];
      }
    }

    if (thisPtMode.contains("tram")) {
      cColor = Colors.green[100];
      if (thisMode.contains("Ankunft")) {
        cColor = Colors.green[50];
      }
    }

    String quay = "Gl. " + thisQuayNumber + "  ";

    if (thisQuayNumber.length < 1) {
      quay = "";
    }

    TextStyle titleStyle = TextStyle(fontSize: stopsFontSize);

    if (Late[thisJRef].contains("tooLate")) {
      titleStyle = TextStyle(fontSize: stopsFontSize, color: Colors.redAccent);
    }

    return Card(
      color: cColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(thisTimeString + " " + origDest, style: titleStyle),
            subtitle: Text(
              quay + thisTrainName + "   " + thisStart + " - " + thisEnd,
              style: TextStyle(fontSize: stopsFontSizeS),
            ),
            onTap: () {
              go_tripinfo(thisJRef);
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
      orsArgs = inArgs.toList();
      tripArgs = inArgs.toList();

      requestUtc = inArgs.elementAt(0);
      startLats = inArgs.elementAt(1);
      startLongs = inArgs.elementAt(2);
      radius = inArgs.elementAt(3);
      numStats = inArgs.elementAt(4);
      numStops = inArgs.elementAt(5);
      startAddress = inArgs.elementAt(6);
      stationId = inArgs.elementAt(7);
      stationName = inArgs.elementAt(8);
      stationMode = inArgs.elementAt(9);
      stationLats = inArgs.elementAt(10);
      stationLongs = inArgs.elementAt(11);

      Duration arrDur = Duration(hours: 0);

      if (inArgs.length == 13) {
        stationArrival = inArgs[12];
        List<String> stArrList = stationArrival.split(":");
        int stArrHour = int.parse(stArrList[0]);
        int stArrMin = int.parse(stArrList[1]);
        int stArrSec = int.parse(stArrList[2]);

        arrDur = Duration(
          hours: stArrHour,
          minutes: stArrMin,
          seconds: stArrSec,
        );
      }

      thistUtcd = requestUtc.replaceAll("T", " ");
      var thistUtc = DateTime.parse(thistUtcd);
      var thistLocdt = thistUtc.toLocal();
      var thistArriv = thistLocdt.add(arrDur);
      thistArrivS = thistArriv.toString();
      thistLoc = thistUtc.toLocal().toString();
      List<String> thistLocs = thistLoc.split(" ");
      thistDate = thistLocs[0];

      inArgsNotDone = false;
    }

    Size size = MediaQuery.sizeOf(context);

    if (size.shortestSide < 700) {
      stopsFontSize = 15;
      stopsFontSizeT = 15 * 1.2;
      stopsFontSizeS = 15 * 0.8;
      stopsIconSize = 25;
    }

    myStopsRequest(requestUtc, numStops, stationId);
    stopsLength = TheStops.length;

    geoCodes(double.parse(stationLats), double.parse(stationLongs));

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          title: Text(
            thistDate + " " + stationName,
            style: TextStyle(fontSize: stopsFontSizeT),
          ),
          backgroundColor: Colors.teal[400],
        ),
        body: ListView.builder(
          itemCount: stopsLength,
          itemBuilder: (context, index) => mkCard(index),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.teal[400],
          height: 70.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.west, size: stopsIconSize),
                color: Colors.lightGreenAccent,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_stations();
                },
              ),
              IconButton(
                icon: Icon(Icons.trip_origin, size: stopsIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_start();
                },
              ),
              IconButton(
                icon: Icon(Icons.store, size: stopsIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_stations();
                },
              ),
              IconButton(
                icon: Icon(Icons.map, size: stopsIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_map();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
