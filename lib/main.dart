//     veroeffentlicht unter:
//
//     GNU GENERAL PUBLIC LICENSE
//
//     Version 3, 29 June 2007
//
//     https://www.gnu.org/licenses/gpl-3.0.en.html

import 'package:flutter/material.dart';

import './start.dart';
import './stations.dart';
import './stops.dart';
import './ors_dir.dart';
import './os_map.dart';
import './os_tmap.dart';
import './trip.dart';

void main() async {
  runApp(const MyFahrplanApp());
}

class MyFahrplanApp extends StatelessWidget {
  const MyFahrplanApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    double snackFontSize = 20.0;
    double snackBorderRadius = 4.0;

    if (size.shortestSide < 700) {
      snackFontSize = 15.0;
      snackBorderRadius = 3.0;
    }

    return MaterialApp(
      title: 'Fahrplan',
      theme: ThemeData(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[100]!,
          actionTextColor: Colors.red,
          contentTextStyle: TextStyle(
            fontSize: snackFontSize,
            color: Colors.black,
          ),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(snackBorderRadius))),
          behavior: SnackBarBehavior.floating,
          elevation: 10.0,
        ),
      ),
      initialRoute: 'StartPage',
      routes: {
        'StartPage': (context) => const StartPage(),
        'StationsPage': (context) => const StationsPage(),
        'StopsPage': (context) => const StopsPage(),
        'OrsDirPage': (context) => const OrsDirPage(),
        'OsMapPage': (context) => const OsMapPage(),
        'OstMapPage': (context) => const OstMapPage(),
        'TripPage': (context) => const TripPage(),
      },
    );
  }
}
