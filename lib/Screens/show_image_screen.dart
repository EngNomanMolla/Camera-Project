import 'package:camera_project/Controllers/display_image_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ShowImage extends StatelessWidget {
  const ShowImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back),
      onPressed: (){
        Get.back();
      },
      ),),
      body: GetBuilder<DisplayImageController>(
        init: DisplayImageController(),
        builder: (controller){
          return Column(
            children: [
              Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child:controller.getImage()
                  )
              ),

              Container(
                  height: 40,
                  child: Slider(
                    value: controller.index.toDouble(),
                    min: 0,
                    max: controller.imageList.length.toDouble(),
                    divisions:controller.imageList.length.toInt(),
                    label: controller.imageList.length.toString(),
                    onChanged: (double value) {
                      controller.changeIndex(value.toInt());
                    },
                  ))
            ],
          );
        },
      ),
    );
  }
}
