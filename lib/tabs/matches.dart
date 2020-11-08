// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/register.dart';

class MatchTab extends StatefulWidget {
  @override
  _MatchTabState createState() => _MatchTabState();
}

class _MatchTabState extends State<MatchTab> {
  String name;
  int age;
  String photo;
  int index = 0;
  List<Map> users = [
    {
      "name": "example1",
      "photo": "assets/example1.jpeg",
      "age": 23,
    },
    {
      "name": "example2",
      "photo": "assets/example2.jpeg",
      "age": 23,
    },
    {
      "name": "example3",
      "photo": "assets/example3.jpeg",
      "age": 23,
    },
    {
      "name": "example4",
      "photo": "assets/example4.jpeg",
      "age": 23,
    },
    {
      "name": "example5",
      "photo": "assets/example5.jpeg",
      "age": 23,
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      photo = users[index]["photo"];
      name = users[index]["name"];
      age = users[index]["age"];
    });
  }

  void callNextUser() {
    index++;
    setState(() {
      photo = users[index]["photo"];
      name = users[index]["name"];
      age = users[index]["age"];
    });
  }

  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Image(
            image: AssetImage(photo),
          ),
          Column(
            children: [
              Text(
                name + " " + age.toString(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    color: Colors.redAccent,
                    child: Text("Nope."),
                    onPressed: () => callNextUser(),
                  ),
                  FlatButton(
                    color: Colors.greenAccent,
                    child: Text("Yes!"),
                    onPressed: () => callNextUser(),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
