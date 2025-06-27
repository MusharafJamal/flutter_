import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/firebase_options.dart';
import 'package:flutter_application_3/pages/ipadd.dart';
import 'package:flutter_application_3/pages/userui.dart';
import 'package:flutter_application_3/warapper/wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis/fcm/v1.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

String? ipAdrress;
String? token;
CameraDescription? firstCamera;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final cameras = await availableCameras();
  // final CameraDescription camera;
  firstCamera = cameras
      .firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  token = await messaging.getToken();
  log('FCM Token: $token');
  ipAdrress = await getIPAddress();
  log("IP address : $ipAdrress");
  // final location = await getLocationFromIP(ipAdrress!);
  // log(location.toString());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final CameraDescription camera;
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme:
                GoogleFonts.jockeyOneTextTheme(Theme.of(context).textTheme)),
        home: Wrapper());
  }
}
