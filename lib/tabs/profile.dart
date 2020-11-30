// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

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
          tags.add(element);
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

  List<String> errors = List<String>();
  String _errorShowed = "";

  void checkNullValues(String name, String age) {
    List<String> textFields = List<String>();
    textFields.add(age);
    textFields.add(name);
    int i = 0;
    while (i < textFields.length) {
      if (textFields[i].isEmpty) {
        errors.add("Preencha todos os campos.");
        break;
      }
      i++;
    }
  }

  void checkValidLength(String name) {
    if (name.length < 3)
      errors.add("Seu nome deve conter pelo menos 3 caractéres");
  }

  bool validateData(
    String name,
    String age,
  ) {
    errors = new List<String>();
    checkNullValues(name, age);
    checkValidLength(name);
    return errors.length < 0;
  }

  void updateUserInfo() async {
    Map<String, dynamic> userData = {
      "name": widget._nameController.text,
      "age": widget._ageController.text.toString(),
      "tags": tags
    };
    if (validateData(
        widget._nameController.text, widget._ageController.text.toString()))
      await db
          .collection("appUsers")
          .doc(auth.currentUser.uid)
          .update(userData);
    else
      callErrors();
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
        errors = List<String>();
        _errorShowed = "";
      });
    });
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
    setState(() {
      tags.remove(tag);
    });
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
                enabled: false,
                decoration: InputDecoration(labelText: "Email:"),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text("Interesses:")),

                  Container(
                    width: MediaQuery.of(context).size.width * .8,
                    height: MediaQuery.of(context).size.height * .2,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: tags.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 50,
                          child: Center(
                              child: Card(
                                color: Colors.blue,
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () => showTagRemovalDialog(tags[index]),
                                  child: Container(
                                    width: 300,
                                    height: 100,
                                    child:  Center
                                      (child: Text('${tags[index]}', style: TextStyle(color: Colors.white))
                                    ),
                                  )
                                ),

                                //onPressed: () => showTagRemovalDialog(element)
                            )
                          ),
                        );
                      }
                    ),
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
                  ElevatedButton(
                      onPressed: () => updateUserInfo(), child: Text("Salvar")),
                  RaisedButton(
                    color: Colors.redAccent,
                      textColor: Colors.white,
                      onPressed: () => logOut(), child: Text("Sair"))
                ],
              ),
              Text(_errorShowed),
            ],
          ),
        ));
    ;
  }
}
