import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'dart:io';

class DashboardController extends GetxController{
  RxBool isCapturing=RxBool(false);

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image;
  @override
  void onInit() {

    super.onInit();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if(cameras != null){
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        // if (!mounted) {
        //   return;
        // }
      });
    }else{
      print("NO any camera found");
    }
  }
}