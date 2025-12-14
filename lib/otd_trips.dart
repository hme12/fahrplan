import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:core';

import './otd_header.dart';
import './otd_formation.dart';
import './functions.dart';

String myTripRequestString(String requestTime, String jRef, String opDay) {
  String sRTime = requestTime;

  String rref = 'He';
  String mident = '002';

  String req1 =
      '<?xml version="1.0" encoding="UTF-8"?> <OJP version="2.0" xsi:schemaLocation="http://www.vdv.de/ojp OJP_changes_for_v1.1/OJP.xsd" xmlns="http://www.vdv.de/ojp" xmlns:siri="http://www.siri.org.uk/siri" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <OJPRequest> <siri:ServiceRequest> <siri:RequestTimestamp>';

  String req2 = '</siri:RequestTimestamp> <siri:RequestorRef>';

  String req3 =
      '</siri:RequestorRef> <OJPTripInfoRequest> <siri:RequestTimestamp>';

  String req4 = '</siri:RequestTimestamp> <siri:MessageIdentifier>';

  String req5 = '</siri:MessageIdentifier> <JourneyRef>';

  String req6 = '</JourneyRef> <OperatingDayRef>';

  String req7 =
      '</OperatingDayRef> </OJPTripInfoRequest> </siri:ServiceRequest> </OJPRequest> </OJP>';

  String request =
      req1 +
      requestTime +
      req2 +
      rref +
      req3 +
      sRTime +
      req4 +
      mident +
      req5 +
      jRef +
      req6 +
      opDay +
      req7;

  return request;
}

Future<List> myTripRequestF(
  String requestTime,
  String jRef,
  String opDay,
) async {
  String thisDTimeString0 = "";
  String thisDTimeString1 = "";

  String thisATimeString0 = "";
  String thisATimeString1 = "";

  var theFormation = [];
  var theFormationMap = {};
  bool gotFormation = false;

  final url = Uri.parse('https://api.opentransportdata.swiss/ojp20');

  Map<String, String> header = myHeader();

  String tripRequest = myTripRequestString(requestTime, jRef, opDay);

  var tripResponse = await http.post(url, headers: header, body: tripRequest);

  final List<int> tripResponseBytes = tripResponse.bodyBytes;

  if (tripResponseBytes.isEmpty) {
    var noCalls = [];
    noCalls.add("0");
    return (noCalls);
  } 

  var pTripResponseBody = utf8.decode(tripResponseBytes);
  var oTripResponseBody = utf8.decode(tripResponseBytes);

  final pTripResponseXml = XmlDocument.parse(pTripResponseBody);
  final oTripResponseXml = XmlDocument.parse(oTripResponseBody);

  final prevCalls = pTripResponseXml.findAllElements('PreviousCall');
  final onwCalls = oTripResponseXml.findAllElements('OnwardCall');
  final tripService = oTripResponseXml.findAllElements('Service');

  String tripServiceStr = tripService.toString();
  final tripServices = XmlDocument.parse(tripServiceStr);
  final trainNumber = tripServices.findAllElements('TrainNumber');
  String trainNumberText = myInnerText(trainNumber);

  theFormation = await myFormationRequestF(jRef, trainNumberText, opDay);

  String theFormationNumber = theFormation[0];

  if (theFormationNumber != "0") {
    theFormationMap = theFormation[1];
    gotFormation = true;
  }

  List<String> allCalls = [];

  for (var prevCall in prevCalls) {
    String prevCallString = prevCall.toString();

    allCalls.add(prevCallString);
  }

  for (var onwCall in onwCalls) {
    String onwCallString = onwCall.toString();

    allCalls.add(onwCallString);
  }

  var theCalls = [];
  var theCall = {};

  String PrevOnwText = "";

  theCalls.add(trainNumberText);

  for (var oneCallS in allCalls) {
    final oneCall = XmlDocument.parse(oneCallS);
    String oneCallString = oneCall.toString();

    if (oneCallString.contains("PreviousCall")) {
      PrevOnwText = "P";
    }

    if (oneCallString.contains("OnwardCall")) {
      PrevOnwText = "O";
    }

    final StopPointRef = oneCall.findAllElements('siri:StopPointRef');
    String StopPointRefText0 = myInnerText(StopPointRef);
    String StopPointRefText = StopPointRefText0;

    final StopPointName = oneCall.findAllElements('StopPointName');
    String StopPointNameTextk = myInnerText(StopPointName);
    String StopPointNameText = StopPointNameTextk.replaceAll(",", "");

    List<String> bDepTimes = [];
    List<String> bArrTimes = [];

    if (oneCallString.contains("ServiceDeparture")) {
      final sDeparture = oneCall.findAllElements('ServiceDeparture');

      bDepTimes = myInnerText2(sDeparture);
    }

    if (oneCall.toString().contains("ServiceArrival")) {
      final sArrival = oneCall.findAllElements('ServiceArrival');

      bArrTimes = myInnerText2(sArrival);
    }

    thisDTimeString0 = "";
    thisDTimeString1 = "";

    if (bDepTimes.length > 0) {
      thisDTimeString0 = bDepTimes[0];
      thisDTimeString1 = bDepTimes[1];
    }

    thisATimeString0 = "";
    thisATimeString1 = "";

    if (bArrTimes.length > 0) {
      thisATimeString0 = bArrTimes[0];
      thisATimeString1 = bArrTimes[1];
    }

    final QuayNumber = oneCall.findAllElements('PlannedQuay');
    String QuayNumberText = myInnerText(QuayNumber);

    if (StopPointRefText0.contains("sloid")) {
      List<String> sloids = StopPointRefText0.split(":");
      String shortId = sloids[3];
      int shortIdI = int.parse(shortId);
      int longIdI = 8500000 + shortIdI;
      String longId = longIdI.toString();
      StopPointRefText = longId;
    } else {
      StopPointRefText = StopPointRefText0;
    }

    theCall[jRef + StopPointRefText] =
        StopPointRefText +
        "|" +
        StopPointNameText +
        "|" +
        thisDTimeString0 +
        "|" +
        thisDTimeString1 +
        "|" +
        thisATimeString0 +
        "|" +
        thisATimeString1 +
        "|" +
        QuayNumberText +
        "|" +
        PrevOnwText +
        "|" +
        StopPointRefText0;

    if (gotFormation) {
      if (theFormationMap.containsKey(jRef + StopPointRefText)) {
        List<String> thisFormation = theFormationMap[jRef + StopPointRefText]
            .split("|");
        theCall[jRef + StopPointRefText] =
            theCall[jRef + StopPointRefText] +
            "|" +
            thisFormation[2] +
            "|" +
            thisFormation[3];
      } else {
        theCall[jRef + StopPointRefText] =
            theCall[jRef + StopPointRefText] + "|-" + "|-";
      }
    } else {
      theCall[jRef + StopPointRefText] =
          theCall[jRef + StopPointRefText] + "|-" + "|-";
    }
  }

  theCalls.add(theCall);

  return theCalls;
}
