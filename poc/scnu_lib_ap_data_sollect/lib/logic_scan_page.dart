import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wifi_scan/wifi_scan.dart';

class LogicScanPage {
  LogicScanPage(Directory? this.appExternStorage);

  Directory? appExternStorage;
  List<WiFiAccessPoint> accessPoints = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  List<Map<String, Map>> allAPdata = [];

  final TextEditingController coodinateXTxtCtl =
      TextEditingController(text: '1');
  final TextEditingController coodinateYTxtCtl =
      TextEditingController(text: '1');
  final TextEditingController roundsTxtCtl = TextEditingController(text: '100');
  final TextEditingController intervalTxtCtl = TextEditingController(text: '3');
  int rounds = 0;



  Future<bool> startScan() async {
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch (can) {
      case CanStartScan.yes:
        final isScanning = await WiFiScan.instance.startScan();
        return isScanning;
      default:
        return false;
    }
  }

  outputAllDataJson() {
    String coodinateXTxt = coodinateXTxtCtl.text;
    String coodinateYTxt = coodinateYTxtCtl.text;
    Map<String, dynamic> output = {
      "coordinateX": coodinateXTxt,
      "coordinateY": coodinateYTxt,
      "data": allAPdata
    };
    String outputJson = jsonEncode(output);
    File outputJsonFile = File(
        '${appExternStorage!.path}${Platform.pathSeparator}${coodinateXTxt}_$coodinateYTxt.json');
    outputJsonFile.createSync();
    outputJsonFile.writeAsString(outputJson);
    allAPdata.clear();
  }

  List<Map<String, Map>> fillInData(List<WiFiAccessPoint> accessPoints,
      List<Map<String, Map<dynamic, dynamic>>> allAPdata) {
    Map<String, Map<String, dynamic>> apData = {};
    for (WiFiAccessPoint result in accessPoints) {
      // DEBUG
      // if (result.bssid.contains('60:0b:03:ef:3d:f1')) {
      // apData[result.bssid] = {"ssid:": result.ssid, "level": result.level};
      // }
      apData[result.bssid] = {"ssid": result.ssid, "level": result.level};
    }
    allAPdata.add(apData);
    return allAPdata;
  }

  Future<List<WiFiAccessPoint>> getScannedResults() async {
    List<WiFiAccessPoint> accessPoints = [];
    final can =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch (can) {
      case CanGetScannedResults.yes:
        accessPoints = await WiFiScan.instance.getScannedResults();
      default:
        {
          showToast("can't get result");
        }
    }
    return accessPoints;
  }
}
