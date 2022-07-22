import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayImageController extends GetxController{
  int index=0;
  List<Image> imageList=[];
  final Directory _photoDir = new Directory('/storage/emulated/0/Camera Project/MyFolder');
  @override
  void onInit() {
    getImageList();
    super.onInit();
  }

  void getImageList() {
     imageList = _photoDir
        .listSync()
        .map((item) => Image.file(File(item.path),fit: BoxFit.fill, gaplessPlayback: false))
        .toList();
  }

   Image getImage(){
    return imageList[index];
   }

  changeIndex(int value){
    index=value;
    update();

  }


}