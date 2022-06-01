import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';
  double textSize = 20;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Flexible(
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      onPressed: _takePhoto,
                      child: Text(firstButtonText,
                          style:
                          TextStyle(fontSize: textSize, color: Colors.white)),
                    ),
                  ),
                  flex: 1,
                ),
                Flexible(
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      onPressed: _recordVideo,
                      child: Text(secondButtonText,
                          style: TextStyle(
                              fontSize: textSize, color: Colors.blueGrey)),
                    ),
                  ),
                  flex: 1,
                )
              ],
            ),
          ),
        ));
  }

  void _takePhoto() async {
    await _picker
        .pickImage(source: ImageSource.camera)
        .then((XFile? recordedImage) {
      if (recordedImage != null && recordedImage.path != null) {
        setState(() {
          firstButtonText = 'saving in progress...';
        });
        GallerySaver.saveImage(recordedImage.path).then((path) {
          setState(() {
            firstButtonText = 'image saved!';
          });
        });
      }
    });
  }

  void _recordVideo() async {
    await _picker
        .pickVideo(source: ImageSource.camera)
        .then((XFile? recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        GallerySaver.saveVideo(recordedVideo.path).then((path) {
          setState(() {
            secondButtonText = 'video saved!';
          });
        });
      }
    });
  }
}
