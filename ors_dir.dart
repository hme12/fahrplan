import 'dart:core';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

import 'ors_key.dart';

class OrsDirPage extends StatefulWidget {
  const OrsDirPage({super.key});

  @override
  OrsDirPageState createState() => OrsDirPageState();
}

class OrsDirPageState extends State<OrsDirPage> {
  String appTitle = 'Lageplan';
  String urlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

  String dropDownProfile = "footWalking";

  List<LatLng> rPoints = [];
  List<LatLng> dirLine = [];
  LatLng sPoint = LatLng(0.0, 0.0);
  LatLng ePoint = LatLng(0.0, 0.0);
  List<LatLng> corns = [];
  CameraFit iCorns =
      CameraFit.coordinates(coordinates: [LatLng(0.0, 0.0), LatLng(0.0, 0.0)]);

  List<dynamic> inArgs = [];
  List<dynamic> startArgs = [];
  List<dynamic> statsArgs = [];
  List<dynamic> stopsArgs = [];

  LatLng hPoint = LatLng(0.0, 0.0);
  double lZoom = 10.0;

  List<LatLng> wPoints = [];
  List<Marker> nMarkers = [];

  double orsFontSize = 20;
  double orsFontSizeT = 20 * 1.2;
  double orsFontSizeS = 20 * 0.8;
  double orsIconSize = 30;
  bool fMini = false;

  String myDuration = "0:00:00";
  String requestUtc = "";
  String startAddress = "no start address";
  String stationAddress = "no station address";
  bool inArgsNotDone = true;

  MapController myMapController = MapController();
  TextEditingController keyEditingController = TextEditingController();

  List<DropdownMenuItem<String>> dropItems = [];

  final myProfiles = {
    'drivingCar': 0,
    'drivingHgv': 1,
    'cyclingRoad': 2,
    'cyclingMountain': 3,
    'cyclingElectric': 4,
    'footWalking': 5,
    'footHiking': 6,
    'wheelchair': 7
  };

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

