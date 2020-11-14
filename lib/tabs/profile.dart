// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer_tinder/home.dart';

class ProfileTab extends StatefulWidget {
  /**
   * Setting ProfileTab UI variables
   */

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordCopyController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String profilePicURL = "";
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  void fetchUserData() async {
    DocumentSnapshot snapshot =
        await db.collection("appUsers").doc(auth.currentUser.uid).get();
    Map user = snapshot.data();

    String email = user["email"];
    String name = user["name"];
    String age = user["age"].toString();
    String imageURL = user["profilePicURL"];

    setState(() {
      widget._nameController.text = name;
      widget._emailController.text = email;
      widget._ageController.text = age;
      profilePicURL = imageURL;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
  }

  void logOut() {
    auth.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicURL),
            radius: 40,
          ),
          TextField(controller: widget._nameController),
          TextField(controller: widget._ageController),
          TextField(controller: widget._emailController),
          TextField(controller: widget._passwordController),
          TextField(controller: widget._passwordCopyController),
          FlatButton(onPressed: () => logOut(), child: Text("Sair da conta.")),
        ],
      ),
    );
  }
}
