import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_project/Controllers/dashboard_controller.dart';
import 'package:camera_project/Screens/discover_device_screen.dart';
import 'package:camera_project/Screens/display_folder_screen.dart';
import 'package:camera_project/Screens/display_image_screen.dart';
import 'package:camera_project/Services/bluetooth_services.dart';
import 'package:camera_project/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  late TextEditingController degreeController =
      TextEditingController(text: "10");
  late TextEditingController directionController =
      TextEditingController(text: "0");
  late TextEditingController speedController =
      TextEditingController(text: "100");
  late TextEditingController nameController = TextEditingController();
  late TextEditingController idController = TextEditingController();

  Timer? timer;

  @override
  void initState() {
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

  void _takePhoto(String folder) async {
    String foldername =folder;
    try {
      if (controller != null) {
        if (controller!.value.isInitialized) {
          image = await controller!.takePicture();
          _playSound();
          try {
            // final Directory duplicateFilePath =
            //     await getApplicationDocumentsDirectory();
            // String directoryPath = duplicateFilePath.path;
            // final String fileName = path.basename(image!.path);
            final appName = "Camera Project";
            // final filePath = '$directoryPath/$appName/$fileName';
            // File oldImage = File(image!.path);
            // final File newImage = await oldImage.copy(filePath);
            // //await image!.saveTo('$directoryPath/$fileName');

            await GallerySaver.saveImage(image!.path, albumName: '$appName/$foldername');
            print(image!.path);
          } catch (e) {
            Fluttertoast.showToast(msg: "Image not saved" + e.toString());
          }
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
                        Get.to(DisplayFolder());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          "Display Image",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF3C3C3C)),
                    ),
                    SizedBox(width: 10.0),
                    TextButton(
                      onPressed: () {
                        showAlertDialog(context);
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

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Capture"),
      onPressed: () {
        var data = {
          "degree": degreeController.text,
          "ccwdirection": directionController.text,
          "degreesPerSecond": speedController.text
        };
        if (nameController.text.isNotEmpty) {
          //_takePhoto(nameController.text);
          blueToothService.setFolderName(nameController.text);
          nameController.clear();
          Navigator.pop(context);
         blueToothService.takePictureCallback = _takePhoto;
         blueToothService.sendMessage(data.toString());
        } else {
          return;
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Container(
        height: 150,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Enter your folder name"),
            ),
            TextField(
              controller: idController,
              decoration: InputDecoration(hintText: "Enter id"),
            )
          ],
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Future getImageCamera() async {
  //   var imageFile = await ImagePicker().pickImage(
  //       source: ImageSource.camera, maxHeight: 20.0, maxWidth: 20.0);
  //
  //   DateTime ketF = new DateTime.now();
  //   String baru = "${ketF.year}${ketF.month}${ketF.day}";
  //
  //   final directory = await getExternalStorageDirectory();
  //
  //   //int rand = new math.Random().nextInt(100000);
  //
  //   final myImagePath = '${directory!.path}/MyImages' ;
  //   final myImgDir = await new Directory(myImagePath).create();
  //
  //   var kompresimg = new File("$myImagePath/image_$baru.jpg")
  //     ..writeAsBytesSync(img.encodeJpg(imageFile, quality: 95));
  //
  // }

}
