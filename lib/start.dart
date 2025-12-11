import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import './functions.dart';
import './gcode.dart';

String dNow = "no date";
String tNow = "no time";
String requestUtc = "no date";
String tOff = "no offset";
String tDay = "no day";
String tMonth = "no month";
String tYear = "no year";
String tMinute = "no minute";
String tHour = "no hour";
String tOffHour = "no offset";
String tTime = "no time";
String tDate = "no date";
String tNowLocal = "no date";

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  String radius = '10';
  String numStats = '15';
  String numStops = '20';

  List<String> dtNow = [];

  bool addressNotFound = true;
  bool notResetted = true;
  bool inArgsNotDone = true;

  double startLat = 0.0;
  double startLong = 0.0;
  String startLats = "no latitude";
  String startLongs = "no longitude";
  String startAddress = "no address";

  double startFontSize = 20.0;
  double startFontSizeT = 20.0 * 1.2;
  double startFontSizeS = 20.0 * 0.8;
  double startIconSize = 30.0;

  List<dynamic> inArgs = [];

  var TheStations = [];

  DateTime nowLocal = DateTime.now();

  final TextEditingController radController = TextEditingController();
  final TextEditingController statsController = TextEditingController();
  final TextEditingController stopsController = TextEditingController();

  final List<DropdownMenuEntry> radList = [
    DropdownMenuEntry(value: '1', label: '1'),
    DropdownMenuEntry(value: '5', label: '5'),
    DropdownMenuEntry(value: '10', label: '10'),
    DropdownMenuEntry(value: '15', label: '15'),
    DropdownMenuEntry(value: '20', label: '20'),
  ];

  final List<DropdownMenuEntry> statsList = [
    DropdownMenuEntry(value: '5', label: '5'),
    DropdownMenuEntry(value: '10', label: '10'),
    DropdownMenuEntry(value: '15', label: '15'),
    DropdownMenuEntry(value: '20', label: '20'),
    DropdownMenuEntry(value: '25', label: '25'),
    DropdownMenuEntry(value: '30', label: '30'),
    DropdownMenuEntry(value: '35', label: '35'),
  ];

  final List<DropdownMenuEntry> stopsList = [
    DropdownMenuEntry(value: '5', label: '5'),
    DropdownMenuEntry(value: '10', label: '10'),
    DropdownMenuEntry(value: '15', label: '15'),
    DropdownMenuEntry(value: '20', label: '20'),
    DropdownMenuEntry(value: '25', label: '25'),
    DropdownMenuEntry(value: '30', label: '30'),
  ];

  void startLoc() async {
    List<double> startCoords = await myLocationF();

    startLat = startCoords[0];
    startLong = startCoords[1];

    startLats = startLat.toStringAsFixed(6);
    startLongs = startLong.toStringAsFixed(6);

    setState(() {});
  }

  void geoCodes(double startLat, double startLong) async {
    if (addressNotFound) {
      startAddress = await geoCodesF(
        startLat,
        startLong,
        startLats,
        addressNotFound,
        startAddress,
      );

      if (startAddress.contains("no address")) {
        addressNotFound = true;
      } else {
        addressNotFound = false;
      }
    }

    setState(() {});
  }

  List<String> prepareArgs() {
    addressNotFound = true;

    List<String> Args = [
      requestUtc,
      startLats,
      startLongs,
      radius,
      numStats,
      numStops,
      startAddress,
    ];

    return Args;
  }

  void do_reset() {
    inArgs = [];
    addressNotFound = true;

    startLats = "no latitude";
    startLongs = "no longitude";
    radius = '10';
    numStats = '15';
    numStops = '20';
    startAddress = "no address";

    startLoc();
    geoCodes(startLat, startLong);
    dtNow = localTime();
    workDTValues();

    inArgs = [
      requestUtc,
      startLats,
      startLongs,
      radius,
      numStats,
      numStops,
      startAddress,
    ];

    notResetted = false;

    setState(() {});
  }

  void go_stations() {
    List<String> statsArgs = prepareArgs();

    String newroute = 'StationsPage';

    Navigator.pushNamed(context, newroute, arguments: statsArgs);
  }

  void go_map() {
    List<String> mapArgs = prepareArgs();

    String newroute = 'OsMapPage';

    Navigator.pushNamed(context, newroute, arguments: mapArgs);
  }

  void nRadSelected(String rad) {
    radius = rad;

    setState(() {});
  }

  void nStatsSelected(String nstats) {
    numStats = nstats;

    setState(() {});
  }

  void nStopsSelected(String nstops) {
    numStops = nstops;

    setState(() {});
  }

  void workDate(DateTime sDate) {
    String selDate = sDate.toString();

    List<String> sDateTime = selDate.split(' ');
    List<String> selDate0 = sDateTime[0].split('-');

    tYear = selDate0[0];
    tMonth = selDate0[1];
    tDay = selDate0[2];

    tDate = sDateTime[0];

    DateTime tSelLocal = DateTime.parse(tDate + "T" + tTime);
    DateTime tSelUtc = tSelLocal.toUtc();

    String tUtcSel = tSelUtc.toString();
    requestUtc = tUtcSel.replaceFirst(" ", "T");

    dtNow = nTime(requestUtc);

    setState(() {});
  }

  void workTime(DateTime sTime) {
    String selDate = sTime.toString();

    List<String> sDateTime = selDate.split(' ');
    List<String> selDate0 = sDateTime[1].split(':');

    tHour = selDate0[0];
    tMinute = selDate0[1];

    tTime = sDateTime[1];

    DateTime tSelLocal = DateTime.parse(tDate + "T" + tTime);
    DateTime tSelUtc = tSelLocal.toUtc();

    String tUtcSel = tSelUtc.toString();
    requestUtc = tUtcSel.replaceFirst(" ", "T");

    dtNow = nTime(requestUtc);

    setState(() {});
  }

  void workDTValues() {
    dNow = dtNow[0];
    tNow = dtNow[1];
    requestUtc = dtNow[2];
    tOff = dtNow[3];
    tDay = dtNow[4];
    tMonth = dtNow[5];
    tYear = dtNow[6];
    tMinute = dtNow[7];
    tHour = dtNow[8];
    tNowLocal = dtNow[9];

    tDate = dNow;
    tTime = tNow;

    nowLocal = DateTime.parse(tNowLocal);
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.initState();

    setState(() {});
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

  prepareWidget() {
    if (startLats.contains("latitude")) {
      startLoc();
    }

    if (startAddress.contains("no address")) {
      geoCodes(startLat, startLong);
    }

    if (dNow.contains("date")) {
      dtNow = localTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iroute = ModalRoute.of(context);
    final isett = iroute!.settings;

    if (notResetted) {
      if (isett.arguments != null) {
        inArgs = (isett.arguments) as List;

        if (inArgsNotDone) {
          if (inArgs.length > 0) {

            if (inArgs.length == 9) {
              startLat = double.parse(inArgs[7]);
              startLong = double.parse(inArgs[8]);
            }

            if (inArgs.length == 7) {
              startLat = double.parse(inArgs[1]);
              startLong = double.parse(inArgs[2]);
              startAddress = inArgs[6];
            }

            startLats = startLat.toStringAsFixed(6);
            startLongs = startLong.toStringAsFixed(6);

            requestUtc = inArgs[0];
            radius = inArgs[3];
            numStats = inArgs[4];
            numStops = inArgs[5];

            dtNow = nTime(requestUtc);

            inArgsNotDone = false;
          }
        }
      }
    }

    Size size = MediaQuery.sizeOf(context);

    if (size.shortestSide < 700) {
      startFontSize = 15;
      startFontSizeT = 15 * 1.2;
      startFontSizeS = 15 * 0.8;
      startIconSize = 25;
    }

    prepareWidget();
    workDTValues();

    return MaterialApp(
      theme: ThemeData(
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.teal.shade50),
          ),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          title: Text("Fahrplan", style: TextStyle(fontSize: startFontSizeT)),
          backgroundColor: Colors.teal[400],
        ),
        body: Column(
          children: <Widget>[
            Card(
              color: Colors.teal[200],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      startAddress,
                      style: TextStyle(fontSize: startFontSize),
                    ),
                    subtitle: Text(
                      startLats + " N  " + startLongs + " E",
                      style: TextStyle(fontSize: startFontSize),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              color: Colors.teal[100],
              child: ListTile(
                title: Text(
                  "  " + tDay + '.' + tMonth + '.' + tYear,
                  style: TextStyle(fontSize: startFontSize),
                ),
                leading: OutlinedButton(
                  onPressed: () {
                    DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime(2025, 1, 1),
                      maxTime: DateTime(2030, 12, 31),
                      onConfirm: (datePicked) {
                        workDate(datePicked);
                      },
                      currentTime: nowLocal,
                      locale: LocaleType.de,
                    );
                  },
                  child: Text(
                    'Datum',
                    style: TextStyle(
                      fontSize: startFontSize,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.teal[100],
              child: ListTile(
                title: Text(
                  "   " + tHour + ":" + tMinute,
                  style: TextStyle(fontSize: startFontSize),
                ),
                leading: OutlinedButton(
                  onPressed: () {
                    DatePicker.showTimePicker(
                      context,
                      showTitleActions: true,
                      showSecondsColumn: false,
                      onConfirm: (timePicked) {
                        workTime(timePicked);
                      },
                      currentTime: nowLocal,
                      locale: LocaleType.de,
                    );
                  },
                  child: Text(
                    'Zeit',
                    style: TextStyle(
                      fontSize: startFontSize,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.teal[100],
              child: ListTile(
                title: Text(
                  "Suchradius [km]",
                  style: TextStyle(fontSize: startFontSize),
                ),
                leading: DropdownMenu(
                  initialSelection: radius,
                  controller: radController,
                  onSelected: (value) {
                    nRadSelected(value);
                  },
                  dropdownMenuEntries: radList,
                ),
              ),
            ),
            Card(
              color: Colors.teal[100],
              child: ListTile(
                title: Text(
                  "Anzahl Stationen",
                  style: TextStyle(fontSize: startFontSize),
                ),
                leading: DropdownMenu(
                  initialSelection: numStats,
                  controller: statsController,
                  onSelected: (value) {
                    nStatsSelected(value);
                  },
                  dropdownMenuEntries: statsList,
                ),
              ),
            ),
            Card(
              color: Colors.teal[100],
              child: ListTile(
                title: Text(
                  "Anzahl Abfahrten / Ankünfte",
                  style: TextStyle(fontSize: startFontSize),
                ),
                leading: DropdownMenu(
                  initialSelection: numStops,
                  controller: stopsController,
                  onSelected: (value) {
                    nStopsSelected(value);
                  },
                  dropdownMenuEntries: stopsList,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.teal[400],
          height: 70.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.store, size: startIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_stations();
                },
              ),
              IconButton(
                icon: Icon(Icons.map_outlined, size: startIconSize),
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  go_map();
                },
              ),
              IconButton(
                icon: Icon(Icons.replay_outlined, size: startIconSize),
                color: Colors.red[800],
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                onPressed: () {
                  do_reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
