import 'package:flutter/material.dart';
import 'dart:async';


class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key, required this.erorMsg}) : super(key: key);
  final String erorMsg;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {

  Future<void> huntWiFis() async {

    setState(() {});
    // if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('WiFiHunter examplea app'),
      ),
      body: Text(widget.erorMsg),
    ));
  }
}
