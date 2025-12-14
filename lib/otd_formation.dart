import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

import './otd_header_form.dart';
import './functions.dart';

String myFormationRequestString(String evu, String trainNumber, String opDay) {
  String baseUrl = 'https://api.opentransportdata.swiss/formation/v2/';

  String stopBased = 'formations_stop_based';
//  String vehicleBased = 'formations_vehicle_based';
//  String fullBased = 'formations_full';

  String req1 = baseUrl;

  String req2 = stopBased;

  String req3 = '?evu=';

  String req4 = '&operationDate=';

  String req5 = '&trainNumber=';

  String request = req1 + req2 + req3 + evu + req4 + opDay + req5 + trainNumber;

  return request;
}

Future<List> myFormationRequestF(
  String jRef,
  String trainNumber,
  String opDay,
) async {
  String evu = wEvu(jRef);

  var theForms = [];

  //  if ((evu != "nA") && (evu != "RhB")) {
  if (evu != "nA") {
    Map<String, String> header = myFormHeader();

    String formationRequest = myFormationRequestString(evu, trainNumber, opDay);

    final requestUrl = Uri.parse(formationRequest);

    var formationResponse = await http.get(requestUrl, headers: header);

    int formationResponseStatus = formationResponse.statusCode;

    if (formationResponseStatus == 200) {
      theForms.add(trainNumber);

      final List<int> formationResponseBytes = formationResponse.bodyBytes;

      var formationResponseBody = utf8.decode(formationResponseBytes);

      var formationResponseJson = jsonDecode(formationResponseBody);

      var theForm = {};

      var g1 = formationResponseJson["formationsAtScheduledStops"];

      for (var g4 in g1) {
        var g5 = g4["scheduledStop"];

        var g8 = g5["stopPoint"];
        String g9 = g8["uic"].toString();
        String g10 = g8["name"];

        var g6 = g4["formationShort"];
        var g7 = g6["formationShortString"];

        if (g7 != null) {
          String clForm = cleanFormation(g7);

          theForm[jRef + g9] = g9 + "|" + g10 + "|<- " + g7 + "|<- " + clForm;
        } else {
          theForm[jRef + g9] = g9 + "|" + g10 + "|<- " + "|<- ";
        }
      }

      theForms.add(theForm);
    } else {
      theForms.add("0");
    }
  } else {
    theForms.add("0");
  }

  return theForms;
}
