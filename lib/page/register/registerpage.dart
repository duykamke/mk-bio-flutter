import 'package:epin/page/register/model/enrollment_form.dart';
import 'package:epin/page/register/model/id_document.dart';

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
  DateTime selectedDate = DateTime.now();
  String _currentGender;

  TextEditingController idController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2016),
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
    imageBytes = fileData.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Future<Map> _avatarSubmit() async {
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
  }

  Future<EnrollmentForm> _enroll() async {
    IDDocumentClass newIDDocument = IDDocumentClass(
      frontImage: convertImageToBase64(idFrontData),
      backImage: convertImageToBase64(idBackData),
      type: 1,
    );
    EnrollmentForm newForm = EnrollmentForm(
      idCard: idController.text,
      name: nameController.text,
      birtDate: dateController.text,
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
    print(body);
    return http
        .post(Uri.encodeFull(url), headers: headers, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }

      print(response.body);

      return EnrollmentForm.fromJson(json.decode(response.body));
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

  Widget showIDfront() {
    return FutureBuilder<File>(
      future: idFrontFile,
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: new AppBar(
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
                      text: 'Đăng ký',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500))),
            ])),
          )),
      body: Form(
          child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(left: 20, right: 20),
        height: 1000,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(
                child: new ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: new TextFormField(
                      controller: idController,
                      decoration: new InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "CMND/CCCD",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                    ))),
            SizedBox(
                child: new ListTile(
              leading: const Icon(Icons.perm_identity),
              title: new TextFormField(
                controller: nameController,
                decoration: new InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Tên",
                  labelStyle: TextStyle(fontSize: 14),
                ),
              ),
            )),
            SizedBox(
              child: new ListTile(
                  leading: const Icon(Icons.date_range),
                  title: new InkWell(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: IgnorePointer(
                        child: new TextFormField(
                          
                          decoration: new InputDecoration(
                              labelText: 'Ngày sinh',
                              labelStyle: TextStyle(fontSize: 14),
                              border: UnderlineInputBorder()),
                          controller: dateController,
                        ),
                      ))),
            ),
            SizedBox(
                child: new ListTile(
              leading: Icon(Icons.person),
              title: SizedBox(
                  child: DropdownButtonFormField<String>(
                hint: Text('Giới tính'),
                decoration: InputDecoration.collapsed(hintText: 'Giới tính'),
                value: _currentGender,
                items: <String>['Nam', 'Nữ', 'Không xác định']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    _currentGender = newValue;
                  });
                },
              )),
            )),
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
                        RichText(
                          text: TextSpan(
                              text: 'Tải lên ảnh chân dung',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                        ),
                        InkWell(
                            onTap: () {
                              pickPortraitFromGallery(ImageSource.gallery);
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
                        RichText(
                          text: TextSpan(
                              text: 'Tải lên ảnh CMND/CCCD',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                        ),
                        Column(children: <Widget>[
                          InkWell(
                              onTap: () {
                                pickIDFrontFromGallery(ImageSource.gallery);
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
                            child: Text('Mặt trước'),
                          )
                        ]),
                        Column(children: <Widget>[
                          InkWell(
                              onTap: () {
                                pickIDBackFromGallery(ImageSource.gallery);
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
                            child: Text('Mặt sau'),
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
                    setState(() {
                      _enroll();
                    });
                  },
                  child: const Text("Đăng ký"),
                )),
          ],
        ),
      )),
    );
  }
}