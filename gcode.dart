import 'dart:core';
import 'dart:io';

import 'package:location/location.dart';
import 'dart:io' show Platform;
import 'package:open_route_service/open_route_service.dart';

import 'ors_key.dart';
import 'def_coords.dart';

Future<List<double>> myLocationF() async {
//  double fLatitude = 46.777;
//  fLatitude = 47.36652;
//  double fLongitude = 10.1481;
//  fLongitude = 8.54095;

  List<double> defCoord = [defLatitude, defLongitude];

// Platform.isAndroid
// Platform.isFuchsia
// Platform.isIOS
// Platform.isLinux
// Platform.isMacOS
// Platform.isWindows

  if (Platform.isLinux) {
    return defCoord;
  }

  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return defCoord;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return defCoord;
    }
  }

  _locationData = await location.getLocation();

  double? latitude = _locationData.latitude;
  double? longitude = _locationData.longitude;

  List<double> here = [latitude!, longitude!];

  return here;
}

OpenRouteService connectToORS() {
  OpenRouteService nclient = OpenRouteService(apiKey: orsKey);

  return (nclient);
}

Future<String> geoCodesFT(double llat, double llong) async {
  OpenRouteService mclient = connectToORS();

  String myAddress = await fetchGCode(mclient, llat, llong);

  return (myAddress);
}

Future<String> geoCodesF(
    double llat, double llong, String lats, bool aNF, String nAdr) async {
  if (aNF) {
    if (lats.contains("latitude")) {
      return ("no address");
    } else {
      OpenRouteService mclient = connectToORS();

      String myAddress = await fetchGCode(mclient, llat, llong);

      return (myAddress);
    }
  } else {
    return (nAdr);
  }
}

Future<String> fetchGCode(
    OpenRouteService client, double startLat, double startLng) async {
  List<String> gLayers = ["address"];

  double circleRadius = 1.0;
  String sName = "";
  String sLocal = "";
  String myAddress = "";
  String sPcode = "";

  ORSCoordinate startCoord =
      ORSCoordinate(latitude: startLat, longitude: startLng);

  try {
    final GeoJsonFeatureCollection gcode = await client.geocodeReverseGet(
        point: startCoord, boundaryCircleRadius: circleRadius, layers: gLayers);

    sName = gcode.features[0].properties["name"].toString() + " - ";

    if (gcode.features[0].properties["postalcode"] != null) {
      sPcode = gcode.features[0].properties["postalcode"].toString() + " ";
    }

    if (gcode.features[0].properties["locality"] != null) {
      sLocal = gcode.features[0].properties["locality"].toString();
    }

    myAddress = sName + sLocal;
  } catch (err) {
    myAddress = "-";
  }

  return (myAddress);
}
