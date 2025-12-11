import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'def_coords.dart';
import 'map_urls.dart';

class OsMapPage extends StatefulWidget {
  const OsMapPage({super.key});

  @override
  OsMapPageState createState() => OsMapPageState();
}

class OsMapPageState extends State<OsMapPage> {
  String appTitle = 'Start';
  String userAgent = 'my.agent';

  List<dynamic> inArgs = [];
  List<dynamic> startArgs = [];

  String hereLats = "";
  String hereLongs = "";
  LatLng hereLatLong = LatLng(0.0, 0.0);

  String startLats = "no latitude";
  String startLongs = "no longitude";
  String tappedAddress = "no address";
  LatLng startLatLong = LatLng(0.0, 0.0);

  bool mapNotTapped = true;
  bool inArgsNotDone = true;

  List<LatLng> rPoints = [];
  List<LatLng> corns = [];
  CameraFit iCorns = CameraFit.coordinates(
    coordinates: [LatLng(0.0, 0.0), LatLng(0.0, 0.0)],
  );

  double osFontSize = 20;
  double osFontSizeT = 20 * 1.2;
  double osFontSizeS = 20 * 0.8;
  double osIconSize = 30;
  bool fMini = false;
  int swUrl = 1;
  String urlTemplate = urlSwissG;

  MapController myMapController = MapController();

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

