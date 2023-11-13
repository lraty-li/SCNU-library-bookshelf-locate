import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scnu_lib_ap_data_sollect/logic_scan_page.dart';
import 'package:vibration/vibration.dart';
import 'package:wifi_scan/wifi_scan.dart';

class ScanPage extends StatefulWidget {
  final Directory? appExternStorage;
  late LogicScanPage logic;
  ScanPage(this.appExternStorage, {Key? key}) : super(key: key) {
    logic = LogicScanPage(appExternStorage); //TODO set as modal parameter
  }

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    LogicScanPage logic = widget.logic;
    return OKToast(
      child: MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: const Text('WiFiHunter examplea app'),
        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              TextField(
                  controller: logic.coodinateXTxtCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "coordinateX")),
              TextField(
                  controller: logic.coodinateYTxtCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "coordinateY")),
              TextField(
                  controller: logic.roundsTxtCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "rounds")),
              TextField(
                  controller: logic.intervalTxtCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "_interval")),
              Text('scanning on round:${logic.rounds}')
            ])),
        // 虽然是采集数据用的，但是不是太马虎了一点
        //TODO why padding not workking
        floatingActionButton: Padding(
          padding: EdgeInsets.all(50),
          child: ElevatedButton(
              onPressed: () => huntWiFis(),
              child: const Text(
                'Hunt Networks',
              )),
        ),
      )),
    );
  }

  Future<void> huntWiFis() async {
    LogicScanPage logic = widget.logic;
    showToast('scan started');
    int rounds = int.parse(logic.roundsTxtCtl.text);
    final int interval = int.parse(logic.intervalTxtCtl.text);
    for (; rounds > 0; rounds--) {
      setState(() {}); //TODO notify UI
      bool startScanSuccess = await logic.startScan();
      if (startScanSuccess) {
        await Future.delayed(
            Duration(seconds: interval)); //intervals later to scan next time
        logic.accessPoints = await logic.getScannedResults();
        logic.allAPdata = logic.fillInData(logic.accessPoints, logic.allAPdata);

        if (rounds == 1) {
          logic.outputAllDataJson();
        }
        //but getting result not delayed?
      }
    }

    showToast('scan finish');
    if (await Vibration.hasVibrator() != null) {
      Vibration.vibrate();
    }

    setState(() {});
    if (!mounted) return;
  }

  _updateInterface() {
    setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    widget.logic.subscription?.cancel();
  }
}
