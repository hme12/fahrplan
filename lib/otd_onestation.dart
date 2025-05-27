import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:core';

import './otd_header.dart';
import './functions.dart';

String myOneStationRequestString(
    String requestTime, String requestId, String requestName) {
  String sRTime = requestTime;

  String requestor = 'He';
  String msgId = '001';

  String r01 =
      '<?xml version="1.0" encoding="UTF-8"?> <OJP xmlns="http://www.vdv.de/ojp" xmlns:siri="http://www.siri.org.uk/siri" version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vdv.de/ojp ../../../../Downloads/OJP-changes_for_v1.1%20(1)/OJP-changes_for_v1.1/OJP.xsd"> <OJPRequest> <siri:ServiceRequest> <siri:RequestTimestamp>';

  String r02 = '</siri:RequestTimestamp> <siri:RequestorRef>';

  String r03 =
      '</siri:RequestorRef> <OJPLocationInformationRequest> <siri:RequestTimestamp>';

  String r04 = '</siri:RequestTimestamp> <siri:MessageIdentifier>';

  String r05 =
      '</siri:MessageIdentifier> <InitialInput> <PlaceRef><StopPlaceRef>';
  String r06 = '</StopPlaceRef>';
  String r07 = '</PlaceRef><Name>';
  String r08 = '</Name></InitialInput> ';
  String r09 =
      '<Restrictions><Type>stop</Type> <NumberOfResults>5</NumberOfResults></Restrictions>';

  String r10 =
      '</OJPLocationInformationRequest> </siri:ServiceRequest> </OJPRequest> </OJP>';

  String request = r01 +
      requestTime +
      r02 +
      requestor +
      r03 +
      sRTime +
      r04 +
      msgId +
      r05 +
      requestId +
      r06 +
      r07 +
      requestName +
      r08 +
      r09 +
      r10;

  return request;
}

Future<String> myOneStationRequestF(
    String reqTime, String reqId, String reqName) async {
  final url = Uri.parse('https://api.opentransportdata.swiss/ojp20');

  Map<String, String> header = myHeader();

  String stationsRequest = myOneStationRequestString(reqTime, reqId, reqName);

  var stationsResponse =
      await http.post(url, headers: header, body: stationsRequest);

  final List<int> stationsResponseBytes = stationsResponse.bodyBytes;

  var stationsResponseBody = utf8.decode(stationsResponseBytes);

  final stationsResponseXml = XmlDocument.parse(stationsResponseBody);

  final allStations = stationsResponseXml.findAllElements('PlaceResult');

  String theStation = "";
  String theStationP = "";
  bool notFound = true;
  double maxProb = 0.0;

  for (var oneStation in allStations) {
    final stopPlaceRef = oneStation.findAllElements('StopPlaceRef');
    String stopPlaceRefText = myInnerText(stopPlaceRef);

    final privCode = oneStation.findAllElements('PrivateCode');
    String privCodeText = myInnerText(privCode);

    final topoRef = oneStation.findAllElements('TopographicPlaceRef');
    String topoRefText = myInnerText(topoRef);

    final stopPlaceName = oneStation.findAllElements('StopPlaceName');
    String stopPlaceNameText = myInnerText(stopPlaceName);

    final stopName = oneStation.findAllElements('Name');
    String stopNameText = myInnerText(stopName);

    final geoPos = oneStation.findAllElements('GeoPosition');
    String geoPosText = myInnerText(geoPos);

    final geoLong = oneStation.findAllElements('siri:Longitude');
    String geoLongText = myInnerText(geoLong);

    final geoLat = oneStation.findAllElements('siri:Latitude');
    String geoLatText = myInnerText(geoLat);

    final compl = oneStation.findAllElements('Complete');
    String complText = myInnerText(compl);

    final prob = oneStation.findAllElements('Probability');
    String probText = myInnerText(prob);

    final ptMode = oneStation.findAllElements('PtMode');
    String ptModeText = myInnerText(ptMode);

    final subMode = oneStation.findAllElements('siri:BusSubmode');
    String subModeText = myInnerText(subMode);

    double probability = double.parse(probText);

    if (probability > maxProb) {
      theStationP = stopPlaceRefText +
          "|" +
          stopPlaceNameText +
          "|" +
          geoLatText +
          "|" +
          geoLongText;

      maxProb = probability;
    }

    if (reqId == stopPlaceRefText) {
      theStation = stopPlaceRefText +
          "|" +
          stopPlaceNameText +
          "|" +
          geoLatText +
          "|" +
          geoLongText;

      notFound = false;
    }
  }

  if (notFound) {
    theStation = theStationP;
  }

  return theStation;
}
