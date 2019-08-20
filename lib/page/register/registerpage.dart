import 'package:mk_bio/page/register/model/response_body.dart';
import 'package:mk_bio/page/register/model/enrollment_form.dart';
import 'package:mk_bio/page/register/model/id_document.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';

import 'package:image_picker/image_picker.dart';

// Uncomment lines 7 and 10 to view the visual layout at runtime.
class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _dropdownError;
  String _portraitError;
  String _backIDError;
  String _frontIDError;
  String _bothIDError;

  DateTime selectedDate = DateTime.now();
  String _currentGender;

  TextEditingController idController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();

  Future<File> imageFile;

  SnackBar snackBar;
  @override
  void initState() {
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1940),
        lastDate: DateTime(2020));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = selectedDate.day.toString() +
            '/' +
            selectedDate.month.toString() +
            '/' +
            selectedDate.year.toString();
      });
  }

  Future<File> portraitFile, idFrontFile, idBackFile;
  File portraitData, idFrontData, idBackData;
  List<int> imageBytes;
  String base64Image;

  String convertImageToBase64(File fileData) {
    if (fileData != null) {
      imageBytes = fileData.readAsBytesSync();
      return base64Encode(imageBytes);
    } else
      return '';
  }

  /*Future<Map> _avatarSubmit() async {
    imageBytes = portraitData.readAsBytesSync();
    base64Image = base64Encode(imageBytes);

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "x-access-token":
          "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiJ9.zyLN_9bes3UJctAgEPfDG9fi8tt3qmgZATJ7Vsfx-LJeynVsLU7ghNYtCFRxMxOSPyaqSME2B6_3452zhXIlDA"
    };
    var body = json.encode({"faceImage": base64Image});

    print(base64Image);
    String url = 'http://117.6.128.91:17000/api/admin/enroll/assetFace';
    if (base64Image != null) {
      http.Response response =
          await http.post(Uri.encodeFull(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        print(response.body);
        // If the call to the server was successful, parse the JSON.
      } else {
        // If that call was not successful, throw an error.
        print(response.body);
      }

      Map content = json.decode(response.body);
      return content;
    } else {
      throw Exception('empty');
    }
  }*/

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<SnackBar> _enroll() async {
    IDDocumentClass newIDDocument = IDDocumentClass(
      frontImage: convertImageToBase64(idFrontData),
      backImage: convertImageToBase64(idBackData),
      type: 1,
    );
    EnrollmentForm newForm = EnrollmentForm(
      idCard: idController.text,
      name: nameController.text,
      birthDate: dateController.text,
      gender: _currentGender,
      faceImage: convertImageToBase64(portraitData),
      idDocument: newIDDocument,
    );

    Map<String, String> headers = {
      "content-type": "application/json",
      'Accept': 'application/json',
      "x-access-token":
          "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiJ9.zyLN_9bes3UJctAgEPfDG9fi8tt3qmgZATJ7Vsfx-LJeynVsLU7ghNYtCFRxMxOSPyaqSME2B6_3452zhXIlDA"
    };

    String url = 'http://192.168.0.69:15420/api/mobile/biometric/enroll';

    final body = json.encode(newForm);

    return http
        .post(Uri.encodeFull(url), headers: headers, body: body)
        .then((http.Response response) {
      var responseBody = ResponseBody.fromJson(json.decode(response.body));

      if (responseBody.success) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Đăng ký thành công")))
            .closed
            .then((reason) {
          // snackbar is now closed
        });
      } else {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Đăng ký thất bại")))
            .closed
            .then((reason) {
          // snackbar is now closed
        });
      }
      print(responseBody.success);

      return snackBar;
    });
  }

  Widget showPortrait() {
    return FutureBuilder<File>(
      future: portraitFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          portraitData = snapshot.data;
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: new IconTheme(
              data: new IconThemeData(color: Colors.blue[900]),
              child: new Icon(Icons.add_a_photo),
            ),
          );
        }
      },
    );
  }

  Widget showIDback() {
    return FutureBuilder<File>(
      future: idBackFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          idBackData = snapshot.data;
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: new IconTheme(
              data: new IconThemeData(color: Colors.blue[900]),
              child: new Icon(Icons.add_a_photo),
            ),
          );
        }
      },
    );
  }

  Widget showIDfront() {
    return FutureBuilder<File>(
      future: idFrontFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          idFrontData = snapshot.data;
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: new IconTheme(
              data: new IconThemeData(color: Colors.blue[900]),
              child: new Icon(Icons.add_a_photo),
            ),
          );
        }
      },
    );
  }

  //Open gallery
  pickPortraitFromGallery(ImageSource source) {
    setState(() {
      portraitFile = ImagePicker.pickImage(source: source);
    });
  }

  pickIDFrontFromGallery(ImageSource source) {
    setState(() {
      idFrontFile = ImagePicker.pickImage(source: source);
    });
  }

  pickIDBackFromGallery(ImageSource source) {
    setState(() {
      idBackFile = ImagePicker.pickImage(source: source);
    });
  }

  Widget showIDText() {
    if (_bothIDError == null) {
      if (_backIDError == null)
        return RichText(
          text: TextSpan(
              text: 'Tải lên ảnh CMND/CCCD',
              style: TextStyle(fontSize: 14, color: Colors.black)),
        );
      else if (_frontIDError == null)
        return RichText(
          text: TextSpan(
              text: 'Tải lên ảnh CMND/CCCD',
              style: TextStyle(fontSize: 14, color: Colors.black)),
        );
    } else
      return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _bothIDError ?? "",
            style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: new AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.blue[900]),
            backgroundColor: Colors.grey[50],
            leading: IconButton(
                iconSize: 24.0,
                icon: Icon(Icons.arrow_back),
                color: Colors.blue[900],
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                }),
            title: InkWell(
                child: Row(children: [
              Image(
                image: AssetImage("images/Logo.png"),
                height: 20,
              ),
              RichText(
                  text: TextSpan(
                      text: 'Đăng ký',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500))),
            ])),
          )),
      body: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(left: 20, right: 20),
            height: 1000,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(
                    child: new ListTile(
                        leading:
                            Icon(Icons.credit_card, color: Colors.blue[900]),
                        title: new TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Xin hãy điền CMND/CCCD';
                            }
                            return null;
                          },
                          controller: idController,
                          decoration: new InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue[900]),
                              ),
                              border: UnderlineInputBorder(),
                              labelText: "CMND/CCCD",
                              labelStyle: TextStyle(fontSize: 14),
                              focusColor: Colors.blue[900]),
                        ))),
                SizedBox(
                    child: new ListTile(
                  leading: Icon(Icons.short_text, color: Colors.blue[900]),
                  title: new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Xin hãy điền tên';
                      }
                      return null;
                    },
                    controller: nameController,
                    decoration: new InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[900]),
                      ),
                      border: UnderlineInputBorder(),
                      labelText: "Tên",
                      labelStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                )),
                SizedBox(
                  child: new ListTile(
                      leading: Icon(
                        Icons.date_range,
                        color: Colors.blue[900],
                      ),
                      title: new InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: IgnorePointer(
                            child: new TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Xin hãy điền ngày sinh';
                                }
                                return null;
                              },
                              decoration: new InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blue[900]),
                                  ),
                                  labelText: 'Ngày sinh',
                                  labelStyle: TextStyle(fontSize: 14),
                                  border: UnderlineInputBorder()),
                              controller: dateController,
                            ),
                          ))),
                ),
                SizedBox(
                    child: new ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: Colors.blue[900],
                        ),
                        title: Column(children: [
                          SizedBox(
                              child: DropdownButtonFormField<String>(
                            hint: Text('Giới tính'),
                            decoration: InputDecoration.collapsed(
                                hintText: 'Giới tính'),
                            value: _currentGender,
                            items: <String>['Nam', 'Nữ', 'Không xác định']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                _dropdownError = null;
                                _currentGender = newValue;
                              });
                            },
                          )),
                          _dropdownError == null
                              ? SizedBox.shrink()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _dropdownError ?? "",
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  )),
                        ]))),
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(bottom: 20),
                    child: Container(
                        child: Column(children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _portraitError == null
                                ? RichText(
                                    text: TextSpan(
                                        text: 'Tải lên ảnh chân dung',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _portraitError ?? "",
                                      style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    )),
                            InkWell(
                                onTap: () {
                                  pickPortraitFromGallery(ImageSource.camera);
                                },
                                child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    padding: EdgeInsets.all(6),
                                    radius: Radius.circular(12),
                                    color: Colors.blue[900],
                                    strokeWidth: 1,
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        child: showPortrait()))),
                          ]),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            showIDText(),
                            Column(children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    pickIDFrontFromGallery(ImageSource.camera);
                                  },
                                  child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      padding: EdgeInsets.all(6),
                                      radius: Radius.circular(12),
                                      color: Colors.blue[900],
                                      strokeWidth: 1,
                                      child: Container(
                                          height: 40,
                                          width: 40,
                                          child: showIDfront()))),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: _frontIDError == null
                                    ? Text('Mặt trước')
                                    : Text(
                                        _frontIDError ?? "",
                                        style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                              )
                            ]),
                            Column(children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    pickIDBackFromGallery(ImageSource.camera);
                                  },
                                  child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      padding: EdgeInsets.all(6),
                                      radius: Radius.circular(12),
                                      color: Colors.blue[900],
                                      strokeWidth: 1,
                                      child: Container(
                                          height: 40,
                                          width: 40,
                                          child: showIDback()))),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: _backIDError == null
                                    ? Text('Mặt sau')
                                    : Text(
                                        _backIDError ?? "",
                                        style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                              )
                            ]),
                          ]),
                    ]))),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 100),
                    child: MaterialButton(
                      color: Colors.blue[900],
                      textColor: Colors.yellow[600],
                      splashColor: Colors.yellow[600],
                      elevation: 8,
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        if (portraitFile != null) _portraitError = null;
                        if (idBackFile != null) _backIDError = null;
                        if (idFrontFile != null) _frontIDError = null;
                        if (idBackFile != null && idFrontFile != null)
                          _bothIDError = null;

                        bool _isValid = _formKey.currentState.validate();
                        if (_currentGender == null) {
                          setState(
                              () => _dropdownError = "Xin hãy chọn giới tính");
                          _isValid = false;
                        }
                        if (portraitFile == null) {
                          setState(() =>
                              _portraitError = "Xin hãy tải lên ảnh chân dung");
                          _isValid = false;
                        }
                        if (idBackFile == null || idFrontFile == null) {
                          setState(() =>
                              _bothIDError = "Xin hãy tải lên ảnh CMND/CCCD");
                          _isValid = false;
                        }
                        if (idBackFile == null) {
                          setState(() => _backIDError = "Mặt sau");

                          _isValid = false;
                        }
                        if (idFrontFile == null) {
                          setState(() => _frontIDError = "Mặt trước");

                          _isValid = false;
                        }

                        if (_isValid) {
                          _enroll();
                        }
                      },
                      child: const Text("Đăng ký"),
                    )),
              ],
            ),
          )),
    );
  }
}
