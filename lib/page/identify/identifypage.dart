import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:mk_bio/page/identify/model/response_body.dart';
import 'package:mk_bio/page/identify/model/user_info.dart';
import 'package:mk_bio/page/identify/usercard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

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
  bool imageCaptured = false;
  List<int> imageBytes;
  String base64Image;

  ScrollController _scrollController = ScrollController();

  Future<List<UserInfo>> usersFound;
  UserInfo user;

  Future<File> portraitFile;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {}
    });

    controller = CameraController(widget.camera, ResolutionPreset.high);
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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

    try {
      _initializeControllerFuture = controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
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
    final Directory directory = await getExternalStorageDirectory();
    final myImagePath = '${directory.path}/Pictures/pics';
    await Directory(myImagePath).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$myImagePath/$currentTime.jpg';

    try {
      await _initializeControllerFuture;
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  void _onCapturePressed() {
    _takePicture().then((filePath) async {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          imageCaptured = true;
          FlutterNativeImage.cropImage(
              imagePath,
              0,
              0,
              MediaQuery.of(context).size.width.toInt(),
              MediaQuery.of(context).size.width.toInt());
        });
        usersFound = _portraitSubmit();

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

  /*pickPortraitFromGallery(ImageSource source) {
    setState(() {
      portraitFile = ImagePicker.pickImage(source: source);
      if (portraitFile != null) usersFound = _portraitSubmit();
    });
  }*/

  Future<List<UserInfo>> _portraitSubmit() async {
    imageBytes = File(imagePath).readAsBytesSync();
    base64Image = base64Encode(imageBytes);

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "x-access-token":
          "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiJ9.zyLN_9bes3UJctAgEPfDG9fi8tt3qmgZATJ7Vsfx-LJeynVsLU7ghNYtCFRxMxOSPyaqSME2B6_3452zhXIlDA"
    };
    var body = json.encode({"faceImage": base64Image});

    String url = 'http://192.168.0.69:15420/api/mobile/biometric/identify';
    if (base64Image != null) {
      http.Response response =
          await http.post(Uri.encodeFull(url), headers: headers, body: body);
      if (ResponseBody.fromJson(json.decode(response.body)).success == true) {
        print(response.body);
        return ResponseBody.fromJson(json.decode(response.body)).data;
      } else {
        print(response.body);

        return [];
      }
    } else {
      throw Exception('empty');
    }
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    var _futureBuilder = new FutureBuilder(
        future: usersFound,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
                child: Center(
                    child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue[900]),
            )));
          if (!snapshot.hasData)
            return Container(
                child: Center(
                    child:
                        Text('Chụp ảnh chân dung để tìm thông tin cá nhân')));
          return createMyListView(context, snapshot);
        });
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: new AppBar(
              automaticallyImplyLeading: false,
              actions: <Widget>[
                Container(
                    padding: EdgeInsets.all(1),
                    child: MaterialButton(
                      color: Colors.blue[900],
                      textColor: Colors.yellow[600],
                      splashColor: Colors.yellow[600],
                      elevation: 8,
                      shape: BeveledRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(2, 6))),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: RichText(
                          text: TextSpan(
                              text: 'Đăng ký',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.yellow[600],
                                  fontWeight: FontWeight.w500))),
                    )),
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
                            child: _displayCapturedImage(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: size - 110,
                      left: size - 60,
                      child: createCameraButton()),
                  Positioned.fill(
                      child: Align(
                        child: _retakePhoto(),
                        alignment: Alignment.bottomCenter,
                      ))
                ]);
              } else {
                return Container();
              }
            },
          ),
          Expanded(child: _futureBuilder)
        ]));
  }

  Widget createCameraButton() {
    if (imageCaptured == true) {
      return Container();
    } else
      return Column(children: [
        SizedBox(
          height: 35,
          width: 35,
          child: FloatingActionButton(
              heroTag: "btnSwitchCamera",
              elevation: 8,
              backgroundColor: Colors.blue[900],
              child: IconTheme(
                data: new IconThemeData(color: Colors.yellow[600], size: 20),
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
            heroTag: "btnCameraCapture",
            elevation: 8,
            backgroundColor: Colors.blue[900],
            child: IconTheme(
              data: new IconThemeData(color: Colors.yellow[600], size: 35),
              child: new Icon(Icons.photo_camera),
            ),
            onPressed: () {
              _onCapturePressed();
            })
      ]);
  }

  Widget createMyListView(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> values = snapshot.data;
    if (values.isEmpty) {
      return Column(children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Center(
            child: Text('Không tìm thấy kết quả'),
          ),
        ),
      ]);
    }
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return UserCard(
          values[index],
        );
      },
    );
  }

  Widget _retakePhoto() {
    if (imageCaptured == true) {
      return Container(
          child: MaterialButton(
            color: Colors.blue[900],
            textColor: Colors.yellow[600],
            splashColor: Colors.yellow[600],
            elevation: 8,
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () {
              setState(() {
                imageCaptured = false;
              });
            },
            child: const Text("Chụp lại"),
          ));
    } else
      return Container();
  }

  Widget _displayCapturedImage() {
    if (imageCaptured == false) {
      return CameraPreview(controller);
    } else
      return Image.file(File(imagePath));
  }
}
