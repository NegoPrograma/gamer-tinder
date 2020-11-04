// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/home.dart';

class Register extends StatefulWidget {
  /**
   * Setting Register UI variables
   */

  TextEditingController _emailController = TextEditingController(text:"teste@teste.com");
TextEditingController _passwordController = TextEditingController(text:"tester");
  TextEditingController _passwordCopyController = TextEditingController(text:"tester");

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  void validateAccount() async {
    String email = widget._emailController.text;
    String password = widget._passwordController.text;
    String passwordCopy = widget._passwordCopyController.text;

    FirebaseAuth auth = FirebaseAuth.instance;
    if (password == passwordCopy) {
      UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .catchError(
            (onError) => print(onError),
          );
      if (userCredential.user.email != "") {
        enterHomeScreen(this.context);
      }
    }
  }

  void enterHomeScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login page"),backgroundColor: Colors.redAccent,),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: widget._emailController),
            TextField(controller: widget._passwordController),
            TextField(controller: widget._passwordCopyController),
            FlatButton(
                onPressed: () => validateAccount(),
                child: Text("Criar conta.")),
          ],
        ),
      ),
    );
  }
}
