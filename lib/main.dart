import 'dart:async';

import 'package:camera/camera.dart';
import 'package:mk_bio/page/identify/identifypage.dart';
import 'package:mk_bio/page/mainpage.dart';
import 'package:mk_bio/page/register/registerpage.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();

  runApp(App());
}

class App extends StatelessWidget {
  final firstCamera = cameras.first;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation',
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/register': (context) => RegisterPage(),
        '/identify': (context) => IdentifyPage(
              camera: firstCamera,
            )
      },
    );
  }
}
