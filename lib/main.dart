import 'package:camera_project/Screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soundpool/soundpool.dart';
Soundpool? soundpoolOptions;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  soundpoolOptions = Soundpool(streamType: StreamType.notification);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}
