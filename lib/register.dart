// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/home.dart';
import 'package:geolocator/geolocator.dart';

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
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> errors = List<String>();
  String _errorShowed = "";
  void checkNullValues(String email, String name, String age, String password,
      String passwordCopy) {
    List<String> textFields = List<String>();
    textFields.add(email);
    textFields.add(age);
    textFields.add(name);
    textFields.add(password);
    textFields.add(passwordCopy);
    int i = 0;
    while (i < textFields.length) {
      if (textFields[i].isEmpty) {
        errors.add("Preencha todos os campos.");
        break;
      }
      i++;
    }
  }

  void checkPasswordEqualValues(String password, String passwordCopy) {
    if (!(password.contains(passwordCopy) &&
        password.length == passwordCopy.length)) {
      errors.add("As senhas preenchidas são diferentes!");
    }
  }

  void checkValidLength(String name, String password) {
    if (name.length < 3)
      errors.add("Seu nome deve conter pelo menos 3 caractéres");
    if (password.length < 8)
      errors.add("Sua senha deve conter pelo menos 8 caractéres");
  }

  bool validateData(String email, String name, String age, String password,
      String passwordCopy) {
    checkNullValues(email, name, age, password, passwordCopy);
    checkPasswordEqualValues(password, passwordCopy);
    checkValidLength(name, password);
    return errors.length == 0;
  }

  void callErrors() {
    StringBuffer errorStringBuffer = StringBuffer();
    errorStringBuffer.write("Erros: \n");
    errors.forEach((error) {
      errorStringBuffer.write(error);
      errorStringBuffer.write("\n");
    });

    setState(() {
      _errorShowed = errorStringBuffer.toString();
    });

    Timer(Duration(seconds: 10), () {
      setState(() {
        errors.removeRange(-1, errors.length);
        _errorShowed = "";
      });
    });
  }

  void registerAccount() async {
    String email = widget._emailController.text;
    String name = widget._nameController.text;
    String age = widget._ageController.text;
    String password = widget._passwordController.text;
    String passwordCopy = widget._passwordCopyController.text;

    bool dataIsValid =
        await validateData(email, name, age, password, passwordCopy);
    if (dataIsValid) {
      try {
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);
        Position userPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        Map<String, dynamic> data = {
          "id": userCredential.user.uid,
          "email": email,
          "name": name,
          "age": age,
          "profilePicURL":
              "https://www.construtoracesconetto.com.br/wp-content/uploads/2020/03/blank-profile-picture-973460_640.png",
          "coordinates": {
            "latitude": userPos.latitude,
            "longitude": userPos.longitude
          }
        };
        await db.collection("appUsers").doc(userCredential.user.uid).set(data);
        enterHomeScreen(context);
      } catch (e) {
        print("operation failed: $e");
      }
    } else {
      callErrors();
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: widget._nameController,
                decoration: InputDecoration(labelText: "Nome:"),
              ),
              TextField(
                controller: widget._ageController,
                decoration: InputDecoration(labelText: "Idade:"),
              ),
              TextField(
                controller: widget._emailController,
                decoration: InputDecoration(labelText: "Email:"),
              ),
              TextField(
                controller: widget._passwordController,
                decoration: InputDecoration(labelText: "Senha:"),
              ),
              TextField(
                controller: widget._passwordCopyController,
                decoration:
                    InputDecoration(labelText: "Digite sua senha novamente:"),
              ),
              FlatButton(
                  onPressed: () => registerAccount(),
                  child: Text("Criar conta.")),
              Text(_errorShowed),
            ],
          ),
        ),
      ),
    );
  }
}
