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
  List<FlatButton> tagButtons = List<FlatButton>();
  List<String> tags = List<String>();

  void fetchUserData() async {
    DocumentSnapshot snapshot =
        await db.collection("appUsers").doc(auth.currentUser.uid).get();
    Map<String, dynamic> user = snapshot.data();

    String email = user["email"];
    String name = user["name"];
    String age = user["age"].toString();
    String imageURL = user["profilePicURL"];
    if (user["tags"] != null) {
      tags = List<String>.from(user["tags"]);
      tags.forEach((element) {
        setState(() {
          tagButtons.add(
            FlatButton(
              color: Colors.blueAccent,
              onPressed: ()=>showTagRemovalDialog(element),
              child: Text(element),
            ),
          );
        });
      });
    }

    setState(() {
      widget._nameController.text = name;
      widget._emailController.text = email;
      widget._ageController.text = age;
      profilePicURL = imageURL;
    });

    setState(() {});
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
      "tags": tags
    };

    await db.collection("appUsers").doc(auth.currentUser.uid).update(userData);
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void logOut() async {
    await auth.signOut();
    Navigator.popAndPushNamed(context, "/");
  }

  void removeTag(String tag) async {
    tags.remove(tag);
    await db
        .collection("appUsers")
        .doc(auth.currentUser.uid)
        .update({"tags": tags});
  }

  void showTagRemovalDialog(String tag) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Deseja remover essa tag?"),
            actions: <Widget>[
              // define os botões na base do dialogo
              FlatButton(
                child: new Text("Não"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Sim"),
                onPressed: () {
                  removeTag(tag);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void addTagToList(String tag) {
    //no caso do usuário tentar colocar a opção da lista "selecione uma opção"
    if (!tag.contains("uma") && !tags.contains(tag)) {
      setState(() {
        tagButtons.add(FlatButton(
            color: Colors.blueAccent,
            onPressed: () {
              showTagRemovalDialog(tag);
            },
            child: Text(tag)));
        tags.add(tag);
      });
    }
  }

  AlertDialog showTagOptions() {
    String dropdownValue = 'Selecione uma opção.';
    DropdownButton options = DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>[
        'Selecione uma opção.',
        'CS:GO',
        'GTAV',
        'League of Legends',
        'Dark Souls'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    return AlertDialog(
      title: new Text("Selecione uma tag."),
      content: options,
      actions: <Widget>[
        // define os botões na base do dialogo
        FlatButton(
          child: new Text("Fechar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: new Text("Adicionar Tag"),
          onPressed: () {
            addTagToList(dropdownValue);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Widget status = Container();
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profilePicURL),
                radius: 40,
              ),
              FlatButton(
                  onPressed: () => updateUserPhoto(),
                  child: Text("Mudar imagem de perfil")),
              status,
              TextField(controller: widget._nameController),
              TextField(controller: widget._ageController),
              TextField(controller: widget._emailController),
              Column(
                children: [
                  Text("Suas tags: "),
                  Row(
                    children: tagButtons,
                  ),
                  FlatButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showTagOptions();
                          });
                    },
                    child: Text("+"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                      onPressed: () => updateUserInfo(), child: Text("Salvar")),
                  FlatButton(
                      onPressed: () => logOut(), child: Text("Sair da conta."))
                ],
              ),
            ],
          ),
        ));
    ;
  }
}
