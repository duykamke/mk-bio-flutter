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
    return ListTile(
      leading: Image.memory(base64Decode(user.image)),
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        RichText(
            text: TextSpan(
                text: '${user.name}',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold))),
        Container(
          width: 45,
          height: 45,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          padding: EdgeInsets.all(2),
          child: Center(child: Text('$fap')),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[900], width: 1)),
        ),
      ]),
      subtitle:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('CMND/CCCD: ${user.subjectId}'),
        RichText(
            text: TextSpan(
                text: 'Độ chính xác',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[900],
                )))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: userCard,
    );
  }
}
