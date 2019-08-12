import 'package:flutter/material.dart';
import 'package:epin/page/register/registerpage.dart';

// Uncomment lines 7 and 10 to view the visual layout at runtime.

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Form(
            key: _formKey,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(children: <Widget>[
                Positioned.fill(
                    top: 70,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                          child: Column(children: <Widget>[
                        Image(
                          image: AssetImage("images/Logo.png"),
                          height: 60,
                        ),
                        Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(top: 30, left: 10),
                            child: RichText(
                                text: TextSpan(
                                    text: 'Welcome back to MK ABIS',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blueGrey[900],
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500))))
                      ])),
                    )),
                Positioned.fill(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            height: 450,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 50),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Color(0xDEBB5D),
                                  width: 1.0,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0xDEBB5D),
                                    spreadRadius: 0.0,
                                    blurRadius: 10,
                                  )
                                ]),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(bottom: 8, top: 70),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.person),
                                      hintText: 'Điền tên người dùng ở đây',
                                      labelText: 'Tên người dùng',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextFormField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.person),
                                      hintText: 'Điền mật khẩu ở đây',
                                      labelText: 'Mật khẩu',
                                    ),
                                  ),
                                )
                              ],
                            )))),
                Positioned.fill(
                    bottom: 100,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      width: 300,
                      child: MaterialButton(
                        color: Colors.blue[900],
                        textColor: Colors.yellow[600],
                        shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        onPressed: () {
                          navigateToRegister(context);
                        },
                        child: Text("Đăng nhập",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                    fontFamily: 'Montserrat')
                                .copyWith()),
                      ),
                    )),
              ]),
            )));
  }

  Future navigateToRegister(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }
}
