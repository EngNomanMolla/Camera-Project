
import 'dart:io';

import 'package:camera_project/Screens/display_image_screen.dart';
import 'package:camera_project/Screens/show_image_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
class DisplayFolder extends StatefulWidget {
  const DisplayFolder({Key? key}) : super(key: key);

  @override
  _DisplayFolderState createState() => _DisplayFolderState();
}

class _DisplayFolderState extends State<DisplayFolder> {

  List<FileSystemEntity> ?_folders;
  Future<void> getDir() async {
    final directory = await getApplicationDocumentsDirectory();
   // print(directory);
    final dir = directory.path;
    String pdfDirectory = '$dir/';
    //final myDir = new Directory("/data/user/0/com.example.camera_project/cache/");
    final myDir = new Directory("/storage/emulated/0/Camera Project");
    setState(() {
      _folders = myDir.listSync(recursive: false, followLinks: false);

    });
    print(_folders!.length.toString());
    print("length"+ _folders!.last.toString());
  }

  void _openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    // if no file is picked
    if (result == null) return;

    // we get the file from result object
    final file = result.files.first;

    _openFile(file);
  }



@override
   void initState() {
  getDir();
   //print("length"+ _folders!.length.toString());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
         shrinkWrap: true,
          itemCount: _folders!.length,
          itemBuilder: (context,index){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){
                  final baseName=basename(_folders![index].path);
                 Get.to(DisplayImage(),arguments: ['/storage/emulated/0/Camera Project/$baseName']);
                  //Get.to(DisplayImage());
                },
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey,
                  child: Text(basename(_folders![index].path)),
                ),
              ),
            );
          }),
    );
  }
}

















// import 'dart:io';
//
// import 'package:file_manager/file_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider_ex/path_provider_ex.dart';
// class MyFileList extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     return _MyFileList();
//   }
// }
//
// class _MyFileList extends State<MyFileList>{
//   var files;
//
//   void getFiles() async { //asyn function to get list of files
//     List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
//     var root = storageInfo[0].rootDir; //storageInfo[1] for SD card, geting the root directory
//     var fm = FileManager(root: Directory(root)); //
//     files = await fm.dirsTree(
//       //set fm.dirsTree() for directory/folder tree list
//         excludedPaths: ["/storage/emulated/0"],
//         //extensions: ["png", "pdf"] //optional, to filter files, remove to list all,
//       //remove this if your are grabbing folder list
//     );
//     setState(() {}); //update the UI
//   }
//
//   @override
//   void initState() {
//     getFiles(); //call getFiles() function on initial state.
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//             title:Text("File/Folder list from SD Card"),
//             backgroundColor: Colors.redAccent
//         ),
//         body:files == null? Text("Searching Files"):
//         ListView.builder(  //if file/folder list is grabbed, then show here
//           itemCount: files?.length ?? 0,
//           itemBuilder: (context, index) {
//             return Card(
//                 child:ListTile(
//                   title: Text(files[index].path.split('/').last),
//                   leading: Icon(Icons.image),
//                   trailing: Icon(Icons.delete, color: Colors.redAccent,),
//                 )
//             );
//           },
//         )
//     );
//   }
// }