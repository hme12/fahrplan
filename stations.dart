import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './otd_stations.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  StationsPageState createState() => StationsPageState();
}

class StationsPageState extends State<StationsPage> {
  int stationsLength = 1;
  var TheStations = [];
  var TheStationsMap = {};
  var StationsIds = [];

  String requestUtc = "";
  String startLats = "";
  String startLongs = "";
  String radius = "";
  String numStats = "";
  String numStops = "";
  String startAddress = "";

  bool inArgsNotDone = true;

  List<dynamic> inArgs = [];
  List<dynamic> startArgs = [];
  List<dynamic> stopsArgs = [];
  List<dynamic> stmapArgs = [];

  double stationsFontSize = 20.0;
  double stationsFontSizeT = 20.0 * 1.2;
  double stationsFontSizeS = 20.0 * 0.8;
  double stationsIconSize = 30.0;

  void go_stops(String idx) {
    String newroute = 'StopsPage';

    String stopStation = TheStationsMap[idx].toString();

    List<String> stopStationList = stopStation.split('|');

    String stopName = stopStationList[1];
    String stopMode = stopStationList[5];
    String stopLat = stopStationList[3];
    String stopLng = stopStationList[2];

    stopsArgs.add(idx);
    stopsArgs.add(stopName);
    stopsArgs.add(stopMode);
    stopsArgs.add(stopLat);
    stopsArgs.add(stopLng);

    Navigator.pushNamed(context, newroute, arguments: stopsArgs);
  }

  void go_start() {
    String newroute = 'StartPage';

    Navigator.pushNamed(context, newroute, arguments: startArgs);
  }

  void go_stmap() {
    String newroute = 'OstMapPage';

    Navigator.pushNamed(context, newroute, arguments: stmapArgs);
  }

  void myStationsRequest(String frequestUtc, String fLatitude,
      String fLongitude, String fRadius, String fNumStats) async {
    if (TheStations.length < 1) {
      TheStations = await myStationsRequestF(
          frequestUtc, fLatitude, fLongitude, fRadius, fNumStats);

      TheStationsMap = TheStations[0];

      setState(() {});
    }
  }

  Widget mkCard(int idst) {
    String thisStation = TheStationsMap[StationsIds[idst]].toString();

    List<String> thisStationList = thisStation.split('|');

    String thisId = thisStationList[0];
    String thisLocation = thisStationList[1];
    String thisGeoLong = thisStationList[2];
    String thisGeoLat = thisStationList[3];
    String thisDistance = thisStationList[4];
    String thisMode = thisStationList[5];

    stmapArgs.add(thisGeoLat);
    stmapArgs.add(thisGeoLong);

    double Distance = double.parse(thisDistance);
    double DistMin = Distance * 0.015;
    String thisDistMin = DistMin.toStringAsFixed(2);

    Color? cColor = Colors.blueGrey[100];

    if (thisMode.contains("rail")) {
      cColor = Colors.red[100];
    }

    if (thisMode.contains("bus")) {
      cColor = Colors.yellow[100];
    }

    if (thisMode.contains("water")) {
      cColor = Colors.blue[100];
    }

    if (thisMode.contains("tram")) {
      cColor = Colors.green[100];
    }

    return Card(
      color: cColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(thisLocation,
                style: TextStyle(fontSize: stationsFontSize)),
            subtitle: Text(
                thisMode +
                    "   " +
                    thisDistance +
                    " m   " +
                    thisDistMin +
                    " min",
                style: TextStyle(fontSize: stationsFontSize)),
            onTap: () {
              go_stops(thisId);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

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
//      print("inArgs in stations " + inArgs.toString() + "\n");

      startArgs = inArgs.toList();
      stopsArgs = inArgs.toList();
      stmapArgs = inArgs.toList();

      requestUtc = inArgs.elementAt(0);
      startLats = inArgs.elementAt(1);
      startLongs = inArgs.elementAt(2);
      radius = inArgs.elementAt(3);
      numStats = inArgs.elementAt(4);
      numStops = inArgs.elementAt(5);
      startAddress = inArgs.elementAt(6);

      inArgsNotDone = false;
    }

    Size size = MediaQuery.sizeOf(context);

    if (size.shortestSide < 700) {
      stationsFontSize = 15;
      stationsFontSizeT = 15 * 1.2;
      stationsFontSizeS = 15 * 0.8;
      stationsIconSize = 25;
    }

    myStationsRequest(requestUtc, startLats, startLongs, radius, numStats);
    stationsLength = TheStationsMap.length;
    var stationsKeys = TheStationsMap.keys;

    for (final sKy in stationsKeys) {
      StationsIds.add(sKy);
    }

    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title:
            Text(startAddress, style: TextStyle(fontSize: stationsFontSizeT)),
        backgroundColor: Colors.teal[400],
      ),
      body: ListView.builder(
        itemCount: stationsLength,
        itemBuilder: (context, index) => mkCard(index),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal[400],
        height: 70.0,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.west, size: stationsIconSize),
              color: Colors.lightGreenAccent,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_start();
              },
            ),
            IconButton(
              icon: Icon(Icons.trip_origin, size: stationsIconSize),
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_start();
              },
            ),
            IconButton(
              icon: Icon(Icons.map_rounded, size: stationsIconSize),
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_stmap();
              },
            ),
          ],
        ),
      ),
    ));
  }
}
