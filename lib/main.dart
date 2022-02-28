import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cell_info/CellResponse.dart';
import 'package:cell_info/SIMInfoResponse.dart';
import 'package:cell_info/cell_info.dart';
import 'package:cell_info/models/common/cell_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CellsResponse _cellsResponse;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  String currentDBM = "";

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    CellsResponse cellsResponse;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String platformVersion = await CellInfo.getCellInfo;
      final body = json.decode(platformVersion);

      cellsResponse = CellsResponse.fromJson(body);

      CellType currentCellInFirstChip = cellsResponse.primaryCellList[0];
      print('123456${currentCellInFirstChip.type.toLowerCase()}');
      if (currentCellInFirstChip.type == "LTE") {
        ///4g
        setState(() {
          currentDBM = "LTE dbm = " +
              currentCellInFirstChip.lte.signalLTE.dbm.toString();
          print('currentLte::::$currentDBM');
        });
      } else if (currentCellInFirstChip.type == "NR") {
        /// 5g
        currentDBM =
            "NR dbm = " + currentCellInFirstChip.nr.signalNR.dbm.toString();
        print('currentNr::::$currentDBM');
      } else if (currentCellInFirstChip.type == "WCDMA") {
        ///3g
        currentDBM = "WCDMA dbm = " +
            currentCellInFirstChip.wcdma.signalWCDMA.dbm.toString();
        print('currentWcdma::::$currentDBM');
      } else if (currentCellInFirstChip.type.toLowerCase() == "gsm") {
        /// 2g
        currentDBM =
            "GSM dbm = " + currentCellInFirstChip.gsm.signalGSM.dbm.toString();
        print('currentGSm::::$currentDBM');
      }

      String simInfo = await CellInfo.getSIMInfo;
      final simJson = json.decode(simInfo);
      print(
          "desply name ${SIMInfoResponse.fromJson(simJson).simInfoList[1].displayName}");
    } on PlatformException {
      _cellsResponse = null;
      print('cell info  ::::$e');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _cellsResponse = cellsResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Text(
              currentDBM??'no data', style: TextStyle(color: Colors.black),
            ),
          )),
    );
  }

  Timer timer;

  void startTimer() {
    const oneSec = const Duration(seconds: 3);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        initPlatformState();
      },
    );
  }
}
