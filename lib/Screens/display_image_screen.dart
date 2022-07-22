import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class DisplayImage extends StatefulWidget {
  @override
  _DisplayImageState createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  // final Directory _photoDir = new Directory(
  //     '/storage/emulated/0/folder6');
  final Directory _photoDir = new Directory(Get.arguments[0]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Display Image'),
          elevation: 0.0,
          backgroundColor: Color(0xFF3C3C3C)),
      body: Container(
        child: FutureBuilder(
          builder: (context, status) {
            return ImageGrid(directory: _photoDir);
          },
        ),
      ),
    );
  }
}

class ImageGrid extends StatefulWidget {
  final Directory? directory;

  const ImageGrid({Key? key, this.directory}) : super(key: key);

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  int index = 0;
  List<File> imageList=[];
  var length=0;

  bool checkButtonName=true;

  @override
  void initState() {
    getImagesFromLocal();
    super.initState();
  }

  getImagesFromLocal(){
    imageList= widget.directory!
        .listSync()
        .map((item) => File(item.path) )
        .toList();
     length=imageList.length;

  }
  @override
  Widget build(BuildContext context) {

    List<File> imageList = widget.directory!
        .listSync()
        .map((item) => File(item.path) )
        .toList();


    return Column(
      children: [
        Expanded(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child:Image.file(File(imageList[index].path))
                )
            ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                  height: 40,
                  child: Slider(
                    value: index.toDouble(),
                    min: 0,
                    max: length.toDouble()-1,
                    divisions: imageList.length.toInt(),
                    label: imageList.length.toDouble().round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        index = value.toInt();
                      });
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                     submitImageToServer();
              },
              child: checkButtonName? Text("Submit",style: TextStyle(color: Colors.white),):CircularProgressIndicator(),),
            )
          ],
        )
      ],
    );
  }

  void submitImageToServer()async {
    print( basename(Get.arguments[0]));
    print(imageList[0].path);

    setState(() {
      checkButtonName=false;
    });

    var headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json'
    };
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.50.218:3000/uploadfiles/'));
    request.fields.addAll({
      'folder_name': basename(Get.arguments[0])
    });
    //request.files.add(await http.MultipartFile.fromPath('files', imageList[0].path));

    for(int i=0;i<imageList.length;i++){
      request.files.add(await http.MultipartFile.fromPath('files', imageList[i].path));
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      setState(() {
        checkButtonName=true;
      });

    }
    else {
      print(response.reasonPhrase);
      setState(() {
        checkButtonName=true;
      });
    }




  }
}
