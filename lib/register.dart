// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/home.dart';

class Register extends StatefulWidget {
  /**
   * Setting Register UI variables
   */

  TextEditingController _emailController =
      TextEditingController(text: "teste@teste.com");
  TextEditingController _passwordController =
      TextEditingController(text: "tester");
  TextEditingController _passwordCopyController =
      TextEditingController(text: "tester");
  TextEditingController _nameController =
      TextEditingController(text: "nome original");
  TextEditingController _ageController = TextEditingController(text: "84");

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  void validateAccount() async {
    String email = widget._emailController.text;
    String name = widget._nameController.text;
    String age = widget._ageController.text;
    String password = widget._passwordController.text;
    String passwordCopy = widget._passwordCopyController.text;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;

    if (password == passwordCopy) {
      try {
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);
        Map<String, dynamic> data = {
          "id": userCredential.user.uid,
          "email": email,
          "name": name,
          "age": age,
          "profilePicURL":
              "https://www.construtoracesconetto.com.br/wp-content/uploads/2020/03/blank-profile-picture-973460_640.png"
        };
        print(
            "------------------CREDENTIALSSSSSSSSSSSSSSSSSSSSSSSSSS----------" +
                userCredential.user.uid);
        await db
            .collection("appUsers")
            .doc(userCredential.user.uid)
            .set(data)
            .then((value) => print("------------USER ADDED------------"))
            .catchError((onError) => print("deu merda: $onError"));
        enterHomeScreen(context);
      } catch (e) {
        print("operation faild: $e");
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
      appBar: AppBar(
        title: Text("Login page"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: widget._nameController),
            TextField(controller: widget._ageController),
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
