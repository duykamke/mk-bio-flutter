import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mk_bio/page/identify/model/user_info.dart';

class UserCard extends StatefulWidget {
  final UserInfo user;

  UserCard(this.user);

  @override
  State<StatefulWidget> createState() {
    return UserCardState(user);
  }
}

class UserCardState extends State<UserCard> {
  UserInfo user;

  UserCardState(this.user);

  Widget get userCard {
    int fap = (100 - user.fap).round();
    return new Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            child: ListTile(
              leading: Image.memory(base64Decode(user.image)),
              title: Text('${user.name} '),
              subtitle: Text('CMND/CCCD: ${user.subjectId}'),
              trailing: Column(children: [
                Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(2),
                  child: Center(child: Text('$fap')),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue[900], width: 1)),
                ),
                RichText(
                    text: TextSpan(
                        text: 'Độ chính xác',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        )))
              ]),
            ),
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: userCard,
    );
  }
}
