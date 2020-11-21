import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
import 'package:simple_animations/simple_animations.dart';

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
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 0;

    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Colors.purple[900], end: Colors.purple[500])),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Colors.purple[300], end: Colors.purple[900])),
      Track("color3").add(Duration(seconds: 3),
          ColorTween(begin: Colors.purple[900], end: Colors.purple[500]))
    ]);

    return Scaffold(
      body: Center(
        child: ControlledAnimation(
          playback: Playback.MIRROR,
          tween: tween,
          duration: tween.duration,
          builder: (context, animation) {
            return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [animation["color1"], animation["color2"], animation["color3"]])),
                padding: EdgeInsets.symmetric(vertical: 25),
                width: double.infinity,
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
                ]));
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.bottom_items,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
