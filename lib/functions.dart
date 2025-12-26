import 'package:xml/xml.dart';
import 'dart:core';
import 'package:latlong2/latlong.dart';

String attachZero(String dtVal) {
  if (dtVal.length < 2) {
    dtVal = "0" + dtVal;
  }

  return dtVal;
}

List<String> localTime() {
  final nowLoc = DateTime.now();
  String sNowLoc = nowLoc.toString();

  final nowUtc = nowLoc.toUtc();
  String sNowUtc = nowUtc.toString();

  String requestTime = sNowUtc.replaceFirst(' ', 'T');

  final timeOffset = nowLoc.timeZoneOffset.toString();
  List<String> tOffs = timeOffset.split(':');
  String tOffHour = tOffs[0];

  var sNow = sNowLoc.split(' ');

  String nowDate = sNow[0];
  String nowTime = sNow[1];
  String nowHM = nowTime.substring(0, 5);

  String lDay = attachZero(nowLoc.day.toString());
  String lMonth = attachZero(nowLoc.month.toString());
  String lYear = attachZero(nowLoc.year.toString());
  String lMinute = attachZero(nowLoc.minute.toString());
  String lHour = attachZero(nowLoc.hour.toString());

  List<String> nowDT = [
    nowDate,
    nowHM,
    requestTime,
    tOffHour,
    lDay,
    lMonth,
    lYear,
    lMinute,
    lHour,
    sNowLoc,
  ];

  return nowDT;
}

List<String> nTime(String nUtc) {
  String sNUtc = nUtc.replaceFirst('T', ' ');
  var nReqUtc = DateTime.parse(sNUtc);

  DateTime nReqLoc = nReqUtc.toLocal();
  String sNowLoc = nReqLoc.toString();

  String requestTime = nUtc;

  final timeOffset = nReqLoc.timeZoneOffset.toString();
  List<String> tOffs = timeOffset.split(':');
  String tOffHour = tOffs[0];

  var sNow = sNowLoc.split(' ');

  String nowDate = sNow[0];
  String nowTime = sNow[1];
  String nowHM = nowTime.substring(0, 5);

  String lDay = attachZero(nReqLoc.day.toString());
  String lMonth = attachZero(nReqLoc.month.toString());
  String lYear = attachZero(nReqLoc.year.toString());
  String lMinute = attachZero(nReqLoc.minute.toString());
  String lHour = attachZero(nReqLoc.hour.toString());

  List<String> nowDT = [
    nowDate,
    nowHM,
    requestTime,
    tOffHour,
    lDay,
    lMonth,
    lYear,
    lMinute,
    lHour,
    sNowLoc,
  ];

  return nowDT;
}

List<String> myInnerText2(Iterable<XmlElement> myElement) {
  List<String> bothTimes = [];

  String TTS = "";
  String ETS = "";
  String TTime = "no";
  String ETime = "no";

  Iterable<XmlElement> myElementList = myElement.toList();
  if (myElementList.length > 0) {
    var myElement0 = myElementList.elementAt(0);
    String myElement0S = myElement0.toString();
    int ttstart = 0;
    int etstart = 0;
    int srstart = 0;

    if (myElement0S.contains("TimetabledTime")) {
      ttstart = myElement0S.indexOf("TimetabledTime") - 1;
    }

    if (myElement0S.contains("EstimatedTime")) {
      etstart = myElement0S.indexOf("EstimatedTime") - 1;
    }

    if (myElement0S.contains("Service")) {
      srstart = myElement0S.indexOf("/Service") - 1;
    }

    if (ttstart > 0) {
      if (etstart == 0) {
        TTS = myElement0S.substring(ttstart, srstart);
      } else {
        TTS = myElement0S.substring(ttstart, etstart);
      }
      TTime = TTS.substring(16, 36);
    }

    if (etstart > 0) {
      ETS = myElement0S.substring(etstart, srstart);
      ETime = ETS.substring(15, 35);
    } else {
      ETime = TTime;
    }
  }

  bothTimes.add(TTime);
  bothTimes.add(ETime);

  return (bothTimes);
}

String myInnerText(Iterable<XmlElement> myElement) {
  String mySElement = "";

  Iterable<XmlElement> myElementList = myElement.toList();
  if (myElementList.length > 0) {
    var myElement0 = myElementList.elementAt(0);
    mySElement = myElement0.innerText;
  }

  return mySElement;
}

int myDistance(List<double> here, List<double> there) {
  final Distance distance = Distance();

  LatLng locHere = LatLng(here[0], here[1]);
  LatLng locThere = LatLng(there[0], there[1]);

  final double meter = distance(locHere, locThere);

  return meter.toInt();
}

