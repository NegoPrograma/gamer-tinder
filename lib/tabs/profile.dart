// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTab extends StatefulWidget {
  /**
   * Setting ProfileTab UI variables
   */

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String profilePicURL = "";
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

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

  void updateUserPhoto() async {
    ImagePicker imagePicker = new ImagePicker();
    PickedFile choosenImage =
        await imagePicker.getImage(source: ImageSource.gallery);
    File image = File(choosenImage.path);
    String storagePath = "profilePhotos/" + auth.currentUser.uid + ".png";
    try {
      TaskSnapshot uploadProgress =
          await storage.ref(storagePath).putFile(image);
      String url = await downloadUpdatedPhoto(uploadProgress, storagePath);
      setState(() {
        profilePicURL = url;
      });
      print("link do arquivo de perfil: $url");
    } on FirebaseException catch (e) {
      print("ERRO! $e");
    }
  }

  Future<String> downloadUpdatedPhoto(
      TaskSnapshot uploadStatus, String path) async {
    String url = await uploadStatus.storage.ref(path).getDownloadURL();
    await db
        .collection("appUsers")
        .doc(auth.currentUser.uid)
        .update({"profilePicURL": url});
    return url;
  }

  void updateUserInfo() async {
    Map<String, dynamic> userData = {
      "name": widget._nameController.text,
      "email": widget._emailController.text,
      "age": widget._ageController.text.toString(),
    };

    await db.collection("appUsers").doc(auth.currentUser.uid).update(userData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
  }

  void logOut() async {
    await auth.signOut();
    Navigator.popAndPushNamed(context, "/");
  }

  Widget status = Container();
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
          FlatButton(
              onPressed: () => updateUserPhoto(),
              child: Text("Atualizar foto.")),
          status,
          TextField(controller: widget._nameController),
          TextField(controller: widget._ageController),
          TextField(controller: widget._emailController),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            FlatButton(onPressed: () => updateUserInfo(), child: Text("Atualizar info.")),
          FlatButton(onPressed: () => logOut(), child: Text("Sair da conta."))
          ],)
          ,
        ],
      ),
    );
  }
}
