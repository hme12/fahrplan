import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:core';

import './otd_header_form.dart';
import './functions.dart';

String myFormationRequestString(String evu, String trainNumber, String opDay) {
  String baseUrl = 'https://api.opentransportdata.swiss/formation/v2/';

  String stopBased = 'formations_stop_based';
  String vehicleBased = 'formations_vehicle_based';
  String fullBased = 'formations_full';

  String req1 = baseUrl;

  String req2 = stopBased;

  String req3 = '?evu=';

  String req4 = '&operationDate=';

  String req5 = '&trainNumber=';

  String request = req1 + req2 + req3 + evu + req4 + opDay + req5 + trainNumber;

  return request;
}

Future<List> myFormationRequestF(
    String jRef, String trainNumber, String opDay) async {
  List<String> jRefItems = jRef.split(":");
  String jEvu = jRefItems[3];

  String evu = wEvu (jRef);

// evu:
//
// BLSP    015
// SBBP    001
// MBC     012
// OeBB    049
// RhB     053
// SOB     061
// THURBO  046
// TPF     034
// TRN     025
// VDDB
// ZB      064

  Map<String, String> header = myFormHeader();

  String formationRequest = myFormationRequestString(evu, trainNumber, opDay);

  final requestUrl = Uri.parse(formationRequest);

//  print (requestUrl.toString());

  var formationResponse = await http.get(requestUrl, headers: header);

  int formationResponseStatus = formationResponse.statusCode;

//  print("Code " + formationResponseStatus.toString());

  var theForms = [];

  if (evu == "nA") {
    evu = "-";
  }

  if (evu == "SBBP") {
    evu = "SBB";
  }

  if (evu == "BLSP") {
    evu = "BLS";
  }

  if (formationResponseStatus == 200) {
    theForms.add(trainNumber);

    final List<int> formationResponseBytes = formationResponse.bodyBytes;

    var formationResponseBody = utf8.decode(formationResponseBytes);

    var formationResponseJson = jsonDecode(formationResponseBody);

//    print (formationResponseJson.toString());

//  for (var fKey in formationResponseJson.keys) {
//    print (fKey.toString());
//    print (" ");
//    print (formationResponseJson[fKey].toString());
//    print ("--------------");
//    print (" ");
//  }

    var theForm = {};

    var g1 = formationResponseJson["formationsAtScheduledStops"];

    for (var g4 in g1) {
      var g5 = g4["scheduledStop"];

      var g8 = g5["stopPoint"];
      String g9 = g8["uic"].toString();
//    print (g9.toString());
      String g10 = g8["name"];
//    print (g10.toString());

      var g6 = g4["formationShort"];
//      print (g6.toString());
      var g7 = g6["formationShortString"];
//      print (g7.toString());

      if (g7 != null) {
        String clForm = cleanFormation(g7);

        theForm[jRef + g9] = g9 + "|" + g10 + "|<- " + g7 + "|<- " + clForm + "|" + evu;
      } else {
        theForm[jRef + g9] = g9 + "|" + g10 + "|<- " + "|<- " + "|" + evu;
      }
    }

    theForms.add(theForm);

//    print(theForms.toString());
//    print(" ----------------------- ");
  } else {
    theForms.add("0");
  }

  return theForms;
}
