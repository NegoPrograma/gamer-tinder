// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/register.dart';

class Login extends StatefulWidget {
  /**
   * Setting login UI variables
   */

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void enterRegisterScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Register(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: widget._emailController),
            TextField(controller: widget._passwordController),
            FlatButton(onPressed: () => {}, child: Text("Logar no sistema.")),
            FlatButton(
                onPressed: () => enterRegisterScreen(this.context),
                child: Text("Registrar-se"))
          ],
        ),
      ),
    );
  }
}
