import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_project/Controllers/dashboard_controller.dart';
import 'package:camera_project/Screens/discover_device_screen.dart';
import 'package:camera_project/Services/bluetooth_services.dart';
import 'package:camera_project/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardController dashboardController = Get.put(DashboardController());
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for captured image
  final ImagePicker _picker = ImagePicker();
  Future<int>? _soundId;
  int? _alarmSoundStreamId;

  BluetoothState state = BluetoothState.UNKNOWN;
  BlueToothService blueToothService = Get.put(BlueToothService());
  late TextEditingController degreeController = TextEditingController();
  late TextEditingController directionController = TextEditingController();
  late TextEditingController speedController = TextEditingController();

  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => blueToothService.receivedData());
    loadCamera();
    _soundId = _loadSound();
    super.initState();
  }

  @override
  void dispose() {
   // timer?.cancel();
    super.dispose();
  }

  Future<int> _loadSound() async {
    var asset = await rootBundle.load("assets/capture_tone.wav");
    return await soundpoolOptions!.load(asset);
  }

  Future<void> _playSound() async {
    print('play');
    var _alarmSound = await _soundId;
    _alarmSoundStreamId = await soundpoolOptions!.play(_alarmSound!);
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  void _takePhoto() async {
    try {
      if (controller != null) {
        if (controller!.value.isInitialized) {
          image = await controller!.takePicture();
          _playSound();
          if (image != null && image!.path != null) {
            GallerySaver.saveImage(image!.path).then((path) {});
          }
          setState(() {
            //update UI
          });
        }
      }
    } catch (e) {
      print(e); //show error
    }
  }

  bluetoothOn() async {
    await blueToothService.initialize();
    print(blueToothService.bluetoothState);
    if (await blueToothService.toggleBluetoothState() == true) {
      Get.to(const DiscoveryPage());
    } else {
      print("hoise");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),
                Container(
                    height: 300,
                    width: 300,
                    color: Colors.grey[200],
                    child: controller == null
                        ? Center(child: Text("Loading Camera..."))
                        : !controller!.value.isInitialized
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : CameraPreview(controller!)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Degree"),
                ),
                Container(
                  height: 40.0,
                  width: 300.0,
                  child: TextField(
                    controller: degreeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefix: SizedBox(
                          width: 6.0,
                        ),
                        hintText: "Value",
                        contentPadding: EdgeInsets.all(3.0)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Direction"),
                ),
                Container(
                  height: 40.0,
                  width: 300.0,
                  child: TextField(
                    controller: directionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefix: SizedBox(
                          width: 6.0,
                        ),
                        hintText: "Value",
                        contentPadding: EdgeInsets.all(3.0)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Degrees Per Second"),
                ),
                Container(
                  height: 40.0,
                  width: 300.0,
                  child: TextField(
                    controller: speedController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefix: SizedBox(
                          width: 6.0,
                        ),
                        hintText: "Value",
                        contentPadding: EdgeInsets.all(3.0)),
                  ),
                ),
                SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // _takePhoto();
                        var data = {
                          "degree": degreeController.text,
                          "ccwdirection": directionController.text,
                          "degreesPerSecond": speedController.text
                        };

                          blueToothService.sendMessage(data.toString());

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          "Start Capture",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF3C3C3C)),
                    ),
                    SizedBox(width: 15.0),
                    CircleAvatar(
                        backgroundColor: Color(0xFF3C3C3C),
                        child: IconButton(
                            onPressed: () {
                              bluetoothOn();
                            },
                            icon: Icon(Icons.bluetooth)))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