List<String> ETString(String tTTime, String tETime, String tArr) {
  String late = "";

  String thisTTimed = tTTime.replaceAll("T", " ");
  String thisETimed = tETime.replaceAll("T", " ");

  var thisTTimeUtc = DateTime.parse(thisTTimed);
  var thisETimeUtc = DateTime.parse(thisETimed);

  var thisTTimeLoc = thisTTimeUtc.toLocal();
  var thisETimeLoc = thisETimeUtc.toLocal();

  var thisDelay = thisETimeLoc.difference(thisTTimeLoc);
  int thisDelayI = thisDelay.inMinutes;

  String thisTTimes = thisTTimeLoc.toString();
  String thisETimes = thisETimeLoc.toString();
  String thisDelayIs = thisDelayI.toString();

  List<String> thisTTimesl = thisTTimes.split(" ");
  String opDay = thisTTimesl[0];
  String thisTTimeslT = thisTTimesl[1];
  List<String> thisTTimeslTl = thisTTimeslT.split(":");
  String thisTTimeslTlhm = thisTTimeslTl[0] + ":" + thisTTimeslTl[1];

  List<String> thisETimesl = thisETimes.split(" ");
  String thisETimeslT = thisETimesl[1];
  List<String> thisETimeslTl = thisETimeslT.split(":");
  String thisETimeslTlhm = thisETimeslTl[0] + ":" + thisETimeslTl[1];

  String thisTimeString = thisTTimeslTlhm;

  if (thisDelayI > 0) {
    thisTimeString =
        thisTimeString + " + " + thisDelayIs + " " + thisETimeslTlhm;
  }

  if (!tArr.contains("N")) {
    DateTime thisArriv = DateTime.parse(tArr);

    if (thisETimeLoc.isBefore(thisArriv)) {
      late = "tooLate";
    }
  }

  List<String> retString = [];
  retString.add(thisTimeString);
  retString.add(opDay);
  retString.add(late);

  return (retString);
}

String cleanFormation(String formation) {
  String form_01 = formation;

  String pLeft = RegExp.escape('(');
  String pRight = RegExp.escape(')');

  String form_02 = form_01.replaceAll(RegExp('@'), ' @');
  String form_03 = form_02.replaceAll(RegExp('BHP'), '');
  String form_04 = form_03.replaceAll(RegExp('BZ'), '');
  String form_05 = form_04.replaceAll(RegExp('FZ'), '');
  String form_06 = form_05.replaceAll(RegExp('KW'), '');
  String form_07 = form_06.replaceAll(RegExp('NF'), '');
  String form_08 = form_07.replaceAll(RegExp('VH'), '');
  String form_09 = form_08.replaceAll(RegExp('VR'), '');
  String form_10 = form_09.replaceAll(RegExp('FA'), '');
  String form_11 = form_10.replaceAll(RegExp('LK'), 'L');
  String form_12 = form_11.replaceAll(RegExp('WR'), 'R');
  String form_13 = form_12.replaceAll(RegExp('W1'), 'R1');
  String form_14 = form_13.replaceAll(RegExp('W2'), 'R2');
  String form_22 = form_14.replaceAll(RegExp(r':(\d+)'), '');
  String form_23 = form_22.replaceAll(RegExp('%'), '');

  String form_15 = form_23.replaceAll(RegExp('#'), '');
  String form_16 = form_15.replaceAll(RegExp(';'), '');
  String form_17 = form_16.replaceAll(RegExp(','), ' ');
  String form_18 = form_17.replaceAll(RegExp(pLeft), '( ');
  String form_19 = form_18.replaceAll(RegExp(pRight), ' )');
  String form_20 = form_19.replaceAll(RegExp(' F'), '');
  String form_21 = form_20.trimLeft();

  return (form_21);
}

String wEvu(String jRef) {
  List<String> jRefItems = jRef.split(":");

  String evu = "nA";

  if (jRefItems.length == 5) {
    String jEvu = jRefItems[3];

    if (jEvu.endsWith("053")) {
      evu = "RhB";
    } else if (jEvu.endsWith("001")) {
      evu = "SBBP";
    } else if (jEvu.endsWith("046")) {
      evu = "THURBO";
    } else if (jEvu.endsWith("061")) {
      evu = "SOB";
    } else if (jEvu.endsWith("015")) {
      evu = "BLSP";
    } else if (jEvu.endsWith("012")) {
      evu = "MBC";
    } else if (jEvu.endsWith("049")) {
      evu = "OeBB";
    } else if (jEvu.endsWith("034")) {
      evu = "TPF";
    } else if (jEvu.endsWith("025")) {
      evu = "TRN";
    } else if (jEvu.endsWith("064")) {
      evu = "ZB";
    }
  }

  return (evu);
}