  void fillDropItems() {
    dropItems.clear();

    dropItems.add(DropdownMenuItem<String>(
      value: 'drivingCar',
      child: Text('Drive', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'drivingHgv',
      child: Text('Heavy', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'cyclingRoad',
      child: Text('Cycle', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'cyclingElectric',
      child: Text('E-cycle', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'cyclingMountain',
      child: Text('M-cycle', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'footHiking',
      child: Text('Hike', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'footWalking',
      child: Text('Walk', style: TextStyle(fontSize: orsFontSizeS)),
    ));
    dropItems.add(DropdownMenuItem<String>(
      value: 'wheelchair',
      child: Text('Wheel', style: TextStyle(fontSize: orsFontSizeS)),
    ));
  }

  void doSnack(String snackText) {
    double sWidth = orsFontSizeS * 25;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'dismiss',
          onPressed: () {},
        ),
        content: Text(snackText,
            style: TextStyle(
              fontSize: orsFontSize,
              backgroundColor: Colors.grey[100]!,
              color: Colors.black,
            )),
        duration: const Duration(milliseconds: 19500),
        width: sWidth,
        padding: const EdgeInsets.all(15),
      ),
    );
  }

  void zoomIn() {
    MapCamera myMapCamera = myMapController.camera;
    LatLng centNow = myMapCamera.center;
    double zoomNow = myMapCamera.zoom;
    double zoo = zoomNow + 1.0;
    myMapController.move(centNow, zoo);
  }

  void zoomOut() {
    MapCamera myMapCamera = myMapController.camera;
    LatLng centNow = myMapCamera.center;
    double zoomNow = myMapCamera.zoom;
    double zoo = zoomNow - 1.0;
    myMapController.move(centNow, zoo);
  }

  double fitNewZoom(MapCamera camera, LatLngBounds bounds, EdgeInsets padding) {
    final paddingTL = Point<double>(padding.left, padding.top);
    final paddingBR = Point<double>(padding.right, padding.bottom);
    final paddingTotalXY = paddingTL + paddingBR;

    final cameraSize = camera.nonRotatedSize - paddingTotalXY;

    final projectedBoundsSize = Bounds(
      camera.project(bounds.southEast, camera.zoom),
      camera.project(bounds.northWest, camera.zoom),
    ).size;

    double scalex = projectedBoundsSize.x / cameraSize.x;
    double scaley = projectedBoundsSize.y / cameraSize.y;

    var scalexy = max(scalex, scaley);

    var newZoom = camera.getScaleZoom(1.0 / scalexy);

    newZoom = newZoom.floorToDouble();

    return newZoom;
  }

  LatLng getCenter(MapCamera camera, LatLngBounds bounds, double newZoom,
      EdgeInsets padding) {
    final paddingTL = Point<double>(padding.left, padding.top);
    final paddingBR = Point<double>(padding.right, padding.bottom);
    final paddingOffset = (paddingBR - paddingTL) / 2;

    final swPoint = camera.project(bounds.southWest, newZoom);
    final nePoint = camera.project(bounds.northEast, newZoom);
    final projectedCenter = (swPoint + nePoint) / 2 + paddingOffset;
    final newCenter = camera.unproject(projectedCenter, newZoom);

    return newCenter;
  }

  void doBounds(LatLng corn1, LatLng corn2) {
    MapCamera myMapCamera = myMapController.camera;
    LatLngBounds bounds = LatLngBounds.fromPoints([corn1, corn2]);
    EdgeInsets edgeIn = EdgeInsets.all(1.0);

    double zoo = fitNewZoom(myMapCamera, bounds, edgeIn);
    LatLng nCenter = getCenter(myMapCamera, bounds, zoo, edgeIn);

    myMapController.move(nCenter, zoo);
  }

  void doDir() async {
    await directions();

    setState(() {});
  }

  List<dynamic> fillArgs(int count, List<dynamic> iArgs) {
    List<dynamic> fArgs = [];

    for (var i = 0; i < count; i++) {
      fArgs.add(iArgs[i]);
    }

    return fArgs;
  }

  go_start() {
    Navigator.pushNamed(context, 'StartPage', arguments: startArgs);
  }

  go_stations() {
    Navigator.pushNamed(context, 'StationsPage', arguments: statsArgs);
  }

  go_stops() {
    stopsArgs.add(myDuration);

    Navigator.pushNamed(context, 'StopsPage', arguments: stopsArgs);
  }

  OpenRouteService connectToORS(ORSProfile cProf) {
    OpenRouteService nclient = OpenRouteService(apiKey: orsKey, profile: cProf);

    return (nclient);
  }

  Future<void> directions() async {
    int mprof = myProfiles[dropDownProfile]!;
    ORSProfile oprof = ORSProfile.values[mprof];

    OpenRouteService mclient = connectToORS(oprof);

    List<ORSCoordinate> waypoints = [];

    waypoints.add(
        ORSCoordinate(latitude: sPoint.latitude, longitude: sPoint.longitude));
    waypoints.add(
        ORSCoordinate(latitude: ePoint.latitude, longitude: ePoint.longitude));

    await fetchRoute(waypoints, mclient);
  }

  Future<void> fetchRoute(
      List<ORSCoordinate> waypoints, OpenRouteService client) async {
    try {
      final GeoJsonFeatureCollection dirs =
          await client.directionsMultiRouteGeoJsonPost(coordinates: waypoints);

      Map dirMap = dirs.toJson();
      Map dirFeat = dirMap['features'][0];
      Map dirSumm = dirFeat['properties']['summary'];

      List routeCoords = dirFeat['geometry']['coordinates'][0];

      List<ORSCoordinate> dirBbox = dirs.bbox;

      LatLng corn1 = LatLng(dirBbox[0].latitude, dirBbox[0].longitude);
      LatLng corn2 = LatLng(dirBbox[1].latitude, dirBbox[1].longitude);

      int routeCoordsLength = routeCoords.length;

      if (routeCoordsLength < 2) {
        corn1 =
            LatLng(dirBbox[0].latitude - 0.001, dirBbox[0].longitude - 0.001);
        corn2 =
            LatLng(dirBbox[1].latitude + 0.001, dirBbox[1].longitude + 0.001);
      }

      doBounds(corn1, corn2);

      dirLine.clear();

      if (routeCoordsLength > 1) {
        for (final coord in routeCoords) {
          dirLine.add(LatLng(coord[1], coord[0]));
        }
      } else {
        double sPLat = sPoint.latitude + 0.00001;
        double sPLng = sPoint.longitude + 0.00001;
        double ePLat = ePoint.latitude - 0.00001;
        double ePLng = ePoint.longitude - 0.00001;

        LatLng snPoint = LatLng(sPLat, sPLng);
        LatLng enPoint = LatLng(ePLat, ePLng);

        dirLine.add(snPoint);
        dirLine.add(sPoint);
        dirLine.add(enPoint);
      }

      int dirSummLength = dirSumm.length;
      String myDistance = "0.0";
      String myArrival = "";

      if (dirSummLength > 0) {
        myDistance = distToStr(dirSumm['distance']);
        myDuration = durToStr(dirSumm['duration']);
        myArrival = arrival(dirSumm['duration']);
      }

      String desca = startAddress +
          "\n -> \n" +
          stationAddress +
          "\n" +
          myDistance +
          " km \n" +
          myDuration +
          " hours \n" +
          "Ankunft : " +
          myArrival;

      doSnack(desca);
    } on ORSException catch (e) {
      String es = e.toString();
      int iStatus = es.indexOf("Status");
      int iCode = es.indexOf("Code");
      String mess = es.substring(iStatus, iCode);
    }
  }

  String arrival(double duration) {
    String reqUtc = requestUtc.replaceFirst("T", " ");
    DateTime reqDTUtc = DateTime.parse(reqUtc);
    DateTime reqDTLoc = reqDTUtc.toLocal();

    int durat = duration.toInt();
    Duration dDur = Duration(seconds: durat);

    DateTime dtArriv = reqDTLoc.add(dDur);

    int dHour = dtArriv.hour;
    int dMin = dtArriv.minute;

    String sHour = dHour.toString();
    String sMin = dMin.toString();

    if (dMin < 10) {
      sMin = "0" + sMin;
    }

    String arriv = sHour + ":" + sMin;

    return (arriv);
  }

  String durToStr(double duration) {
    int durat = duration.toInt();
    Duration dDur = Duration(seconds: durat);
    int dHour = dDur.inHours;
    int dMin = dDur.inMinutes - dHour * 60;
    int dSec = dDur.inSeconds - dHour * 3600 - dMin * 60;

    String sHour = dHour.toString();
    String sMin = dMin.toString();
    String sSec = dSec.toString();

    if (dMin < 10) {
      sMin = "0" + sMin;
    }

    if (dSec < 10) {
      sSec = "0" + sSec;
    }

    String sDur = sHour + ":" + sMin + ":" + sSec;

    return (sDur);
  }

  String distToStr(double distance) {
    int kDist = distance ~/ 1000.0;
    int mDist = distance.toInt() - kDist * 1000;

    String skDist = kDist.toString();
    String smDist = mDist.toString();

    if (mDist < 10) {
      smDist = "0" + smDist;
    }

    String kmDist = skDist + "." + smDist;

    return (kmDist);
  }

  @override
  Widget build(BuildContext context) {
    final iroute = ModalRoute.of(context);
    final isett = iroute!.settings;

    if (inArgsNotDone) {
      if (isett.arguments != null) {
        final List inArgs = (isett.arguments) as List;

//      print("inArgs in ors " + inArgs.toString() + "\n");

        stopsArgs = fillArgs(12, inArgs);
        statsArgs = fillArgs(7, inArgs);
        startArgs = fillArgs(7, inArgs);

        requestUtc = inArgs[0];

        sPoint = LatLng(double.parse(inArgs[1]), double.parse(inArgs[2]));
        ePoint = LatLng(double.parse(inArgs[10]), double.parse(inArgs[11]));

        double minlat = sPoint.latitude - 0.001;
        double minlong = sPoint.longitude - 0.001;
        double maxlat = sPoint.latitude + 0.001;
        double maxlong = sPoint.longitude + 0.001;

        if (ePoint.latitude < minlat) {
          minlat = ePoint.latitude - 0.001;
        }

        if (ePoint.latitude > maxlat) {
          maxlat = ePoint.latitude + 0.001;
        }

        if (ePoint.longitude < minlong) {
          minlong = ePoint.longitude - 0.001;
        }

        if (ePoint.longitude > maxlong) {
          maxlong = ePoint.longitude + 0.001;
        }

        LatLng corn1 = LatLng(minlat - 0.005, minlong - 0.005);
        LatLng corn2 = LatLng(maxlat + 0.005, maxlong + 0.005);

        corns.add(corn1);
        corns.add(corn2);

        iCorns = CameraFit.coordinates(coordinates: corns);

        startAddress = inArgs[6];
        stationAddress = inArgs[12];
      }
      inArgsNotDone = false;
    }

    Size size = MediaQuery.sizeOf(context);

    if (size.shortestSide < 700) {
      orsFontSize = 15;
      orsFontSizeT = 15 * 1.2;
      orsFontSizeS = 15 * 0.8;
      orsIconSize = 25;
      fMini = true;
    }

    fillDropItems();

    appTitle = 'Lageplan';
    urlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

    var circles = rPoints.map((latlng) {
      return CircleMarker(
        radius: 5.0,
        point: latlng,
        color: Colors.deepOrange,
      );
    }).toList();

    circles.add(CircleMarker(
      radius: 8.0,
      point: sPoint,
      color: Colors.transparent,
      borderColor: Colors.green,
      borderStrokeWidth: 4.0,
    ));

    circles.add(CircleMarker(
      radius: 8.0,
      point: ePoint,
      color: Colors.transparent,
      borderColor: Colors.red,
      borderStrokeWidth: 4.0,
    ));

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
          title: Text(appTitle, style: TextStyle(fontSize: orsFontSizeT)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal[400],
          actions: <Widget>[
            DropdownButton<String>(
              value: dropDownProfile,
              icon: Icon(Icons.arrow_downward,
                  color: Colors.black, size: orsIconSize),
              iconEnabledColor: Colors.black,
              elevation: 0,
              style: TextStyle(fontSize: orsFontSize, color: Colors.black),
              dropdownColor: Colors.teal[200],
              underline: Container(
                height: 2,
                color: Colors.teal[800],
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropDownProfile = newValue!;
                });
              },
              items: dropItems,
            ),
            IconButton(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 50.0),
              onPressed: () {
                doDir();
              },
              icon: Icon(Icons.route, size: orsIconSize, color: Colors.black),
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
            ),
            Flexible(
              child: FlutterMap(
                mapController: myMapController,
                options: MapOptions(
                  initialCameraFit: iCorns,
                  interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all &
                          ~InteractiveFlag.rotate &
                          ~InteractiveFlag.pinchMove &
                          ~InteractiveFlag.doubleTapDragZoom &
                          ~InteractiveFlag.flingAnimation),
                ),
                children: [
                  TileLayer(
                    urlTemplate: urlTemplate,
                    tileProvider: NetworkTileProvider(),
                  ),
                  CircleLayer(circles: circles),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: dirLine,
                        strokeWidth: 4.0,
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(5),
              child: FloatingActionButton(
                onPressed: zoomIn,
                backgroundColor: Colors.blueAccent,
                heroTag: null,
                mini: fMini,
                child: Icon(Icons.zoom_out_map_outlined, size: orsIconSize),
              )),
          Container(
              margin: const EdgeInsets.all(5),
              child: FloatingActionButton(
                onPressed: zoomOut,
                backgroundColor: Colors.blueAccent,
                heroTag: null,
                mini: fMini,
                child: Icon(Icons.zoom_in_map_outlined, size: orsIconSize),
              )),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal[400],
        height: 70.0,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.west, size: orsIconSize),
              color: Colors.lightGreenAccent,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_stops();
              },
            ),
            IconButton(
              icon: Icon(Icons.trip_origin, size: orsIconSize),
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_start();
              },
            ),
            IconButton(
              icon: Icon(Icons.store, size: orsIconSize),
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_stations();
              },
            ),
            IconButton(
              icon: Icon(Icons.departure_board, size: orsIconSize),
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_stops();
              },
            ),
          ],
        ),
      ),
    );
  }
}
