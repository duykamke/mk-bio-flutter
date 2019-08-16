import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<Null> _resizePhoto(String filePath) async {
    imagePath = filePath;
    imageCaptured = true;
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
          _resizePhoto(filePath);
          FlutterNativeImage.cropImage(
              imagePath,
              0,
              0,
              MediaQuery.of(context).size.width.toInt(),
              MediaQuery.of(context).size.width.toInt());
          _portraitSubmit();
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

  pickPortraitFromGallery(ImageSource source) {
    setState(() {
      portraitFile = ImagePicker.pickImage(source: source);
      if (portraitFile != null) usersFound = _portraitSubmit();
    });
  }

  Future<List<UserInfo>> _portraitSubmit() async {
    File file = await portraitFile;
    imageBytes = file.readAsBytesSync();
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
        return [];
      }
    } else {
      throw Exception('empty');
    }
  }

  List<UserInfo> parseJson(List<UserInfo> response) {
    List<UserInfo> users = new List<UserInfo>();
    List jsonParsed = json.decode(response.toString());
    for (int i = 0; i < jsonParsed.length; i++) {
      users.add(new UserInfo.fromJson(jsonParsed[i]));
    }
    return users;
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
            return Container(child: Center(child: CircularProgressIndicator()));
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
              leading: IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
              ),
              actions: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: MaterialButton(
                      color: Colors.blue[900],
                      textColor: Colors.yellow[600],
                      splashColor: Colors.yellow[600],
                      elevation: 8,
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
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
                      child: Column(children: [
                        SizedBox(
                          height: 35,
                          width: 35,
                          child: FloatingActionButton(
                              heroTag: "btnSwitchCamera",
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
                            heroTag: "btnCameraCapture",
                            elevation: 8,
                            backgroundColor: Colors.blue[900],
                            child: IconTheme(
                              data: new IconThemeData(
                                  color: Colors.yellow[600], size: 35),
                              child: new Icon(Icons.photo_camera),
                            ),
                            onPressed: () {
                              pickPortraitFromGallery(ImageSource.gallery);
                            })
                      ])),
                ]);
              } else {
                return Container();
              }
            },
          ),
          Expanded(child: _futureBuilder)
        ]));
  }

  Widget createMyListView(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> values = snapshot.data;
    if (values.isEmpty) {
      return Container(
        child: Center(
          child: Text('Không tìm thấy kết quả'),
        ),
      );
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

  Widget _displayCapturedImage() {
    if (imageCaptured == false) {
      return CameraPreview(controller);
    } else
      return Image.file(File(imagePath));
  }
}
