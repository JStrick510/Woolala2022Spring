import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadScreen extends StatefulWidget {
  ImageUploadScreen();
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

Future<File> cropImage(imagePath) async {
  File croppedImage = await ImageCropper.cropImage(
    sourcePath: imagePath,
    maxHeight: 1000,
    maxWidth: 1000,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    androidUiSettings: AndroidUiSettings(
      toolbarTitle: 'WooLaLa',
      activeControlsWidgetColor: Colors.green,
      toolbarColor: Colors.blue,
      toolbarWidgetColor: Colors.white,
    ),
  );
  return croppedImage;
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File _image;
  String img64;
  final picker = ImagePicker();
  bool selected = false;

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = await cropImage(pickedFile.path);
      if (_image != null) {
        final bytes = _image.readAsBytesSync();
        img64 = base64Encode(bytes);
        Navigator.pushReplacementNamed(context, '/makepost',
            arguments: [_image, img64]);
      }
    } else {
      print('No image selected.');
    }
  }

  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = await cropImage(pickedFile.path);
      if (_image != null) {
        final bytes = _image.readAsBytesSync();
        img64 = base64Encode(bytes);
        Navigator.pushReplacementNamed(context, '/makepost',
            arguments: [_image, img64]);
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back, // add custom icons also
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () => {
                if (_image != null)
                  Navigator.pushReplacementNamed(context, '/makepost',
                      arguments: [_image, img64])
              },
              child: Text("Next"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            )
          ],
        ),
        body: Center(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 25),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                    Colors.purple[900],
                    Colors.purple[800],
                    Colors.purple[600]
                  ]),
                ),
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 150,
                  ),
                  new Image.asset('./assets/logos/w_logo_test.png',
                      width: 300,
                      height: 150,
                      fit: BoxFit.contain,
                      semanticLabel: 'WooLaLa logo'),
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          child: Icon(Icons.camera_enhance),
                          key: ValueKey("Camera"),
                          onPressed: () => getImageCamera(),
                          heroTag: null,
                        ),
                        FloatingActionButton(
                          child: Icon(Icons.collections),
                          key: ValueKey("Gallery"),
                          onPressed: () => getImageGallery(),
                          heroTag: null,
                        )
                      ]),
                ]))));
  }
}
