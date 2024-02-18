import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ViewImage extends StatelessWidget {
  List<PickedFile>? listOfImage;

  ViewImage(this.listOfImage);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      PageView(
        children: listOfImage!.map((image) {
          return Image.file(File(image.path));
        }).toList(),
      ),
      Positioned(
          right: 10,
          top: 50,
          child: Container(
            width: 50,
            height: 50,
            child: TextButton(
                onPressed: () {
                  print('pressed');
                  Navigator.pop(context);
                },
                child: const Icon(Icons.cancel,color: Colors.red,size: 32,)),
          ))
    ]);
  }
}