  void doSnack(String snackText) {
    double sWidth = osFontSizeS * 25;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(label: 'dismiss', onPressed: () {}),
        content: Text(
          snackText,
          style: TextStyle(
            fontSize: osFontSize,
            backgroundColor: Colors.grey[100]!,
            color: Colors.black,
          ),
        ),
        duration: const Duration(milliseconds: 19500),
        width: sWidth,
        padding: const EdgeInsets.all(15),
      ),
    );
  }

  void showOsm() {
    setState(() {
      urlTemplate = urlOSM;
    });
  }

  void showSwiss() {
    String urlSw = urlSwissG;

    if (swUrl == 1) {
      urlSw = urlSwiss;
      swUrl = 2;
    } else if (swUrl == 2) {
      urlSw = urlSwissI;
      swUrl = 3;
    } else if (swUrl == 3) {
      urlSw = urlSwissG;
      swUrl = 1;
    }

    setState(() {
      urlTemplate = urlSw;
    });
  }

  void showEsri() {
    setState(() {
      urlTemplate = urlEsri;
    });
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

  void doReset() {
    setState(() {
      rPoints.clear();
    });
  }

  void fromStart() {
    startLatLong = hereLatLong;
    mapNotTapped = true;

    setState(() {
      rPoints.clear();
      rPoints.add(startLatLong);

      LatLng corn1 = LatLng(
        startLatLong.latitude - 0.01,
        startLatLong.longitude - 0.01,
      );
      LatLng corn2 = LatLng(
        startLatLong.latitude + 0.01,
        startLatLong.longitude + 0.01,
      );

      corns.add(corn1);
      corns.add(corn2);

      iCorns = CameraFit.coordinates(coordinates: corns);

      bool fitted = myMapController.fitCamera(iCorns);

      String snackPoint =
          "Lat. : " +
          startLatLong.latitude.toStringAsFixed(6) +
          "\nLng. : " +
          startLatLong.longitude.toStringAsFixed(6);

      doSnack(snackPoint);
    });
  }

  void mapTapped(pos, LatLng pnt) {
    startLatLong = pnt;
    mapNotTapped = false;

    setState(() {
      rPoints.clear();
      rPoints.add(startLatLong);

      String snackPoint =
          "Lat. : " +
          startLatLong.latitude.toStringAsFixed(6) +
          "\nLng. : " +
          startLatLong.longitude.toStringAsFixed(6);

      doSnack(snackPoint);
    });
  }

  go_start() {
    if (mapNotTapped) {
      startArgs.add(hereLatLong.latitude.toString());
      startArgs.add(hereLatLong.longitude.toString());
    } else {
      startArgs.add(startLatLong.latitude.toString());
      startArgs.add(startLatLong.longitude.toString());
    }
    Navigator.pushNamed(context, 'StartPage', arguments: startArgs);
  }

  List<dynamic> fillArgs(int count, List<dynamic> iArgs) {
    List<dynamic> fArgs = [];

    for (var i = 0; i < count; i++) {
      fArgs.add(iArgs[i]);
    }

    return fArgs;
  }

  @override
  Widget build(BuildContext context) {
    final iroute = ModalRoute.of(context);
    final isett = iroute!.settings;

    if (inArgsNotDone) {
      final List inArgs = (isett.arguments) as List;

      startArgs = fillArgs(7, inArgs);

      hereLats = inArgs[1];
      hereLongs = inArgs[2];

      if (hereLats.contains("no")) {
        hereLats = defLatitude.toString();
      }

      if (hereLongs.contains("no")) {
        hereLongs = defLongitude.toString();
      }

      double hereLat = double.parse(hereLats);
      double hereLong = double.parse(hereLongs);

      hereLatLong = LatLng(hereLat, hereLong);

      if (mapNotTapped) {
        rPoints.clear();
        rPoints.add(hereLatLong);

        LatLng corn1 = LatLng(
          hereLatLong.latitude - 0.01,
          hereLatLong.longitude - 0.01,
        );
        LatLng corn2 = LatLng(
          hereLatLong.latitude + 0.01,
          hereLatLong.longitude + 0.01,
        );

        corns.add(corn1);
        corns.add(corn2);

        iCorns = CameraFit.coordinates(coordinates: corns);

        inArgsNotDone = false;
      }
    }

    final mediaQueryData = MediaQuery.of(context);

    osFontSize = 20;
    osFontSizeT = 20 * 1.2;
    osFontSizeS = 20 * 0.8;
    osIconSize = 30;
    fMini = false;

    if (mediaQueryData.size.shortestSide < 700) {
      osFontSize = 15;
      osFontSizeT = 15 * 1.2;
      osFontSizeS = 15 * 0.8;
      osIconSize = 25;
      fMini = true;
    }

    var circles = rPoints.map((latlng) {
      return CircleMarker(radius: 8.0, point: latlng, color: Colors.pinkAccent);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text(appTitle, style: TextStyle(fontSize: osFontSizeT)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal[400],
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.volcano_outlined),
            onPressed: () {
              showSwiss();
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              showOsm();
            },
          ),
          IconButton(
            icon: const Icon(Icons.language_outlined),
            onPressed: () {
              showEsri();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(1.0)),
            Flexible(
              child: FlutterMap(
                mapController: myMapController,
                options: MapOptions(
                  initialCameraFit: iCorns,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.all &
                        ~InteractiveFlag.rotate &
                        ~InteractiveFlag.pinchMove &
                        ~InteractiveFlag.doubleTapDragZoom &
                        ~InteractiveFlag.flingAnimation,
                  ),
                  onTap: (tapPosition, point) {
                    mapTapped(tapPosition, point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: urlTemplate,
                    userAgentPackageName: userAgent,
                    tileProvider: NetworkTileProvider(),
                  ),
                  CircleLayer(circles: circles),
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
              child: Icon(Icons.zoom_out_map_outlined, size: osIconSize),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: zoomOut,
              backgroundColor: Colors.blueAccent,
              heroTag: null,
              mini: fMini,
              child: Icon(Icons.zoom_in_map_outlined, size: osIconSize),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal[400],
        height: 70.0,
        child: Row(
          //          spacing: 15.0,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.west, size: osIconSize),
              color: Colors.lightGreenAccent,
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                go_start();
              },
            ),
            IconButton(
              icon: Icon(Icons.undo_outlined, size: osIconSize),
              color: Colors.red[800],
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              onPressed: () {
                fromStart();
              },
            ),
          ],
        ),
      ),
    );
  }
}
