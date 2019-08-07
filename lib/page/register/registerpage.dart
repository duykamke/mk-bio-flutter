import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'model.dart';
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
  final TextEditingController controller = new TextEditingController();
  DateTime selectedDate = DateTime.now();
  String _currentGender;
  Future<Post> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost();
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
        controller.text = selectedDate.day.toString() +
            '/' +
            selectedDate.month.toString() +
            '/' +
            selectedDate.year.toString();
      });
  }

  Future<File> portraitFile, idFrontFile, idBackFile;
  File fileData;
  List<int> imageBytes;
  String base64Image;

  Future<Post> fetchPost() async {
    final response =
        await http.get('https://jsonplaceholder.typicode.com/posts/1');

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return Post.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  Future<Map> _avatarSubmit() async {
    imageBytes = fileData.readAsBytesSync();
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

  Widget showPortrait() {
    return FutureBuilder<File>(
      future: portraitFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          fileData = snapshot.data;
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
              child: const Icon(Icons.add_a_photo));
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
          fileData = snapshot.data;
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
              child: const Icon(Icons.add_a_photo));
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
          fileData = snapshot.data;
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
              child: const Icon(Icons.add_a_photo));
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
        appBar: new AppBar(
          iconTheme: IconThemeData(color: Colors.indigo[800]),
          backgroundColor: Colors.grey[50],
          title: InkWell(
              child: Row(children: [
            Image(
              image: AssetImage("images/Logo.png"),
              height: 40,
              alignment: Alignment.bottomRight,
            ),
            RichText(
                text: TextSpan(
                    text: 'Đăng ký',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.indigo[800],
                        fontWeight: FontWeight.w500))),
          ])),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.save), onPressed: () {})
          ],
        ),
        body: ListView(children: [
          Form(
              child: Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 330,
                    child: ListView(
                      children: <Widget>[
                        new ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: new TextFormField(
                              decoration: new InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "CMND/CCCD",
                              ),
                            )),
                        new ListTile(
                          leading: const Icon(Icons.perm_identity),
                          title: new TextFormField(
                            decoration: new InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: "Tên",
                            ),
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.date_range),
                          title: new InkWell(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: IgnorePointer(
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                      labelText: 'Ngày sinh',
                                      border: UnderlineInputBorder()),
                                  controller: controller,
                                ),
                              )),
                        ),
                        new SizedBox(
                          height: 20,
                        ),
                        new ListTile(
                          leading: Icon(Icons.person),
                          title: SizedBox(
                              child: DropdownButtonFormField<String>(
                            hint: Text('Giới tính'),
                            decoration: InputDecoration.collapsed(
                                hintText: 'Giới tính'),
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
                        )
                      ],
                    ),
                  ))),
          Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Container(
                  height: 200,
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.blueGrey)),
                          ),
                          InkWell(
                              onTap: () {
                                pickPortraitFromGallery(ImageSource.gallery);
                              },
                              child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  padding: EdgeInsets.all(6),
                                  radius: Radius.circular(12),
                                  color: Colors.black,
                                  strokeWidth: 1,
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      child: showPortrait()))),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Tải lên ảnh CMND/CCCD',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.blueGrey)),
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
                                    color: Colors.black,
                                    strokeWidth: 1,
                                    child: Container(
                                        height: 50,
                                        width: 50,
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
                                    color: Colors.black,
                                    strokeWidth: 1,
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        child: showIDback()))),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text('Mặt sau'),
                            )
                          ]),
                        ]),
                  ])))
        ]));
  }
}
