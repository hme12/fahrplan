import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:core';

import './otd_header.dart';
import './functions.dart';
import './http_messages.dart';

String myStationsRequestString(
  String requestTime,
  String requestLat,
  String requestLong,
  String radius,
  String numResults,
) {
  String sRTime = requestTime;

  String exclude = 'true';
  String toExclude = 'bus';
  String requestor = 'He';
  String msgId = '001';

  String r01 =
      '<?xml version="1.0" encoding="UTF-8"?> <OJP xmlns="http://www.vdv.de/ojp" xmlns:siri="http://www.siri.org.uk/siri" version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vdv.de/ojp ../../../../Downloads/OJP-changes_for_v1.1%20(1)/OJP-changes_for_v1.1/OJP.xsd"> <OJPRequest> <siri:ServiceRequest> <siri:RequestTimestamp>';

  String r02 = '</siri:RequestTimestamp> <siri:RequestorRef>';

  String r03 =
      '</siri:RequestorRef> <OJPLocationInformationRequest> <siri:RequestTimestamp>';

  String r04 = '</siri:RequestTimestamp> <siri:MessageIdentifier>';

  String r05 =
      '</siri:MessageIdentifier> <InitialInput> <GeoRestriction> <Circle> <Center> <siri:Longitude>';

  String r06 = '</siri:Longitude> <siri:Latitude>';

  String r07 = '</siri:Latitude> </Center> <Radius>';

  String r08 =
      '</Radius> </Circle> </GeoRestriction> </InitialInput> <Restrictions> <Type>stop</Type> <NumberOfResults>';

  String r09 = '</NumberOfResults> <PtModes> <Exclude>';

  String r10 = '</Exclude> <PtMode>';

  String r11 =
      '</PtMode> </PtModes></Restrictions> </OJPLocationInformationRequest> </siri:ServiceRequest> </OJPRequest> </OJP>';

  String request =
      r01 +
      requestTime +
      r02 +
      requestor +
      r03 +
      sRTime +
      r04 +
      msgId +
      r05 +
      requestLong +
      r06 +
      requestLat +
      r07 +
      radius +
      "000" +
      r08 +
      numResults +
      r09 +
      exclude +
      r10 +
      toExclude +
      r11;

  return request;
}

Future<List> myStationsRequestF(
  String reqTime,
  String reqLat,
  String reqLong,
  String radius,
  String numStats,
) async {
  final url = Uri.parse('https://api.opentransportdata.swiss/ojp20');

  Map<String, String> header = myHeader();

  String stationsRequest = myStationsRequestString(
    reqTime,
    reqLat,
    reqLong,
    radius,
    numStats,
  );

  var stationsResponse = await http.post(
    url,
    headers: header,
    body: stationsRequest,
  );

  int stationsResponseStatus = stationsResponse.statusCode;
  String stationsResponseStatusMessage = statusMessage(stationsResponseStatus);

  if (stationsResponseStatus != 200) {
    var noStations = [];
    var noStation = {};

    noStation["E"] =
        stationsResponseStatus.toString() +
        "|" +
        stationsResponseStatusMessage +
        "|" +
        " " +
        "|" +
        " " +
        "|" +
        " " +
        "|" +
        " ";

    noStations.add(noStation);

    return noStations;
  }

  final List<int> stationsResponseBytes = stationsResponse.bodyBytes;

  var stationsResponseBody = utf8.decode(stationsResponseBytes);

  final stationsResponseXml = XmlDocument.parse(stationsResponseBody);

  final allStations = stationsResponseXml.findAllElements('PlaceResult');

  var theStations = [];
  var theStation = {};

  for (var oneStation in allStations) {
    final stopPlaceRef = oneStation.findAllElements('StopPlaceRef');
    String stopPlaceRefText = myInnerText(stopPlaceRef);

    //    final privCode = oneStation.findAllElements('PrivateCode');
    //    String privCodeText = myInnerText(privCode);

    //    final topoRef = oneStation.findAllElements('TopographicPlaceRef');
    //    String topoRefText = myInnerText(topoRef);

    final stopPlaceName = oneStation.findAllElements('StopPlaceName');
    String stopPlaceNameText = myInnerText(stopPlaceName);

    //    final stopName = oneStation.findAllElements('Name');
    //    String stopNameText = myInnerText(stopName);

    //    final geoPos = oneStation.findAllElements('GeoPosition');
    //    String geoPosText = myInnerText(geoPos);

    final geoLong = oneStation.findAllElements('siri:Longitude');
    String geoLongText = myInnerText(geoLong);

    final geoLat = oneStation.findAllElements('siri:Latitude');
    String geoLatText = myInnerText(geoLat);

    double thereLat = double.parse(geoLatText);
    double thereLong = double.parse(geoLongText);

    //    final compl = oneStation.findAllElements('Complete');
    //    String complText = myInnerText(compl);

    //    final prob = oneStation.findAllElements('Probability');
    //    String probText = myInnerText(prob);

    final ptMode = oneStation.findAllElements('PtMode');
    String ptModeText = myInnerText(ptMode);

    //    final subMode = oneStation.findAllElements('siri:BusSubmode');
    //    String subModeText = myInnerText(subMode);

    List<double> geoThere = [thereLat, thereLong];

    double myLatitude = double.parse(reqLat);
    double myLongitude = double.parse(reqLong);

    List<double> geoStart = [myLatitude, myLongitude];

    int dist = myDistance(geoStart, geoThere);

    theStation[stopPlaceRefText] =
        stopPlaceRefText +
        "|" +
        stopPlaceNameText +
        "|" +
        geoLongText +
        "|" +
        geoLatText +
        "|" +
        dist.toString() +
        "|" +
        ptModeText;
  }

  theStations.add(theStation);

  return theStations;
}
