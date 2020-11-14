// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gamer_tinder/classes/Messages.dart';
import 'package:gamer_tinder/home.dart';
import 'package:gamer_tinder/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => Login(),
        "/Home":(context) => Home(),
        "/Messages": (context) => Messages(ModalRoute.of(context).settings.arguments)
      },
    ),
  );
}
