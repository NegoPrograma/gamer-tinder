// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(FirestoreExampleApp());
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class FirestoreExampleApp extends StatelessWidget {
  /// Given a [Widget], wrap and return a [MaterialApp].
  MaterialApp withMaterialApp(Widget body) {
    return MaterialApp(
      title: 'Firestore Example App',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: body,
      ),
    );
  }

  void register() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("listoftests").doc("test").set({"param": "ui"});
  }

  Widget Accounts() {
    register();
    return Center();
  }

  @override
  Widget build(BuildContext context) {
    return withMaterialApp(Center(child: Accounts()));
  }
}
