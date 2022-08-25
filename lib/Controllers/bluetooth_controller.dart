import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController{

  FlutterBlue? flutterBlue;
  @override
  void onInit() {
   flutterBlue= FlutterBlue.instance;
    super.onInit();
  }

void scanDevices(){
  // Start scanning
  flutterBlue!.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
  var subscription = flutterBlue!.scanResults.listen((results) {
    for (ScanResult r in results) {
      print('${r.device.name} found! rssi: ${r.rssi}');
    }
  });

// Stop scanning
  flutterBlue!.stopScan();
}



}