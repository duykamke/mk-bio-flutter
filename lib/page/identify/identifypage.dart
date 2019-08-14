import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';



//something
class IdentifyPage extends StatefulWidget {
  final CameraDescription camera;

  const IdentifyPage({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _IdentifyPage createState() => _IdentifyPage();
}

class _IdentifyPage extends State<IdentifyPage> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });
        _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
    controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: new AppBar(
              automaticallyImplyLeading: false,
              actions: <Widget>[
                new GestureDetector(
                  child: new Icon(Icons.exit_to_app),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  },
                ),
              ],
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.blue[900]),
              backgroundColor: Colors.grey[50],
              title: InkWell(
                  child: Row(children: [
                Image(
                  image: AssetImage("images/Logo.png"),
                  height: 20,
                ),
                RichText(
                    text: TextSpan(
                        text: 'Nhận dạng',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w500))),
              ])),
            )),
        body: Column(children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(children: [
                  Container(
                    width: size,
                    height: size,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Container(
                            width: size,
                            height: size / controller.value.aspectRatio,
                            child: CameraPreview(
                                controller), // this is my CameraPreview
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: size - 110,
                      left: size - 60,
                      child: Column(children: [
                        SizedBox(
                          height: 35,
                          width: 35,
                          child: FloatingActionButton(
                              elevation: 8,
                              backgroundColor: Colors.blue[900],
                              child: IconTheme(
                                data: new IconThemeData(
                                    color: Colors.yellow[600], size: 20),
                                child: new Icon(Icons.switch_camera),
                              ),
                              onPressed: () {
                                _onSwitchCamera();
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FloatingActionButton(
                            elevation: 8,
                            backgroundColor: Colors.blue[900],
                            child: IconTheme(
                              data: new IconThemeData(
                                  color: Colors.yellow[600], size: 35),
                              child: new Icon(Icons.photo_camera),
                            ),
                            onPressed: () {
                              _onCapturePressed();
                            })
                      ])),
                ]);
              } else {
                return Container();
              }
            },
          ),
          SizedBox(
            height: 30,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            RichText(
              text: TextSpan(
                  text: 'Số CMND/CCCD',
                  style: TextStyle(fontSize: 18, color: Colors.blue[900])),
            ),
            RichText(
              text: TextSpan(
                  text: 'Tên',
                  style: TextStyle(fontSize: 18, color: Colors.blue[900])),
            ),
          ]),
          SizedBox(
            height: 30,
          ),
        ]));
  }

  Future<String> _resizePhoto(String filePath) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);

    int width = properties.width;
    var offset = (properties.height - properties.width) / 2;

    File croppedFile = await FlutterNativeImage.cropImage(
        filePath, 0, offset.round(), width, width);

    return croppedFile.path;
  }

  Future _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${controller.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });

    _initializeControllerFuture = controller.initialize();
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  Future _takePicture() async {
    if (!controller.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);

      return null;
    }

    // Do nothing if a capture is on progress
    if (controller.value.isTakingPicture) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String pictureDirectory = '${appDirectory.path}/Pictures';
    await Directory(pictureDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$pictureDirectory/${currentTime}.jpg';

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  void _onCapturePressed() {
    _takePicture().then((filePath) {
      if (mounted) {
        setState(() async {
          imagePath = await _resizePhoto(filePath);
        });

        if (filePath != null) {
          Fluttertoast.showToast(
              msg: 'Picture saved to $filePath',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white);
        }
      }
    });
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
}
