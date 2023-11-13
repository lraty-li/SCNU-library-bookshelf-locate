import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';


import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scnu_lib_ap_data_sollect/scan_page.dart';

import 'static.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  final Directory? appExternStorage = await handleFolder();
  runApp(ScanPage(appExternStorage));
}

Future<void> init() async {
  
  await requestPermissions();
}

Future<Directory?> handleFolder() async {
  late final Directory? appExternStorage;
  await getDownloadsDirectory().then((value) {
    final Directory? externalStorageDirectory = value;
    if (externalStorageDirectory?.path != null) {
      Directory appExterSto = Directory(
          '${externalStorageDirectory!.path}${Platform.pathSeparator}SCNU_Libray_AP_Data');
      if (!appExterSto.existsSync()) {
        appExterSto.create();
      }
      appExternStorage = appExterSto;
    }
  });
  return appExternStorage;
}

Future<void> requestPermissions() async {
  //TODO check if wifi and location service opened with "network info plus"
  var status = await Permission.storage.status;
  if (status.isDenied) {
    // kai bai
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
  }
}

