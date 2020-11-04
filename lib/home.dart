// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/register.dart';

class Home extends StatefulWidget {
  /**
   * Setting Home UI variables
   */

  String user = "Clica aqui vei";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void showUser() {
    setState(() => widget.user =
        "Bem vindo, dono do email:" + FirebaseAuth.instance.currentUser.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"),backgroundColor: Colors.black,),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FlatButton(onPressed: () => showUser(), child: Text(widget.user))
          ],
        ),
      ),
    );
  }
}
