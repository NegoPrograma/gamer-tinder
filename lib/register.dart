// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  /**
   * Setting Register UI variables
   */

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordCopyController = TextEditingController();

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  void validateAccount() {
    String email = widget._emailController.text;
    String password = widget._passwordController.text;
    String passwordCopy = widget._passwordCopyController.text;

    FirebaseAuth auth = FirebaseAuth.instance;
    if (password == passwordCopy) {
      auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .catchError(
            (onError) => print(onError),
          );
    }
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
