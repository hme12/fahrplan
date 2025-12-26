import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:core';

import './otd_header.dart';
import './functions.dart';
import './http_messages.dart';

import 'dart:collection';

String myStopsRequestString(
  String requestTime,
  String numStops,
  String stationId,
) {
  String sRTime = requestTime;

  String rref = 'He';
  String mident = '002';
  String evtype = 'both';
  String inccalls = 'false';
  String realtime = 'full';

  String req1 =
      '<?xml version="1.0" encoding="UTF-8"?> <OJP xmlns="http://www.vdv.de/ojp" xmlns:siri="http://www.siri.org.uk/siri" version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vdv.de/ojp ../../../../OJP4/OJP.xsd"> <OJPRequest> <siri:ServiceRequest> <siri:RequestTimestamp>';

  String req2 = '</siri:RequestTimestamp> <siri:RequestorRef>';

  String req3 =
      '</siri:RequestorRef> <OJPStopEventRequest> <siri:RequestTimestamp>';

  String req4 = '</siri:RequestTimestamp> <siri:MessageIdentifier>';

  String req5 =
      '</siri:MessageIdentifier> <Location> <PlaceRef> <StopPlaceRef>';

  String req6 = '</StopPlaceRef> </PlaceRef> <DepArrTime>';

  String req7 = '</DepArrTime> </Location> <Params> <NumberOfResults>';

  String req8 = '</NumberOfResults> <StopEventType>';

  String req9 = '</StopEventType> <IncludePreviousCalls>';

  String req10 = '</IncludePreviousCalls> <IncludeOnwardCalls>';

  String req11 = '</IncludeOnwardCalls> <UseRealtimeData>';

  String req12 =
      '</UseRealtimeData> </Params> </OJPStopEventRequest> </siri:ServiceRequest> </OJPRequest> </OJP>';

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
      stationId +
      req6 +
      requestTime +
      req7 +
      numStops +
      req8 +
      evtype +
      req9 +
      inccalls +
      req10 +
      inccalls +
      req11 +
      realtime +
      req12;

  return request;
}

Future<List> myStopsRequestF(
  String requestTime,
  String numStops,
  String stationId,
) async {
  String StopMode = 'Abfahrt';

  final url = Uri.parse('https://api.opentransportdata.swiss/ojp20');

  Map<String, String> header = myHeader();

  String stopsRequest = myStopsRequestString(requestTime, numStops, stationId);

  var stopsResponse = await http.post(url, headers: header, body: stopsRequest);

  int stopsResponseStatus = stopsResponse.statusCode;
  String stopsResponseStatusMessage = statusMessage(stopsResponseStatus);

  var noStops = [];

  if (stopsResponseStatus != 200) {
    String noStop =
        "E|" +
        stopsResponseStatus.toString() +
        "|" +
        stopsResponseStatusMessage;

    noStops.add(noStop);
    return noStops;
  }

  final List<int> stopsResponseBytes = stopsResponse.bodyBytes;

  var stopsResponseBody = utf8.decode(stopsResponseBytes);

  final stopsResponseXml = XmlDocument.parse(stopsResponseBody);

  final allStops = stopsResponseXml.findAllElements('StopEventResult');

  var theStops = [];
  var theStop = {};
  String EstimatedTimeText = "";
  SplayTreeMap<int, String> stopTimes = SplayTreeMap<int, String>();

  for (var oneStop in allStops) {
    String oneStopString = oneStop.toString();

    final JourneyRef = oneStop.findAllElements('JourneyRef');
    String JourneyRefText = myInnerText(JourneyRef);

    final StopPointRef = oneStop.findAllElements('siri:StopPointRef');
    String StopPointRefText = myInnerText(StopPointRef);

    final StopPointName = oneStop.findAllElements('StopPointName');
    String StopPointNameTextk = myInnerText(StopPointName);
    String StopPointNameText = StopPointNameTextk.replaceAll(",", "");

    final TimetabledTime = oneStop.findAllElements('TimetabledTime');
    String TimetabledTimeText = myInnerText(TimetabledTime);

    if (oneStopString.contains("EstimatedTime")) {
      var EstimatedTime = oneStop.findAllElements('EstimatedTime');
      EstimatedTimeText = myInnerText(EstimatedTime);
    } else {
      EstimatedTimeText = TimetabledTimeText;
    }

    if (oneStopString.contains("ServiceDeparture")) {
      StopMode = 'Abfahrt';
    }

    if (oneStopString.contains("ServiceArrival")) {
      StopMode = 'Ankunft';
    }

    final OriginStopPointRef = oneStop.findAllElements('OriginStopPointRef');
    String OriginStopPointRefText = myInnerText(OriginStopPointRef);

    final OriginText = oneStop.findAllElements('OriginText');
    String OriginTextTextk = myInnerText(OriginText);
    String OriginTextText = OriginTextTextk.replaceAll(",", "");

    final DestinationStopPointRef = oneStop.findAllElements(
      'DestinationStopPointRef',
    );
    String DestinationStopPointRefText = myInnerText(DestinationStopPointRef);

    final DestinationText = oneStop.findAllElements('DestinationText');
    String DestinationTextTextk = myInnerText(DestinationText);
    String DestinationTextText = DestinationTextTextk.replaceAll(",", "");

    final PtMode = oneStop.findAllElements('PtMode');
    String PtModeText = myInnerText(PtMode);

    final TrainNumber = oneStop.findAllElements('TrainNumber');
    String TrainNumberText = myInnerText(TrainNumber);

    final TrainName = oneStop.findAllElements('PublishedServiceName');
    String TrainNameText = myInnerText(TrainName);

    final QuayNumber = oneStop.findAllElements('PlannedQuay');
    String QuayNumberText = myInnerText(QuayNumber);

    String TtTT = TimetabledTimeText.replaceFirst("T", " ");
    DateTime DTtTT = DateTime.parse(TtTT);
    int STtTT = DTtTT.millisecondsSinceEpoch;

    if (stopTimes[STtTT] != null) {
      String sT = stopTimes[STtTT].toString();
      String nValue = sT + "|" + JourneyRefText;
      stopTimes[STtTT] = nValue;
    } else {
      stopTimes[STtTT] = JourneyRefText;
    }

    theStop[JourneyRefText] =
        JourneyRefText +
        "|" +
        StopPointRefText +
        "|" +
        StopPointNameText +
        "|" +
        TimetabledTimeText +
        "|" +
        EstimatedTimeText +
        "|" +
        StopMode +
        "|" +
        OriginStopPointRefText +
        "|" +
        OriginTextText +
        "|" +
        DestinationStopPointRefText +
        "|" +
        DestinationTextText +
        "|" +
        PtModeText +
        "|" +
        TrainNumberText +
        "|" +
        TrainNameText +
        "|" +
        QuayNumberText;
  }

  String aValue = "";

  stopTimes.forEach((key, value) {
    if (value.contains("|")) {
      List<String> aValues = value.split("|");
      for (aValue in aValues) {
        theStops.add(theStop[aValue]);
      }
    } else {
      theStops.add(theStop[value]);
    }
  });

  return theStops;
}
