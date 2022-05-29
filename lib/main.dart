import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'dart:ui' as ui;

void main() {
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
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  File? image;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          child: image != null
              ? Image.file(image!)
              : Container(
                  height: 300,
                  width: 300,
                  color: Colors.indigo,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.camera),
        onPressed: () {
          getImage();
        },
      ),
    );
  }

  // getImage() async {
  //   final XFile? pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.camera);
  //
  //   final directory = (await getApplicationDocumentsDirectory()).path;
  //   ByteData byteData =
  //       await pickedFile!.path.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List pngBytes = byteData.buffer.asUint8List();
  //   print(pngBytes);
  //   File imgFile = new File('$directory/screenshot.png');
  //   imgFile.writeAsBytes(pngBytes);
  // }

  // Future<void> getImage() async {
  //   final imageFile = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //     maxWidth: 600,
  //   );
  //   if (imageFile == null) {
  //     return;
  //   }
  //   File tempFile=File(imageFile.path);
  //
  //   setState(() {
  //     _storedImage = tempFile;
  //   });
  //   final appDir = await getTemporaryDirectory();
  //   final fileName = Path.basename(tempFile.path);
  //   final savedImage = await tempFile.copy('${appDir.path}/$fileName');
  // }

  Future getImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    try {
      if (pickedFile != null) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String path = appDocDir.path;
         File pickedImageFile = File(pickedFile.path);
         final  _baseName = Path.basename(pickedFile!.path);
        final String _fileExtension = Path.extension(pickedFile.path);
        final File newImage = await pickedImageFile!.copy('$path/$_baseName$_fileExtension');
        setState(() {
          image = newImage;
          print("file path...");
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print(e);
    }
  }


}
