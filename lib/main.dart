import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminder/screen/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final task = Firestore.instance.collection('tasks');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogIn(),
    );
  }
}

